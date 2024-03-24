//
//  CoinsListViewModel.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import Combine
import Foundation
import UIKit

@MainActor
protocol CoinsListViewModelDelegate: AnyObject {
    func didFailLoadingCoins(with error: Error, onRetry: Bool)
    func showNoInternetConnectionToast()
}

@MainActor
protocol CoinsListViewModelProtocol: AnyObject {
    var dataSourceSnapshot: CoinsListViewModel.DataSourceSnapshot { get }

    func loadCoins() async throws
    func loadImage(for url: URL) async -> UIImage?

    func startPolling() -> AsyncStream<Void>

    func searchCoins(text: String?)
}

final class CoinsListViewModel: CoinsListViewModelProtocol {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>

    private let coinsService: CoinsServiceProtocol
    private let imageService: ImageServiceProtocol
    private unowned let delegate: CoinsListViewModelDelegate

    private let coinsPollingStream: AsyncPollingStream<[Coin]>

    private(set) var dataSourceSnapshot: DataSourceSnapshot
    private var coins: [Coin] = []

    private var cancellables: Set<AnyCancellable> = []

    init(coinsService: CoinsServiceProtocol, imageService: ImageServiceProtocol, reachabilityService: ReachabilityServiceProtocol, delegate: CoinsListViewModelDelegate) {
        self.coinsService = coinsService
        self.imageService = imageService
        self.delegate = delegate

        coinsPollingStream = AsyncPollingStream { try await coinsService.coins }

        dataSourceSnapshot = DataSourceSnapshot()
        dataSourceSnapshot.appendSections([.coins])
        dataSourceSnapshot.appendItems((0..<15).map { _ in .loading }, toSection: .coins)

        reachabilityService.startMonitoring()
        reachabilityService.hasActiveNetwork
            .receive(on: DispatchQueue.main)
            .removeDuplicates()
            .sink { hasActiveNetwork in
                guard !hasActiveNetwork else { return }
                delegate.showNoInternetConnectionToast()
            }
            .store(in: &cancellables)
    }

    func loadCoins() async throws {
        do {
            coins = try await coinsService.coins

            dataSourceSnapshot.deleteSections([.coins])
            dataSourceSnapshot.appendSections([.coins])

            let items: [Section.Item] = coins.map { .coin($0) }
            dataSourceSnapshot.appendItems(items, toSection: .coins)
        } catch {
            delegate.didFailLoadingCoins(with: error, onRetry: !coins.isEmpty)
            throw error
        }
    }

    func loadImage(for url: URL) async -> UIImage? {
        try? await imageService.image(for: url)
    }

    func startPolling() -> AsyncStream<Void> {
        return AsyncStream<Void> { continuation in
            Task {
                for await result in coinsPollingStream.start() {
                    switch result {
                    case .success(let coins):
                        for coin in coins {
                            guard let index = dataSourceSnapshot.itemIdentifiers.firstIndex(where: { itemIdentifier in
                                guard case .coin(let coin) = itemIdentifier.type else { return false }
                                return coin.symbol == coin.symbol
                            }) else { continue }

                            dataSourceSnapshot.itemIdentifiers[index].type = .coin(coin)
                        }

                        dataSourceSnapshot.reloadItems(dataSourceSnapshot.itemIdentifiers)
                    case .failure(let error):
                        print("Received error: \(error)")
                    }
                    continuation.yield(())
                }
                continuation.finish()
            }
        }
    }

    func searchCoins(text: String?) {
        let coins: [Coin]

        if let text, !text.isEmpty {
            coins = self.coins.filter { coin in
                coin.name.lowercased().contains(text.lowercased()) || coin.symbol.lowercased().contains(text.lowercased())
            }
        } else {
            coins = self.coins
        }

        dataSourceSnapshot.deleteSections([.coins])
        dataSourceSnapshot.appendSections([.coins])

        let items: [Section.Item] = coins.map { .coin($0) }
        dataSourceSnapshot.appendItems(items, toSection: .coins)
    }
}

extension CoinsListViewModel {
    enum Section: Hashable {
        case coins
    }
}

extension CoinsListViewModel.Section {
    class Item: Hashable {
        let id = UUID()
        var type: `Type`

        init(type: `Type`) {
            self.type = type
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }

        static func == (lhs: Item, rhs: Item) -> Bool {
            lhs.id == rhs.id
        }
    }
}

extension CoinsListViewModel.Section.Item {
    typealias Item = CoinsListViewModel.Section.Item

    enum `Type` {
        case loading, coin(Coin)
    }

    static var loading: Item { Item(type: .loading) }

    static func coin(_ coin: Coin) -> Item {
        Item(type: .coin(coin))
    }
}

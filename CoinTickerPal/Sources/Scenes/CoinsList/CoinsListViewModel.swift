//
//  CoinsListViewModel.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import Foundation
import UIKit

@MainActor
protocol CoinsListViewModelDelegate: AnyObject {
    func didFailLoadingCoins(with error: Error)
}

@MainActor
protocol CoinsListViewModelProtocol: AnyObject {
    var dataSourceSnapshot: CoinsListViewModel.DataSourceSnapshot { get }

    func loadCoins() async throws
    func loadImage(for url: URL) async -> UIImage?

    func searchCoins(text: String?)
}

final class CoinsListViewModel: CoinsListViewModelProtocol {
    typealias DataSourceSnapshot = NSDiffableDataSourceSnapshot<Section, Section.Item>

    enum Section: Hashable {
        enum Item: Hashable {
            case loading(Int)
            case coin(Coin)
        }

        case loading
        case coins
    }

    private var coins: [Coin] = []
    private(set) var dataSourceSnapshot: DataSourceSnapshot

    private let coinsService: CoinsServiceProtocol
    private let imageService: ImageServiceProtocol
    private unowned let delegate: CoinsListViewModelDelegate

    init(coinsService: CoinsServiceProtocol, imageService: ImageServiceProtocol, delegate: CoinsListViewModelDelegate) {
        self.coinsService = coinsService
        self.imageService = imageService
        self.delegate = delegate

        dataSourceSnapshot = DataSourceSnapshot()
        dataSourceSnapshot.appendSections([.loading])
        dataSourceSnapshot.appendItems((0..<15).map { .loading($0) }, toSection: .loading)
    }

    func loadCoins() async throws {
        do {
            coins = try await coinsService.coins

            dataSourceSnapshot.deleteSections([.loading])
            dataSourceSnapshot.deleteSections([.coins])
            dataSourceSnapshot.appendSections([.coins])
            dataSourceSnapshot.appendItems(coins.map { .coin($0) }, toSection: .coins)
        } catch {
            delegate.didFailLoadingCoins(with: error)
            throw error
        }
    }

    func loadImage(for url: URL) async -> UIImage? {
        try? await imageService.image(for: url)
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
        dataSourceSnapshot.appendItems(coins.map { .coin($0) }, toSection: .coins)
    }
}

//
//  CoinsListViewModel.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

typealias Coin = String

import Foundation
import UIKit

protocol CoinsListViewModelDelegate: AnyObject {
    func didFailLoadingCoins(with error: Error)
}

protocol CoinsListViewModelProtocol: AnyObject {
    var dataSourceSnapshot: CoinsListViewModel.DataSourceSnapshot { get }

    func loadCoins() async throws
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

    private(set) var dataSourceSnapshot: DataSourceSnapshot

    private unowned let delegate: CoinsListViewModelDelegate

    init(delegate: CoinsListViewModelDelegate) {
        self.delegate = delegate

        dataSourceSnapshot = DataSourceSnapshot()
        dataSourceSnapshot.appendSections([.loading])
        dataSourceSnapshot.appendItems((0..<15).map { .loading($0) }, toSection: .loading)
    }

    func loadCoins() async throws {
        do {
            try await Task.sleep(for: .seconds(2))

            let coins = ["BTC", "ETH", "SOL", "BORG", "JUP"]

            dataSourceSnapshot.deleteSections([.loading])
            dataSourceSnapshot.deleteSections([.coins])
            dataSourceSnapshot.appendSections([.coins])
            dataSourceSnapshot.appendItems(coins.map { .coin($0) }, toSection: .coins)
        } catch {
            delegate.didFailLoadingCoins(with: error)
            throw error
        }
    }
}

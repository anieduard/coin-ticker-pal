//
//  CoinsRepository.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 25.03.2024.
//

import Foundation

protocol CoinsRepositoryProtocol: Resolvable {
    var coins: [Coin] { get async throws }
}

final class CoinsRepository: CoinsRepositoryProtocol {
    private let coinsService: any CoinsServiceProtocol

    var coins: [Coin] {
        get async throws {
            let coins = try await coinsService.coins
            let currencyLabels = try await currencyLabels

            return coins.compactMap { coin in
                guard let name = currencyLabels[coin.symbol] else { return nil }
                return Coin(name: name, symbol: coin.symbol, price: coin.lastPrice, priceChange: coin.dailyChangeRelative, earnYield: coin.lastPrice < 50)
            }
        }
    }

    private var currencyLabels: [String: String] {
        get async throws {
            let currencyLabels = try await coinsService.currencyLabels

            return currencyLabels.reduce(into: [:]) { result, currencyLabel in
                result[currencyLabel.symbol] = currencyLabel.name
            }
        }
    }

    init(coinsService: any CoinsServiceProtocol) {
        self.coinsService = coinsService
    }
}

//
//  CoinsRepository.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 25.03.2024.
//

import Foundation

// sourcery: AutoMockable
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
                let imageURL = imageURLs[coin.symbol]
                return Coin(name: name, symbol: coin.symbol, price: coin.lastPrice, priceChange: coin.dailyChangeRelative, earnYield: coin.lastPrice < 50, imageURL: imageURL)
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

    private let imageURLs: [String: URL] = {
        let urls = [
            "BTC": "https://assets.coingecko.com/coins/images/1/small/bitcoin.png?1696501400",
            "ETH": "https://assets.coingecko.com/coins/images/279/small/ethereum.png?1696501628",
            "BORG": "https://assets.coingecko.com/coins/images/2117/small/YJUrRy7r_400x400.png?1696503083",
            "LTC": "https://assets.coingecko.com/coins/images/2/small/litecoin.png?1696501400",
            "XRP": "https://assets.coingecko.com/coins/images/44/small/xrp-symbol-white-128.png?1696501442",
            "DSH": "https://assets.coingecko.com/coins/images/19/small/dash-logo.png?1696501423",
            "RRT": "https://assets.coingecko.com/coins/images/6502/small/Recovery_Right_Token.png?1696506861",
            "EOS": "https://assets.coingecko.com/coins/images/738/small/eos-eos-logo.png?1696501893",
            "DOGE": "https://assets.coingecko.com/coins/images/5/small/dogecoin.png?1696501409",
            "MATIC": "https://assets.coingecko.com/coins/images/4713/small/polygon.png?1698233745",
            "NEXO": "https://assets.coingecko.com/coins/images/3695/small/nexo.png?1696504370",
            "OCEAN": "https://assets.coingecko.com/coins/images/3687/small/ocean-protocol-logo.jpg?1696504363",
            "BEST": "https://assets.coingecko.com/coins/images/8738/small/BEST-Coin-Logo.png?1696508897",
            "AAVE": "https://assets.coingecko.com/coins/images/12645/small/AAVE.png?1696512452",
            "PLU": "https://assets.coingecko.com/coins/images/1241/small/pluton.png?1696502316",
            "FIL": "https://assets.coingecko.com/coins/images/12817/small/filecoin.png?1696512609"
        ]

        return urls.compactMapValues { URL(string: $0) }
    }()

    init(coinsService: any CoinsServiceProtocol) {
        self.coinsService = coinsService
    }
}

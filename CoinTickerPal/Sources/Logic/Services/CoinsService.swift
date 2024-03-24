//
//  CoinsService.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

protocol CoinsServiceProtocol: APIService {
    var coins: [Coin] { get async throws }
}

final class CoinsService: CoinsServiceProtocol {
    private let networkClient: any NetworkClientProtocol

    var coins: [Coin] {
        get async throws {
            let request = request(for: .tickers, queryItems: [.symbols])
            let coins: [Response.Coin] = try await networkClient.load(request)
            let currencyLabels = try await currencyLabels

            return coins.compactMap { coin in
                guard let name = currencyLabels[coin.symbol] else { return nil }
                return Coin(name: name, symbol: coin.symbol, price: coin.lastPrice, priceChange: coin.dailyChangeRelative)
            }
        }
    }

    private var currencyLabels: [String: String] {
        get async throws {
            let request = request(for: .currencyLabel)
            let response: [[Response.CurrencyLabel]] = try await networkClient.load(request)

            return response.flatMap { $0 }.reduce(into: [:]) { result, currencyLabel in
                result[currencyLabel.symbol] = currencyLabel.name
            }
        }
    }

    init(networkClient: any NetworkClientProtocol) {
        self.networkClient = networkClient
    }
}

private extension CoinsService {
    enum Response {
        struct Coin: Decodable {
            let symbol: String
            let bid: Double
            let bidSize: Double
            let ask: Double
            let askSize: Double
            let dailyChange: Double
            let dailyChangeRelative: Double
            let lastPrice: Double
            let volume: Double
            let high: Double
            let low: Double

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()

                symbol = try container.decode(String.self).formatted
                bid = try container.decode(Double.self)
                bidSize = try container.decode(Double.self)
                ask = try container.decode(Double.self)
                askSize = try container.decode(Double.self)
                dailyChange = try container.decode(Double.self)
                dailyChangeRelative = try container.decode(Double.self)
                lastPrice = try container.decode(Double.self)
                volume = try container.decode(Double.self)
                high = try container.decode(Double.self)
                low = try container.decode(Double.self)
            }
        }

        struct CurrencyLabel: Decodable {
            let symbol: String
            let name: String

            init(from decoder: Decoder) throws {
                var container = try decoder.unkeyedContainer()

                symbol = try container.decode(String.self)
                name = try container.decode(String.self)
            }
        }
    }
}

private extension String {
    var formatted: String {
        let pair = replacingOccurrences(of: "t", with: "")

        if pair.contains(":") {
            return pair.components(separatedBy: ":")[0]
        } else {
            return String(pair.prefix(3))
        }
    }
}

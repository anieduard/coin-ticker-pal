//
//  CoinsService.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

// sourcery: AutoMockable
protocol CoinsServiceProtocol: Service {
    var coins: [CoinsService.Response.Coin] { get async throws }
    var currencyLabels: [CoinsService.Response.CurrencyLabel] { get async throws }
}

final class CoinsService: CoinsServiceProtocol {
    private let networkClient: any NetworkClientProtocol

    var coins: [Response.Coin] {
        get async throws {
            let request = request(for: .tickers, queryItems: [.symbols])
            return try await networkClient.load(request)
        }
    }

    var currencyLabels: [CoinsService.Response.CurrencyLabel] {
        get async throws {
            let request = request(for: .currencyLabel)
            let response: [[Response.CurrencyLabel]] = try await networkClient.load(request)

            return response.flatMap { $0 }
        }
    }

    init(networkClient: any NetworkClientProtocol) {
        self.networkClient = networkClient
    }
}

extension CoinsService {
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
        }

        struct CurrencyLabel: Decodable {
            let symbol: String
            let name: String
        }
    }
}

extension CoinsService.Response.Coin {
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

extension CoinsService.Response.CurrencyLabel {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()

        symbol = try container.decode(String.self)
        name = try container.decode(String.self)
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

//
//  CoinsRepositoryTests.swift
//  CoinTickerPalTests
//
//  Created by Eduard Ani on 25.03.2024.
//

import XCTest
@testable import CoinTickerPal

final class CoinsRepositoryTests: XCTestCase {
    var coinsService: CoinsServiceProtocolMock!
    var sut: CoinsRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()

        let coinsResponse: [CoinsService.Response.Coin] = [
            .init(
                symbol: "BTC",
                bid: 66976,
                bidSize: 6.03506578,
                ask: 66986,
                askSize: 3.10096715,
                dailyChange: 1835,
                dailyChangeRelative: 0.02815972,
                lastPrice: 66999,
                volume: 3094.43129125,
                high: 67949,
                low: 64670
            ),
            .init(
                symbol: "ETH",
                bid: 3451.5,
                bidSize: 319.83811813,
                ask: 3451.6,
                askSize: 82.20913147,
                dailyChange: 69.4,
                dailyChangeRelative: 0.0205198,
                lastPrice: 3451.5,
                volume: 3668.61323397,
                high: 3510,
                low: 3335.3
            ),
            .init(
                symbol: "OCEAN",
                bid: 1.1303,
                bidSize: 56851.60124929,
                ask: 1.1315,
                askSize: 89531.3203654,
                dailyChange: 0.0687,
                dailyChangeRelative: 0.06452522,
                lastPrice: 1.1334,
                volume: 42354.53241624,
                high: 1.1371,
                low: 1.0432
            )
        ]

        let currencyLabelsResponse: [CoinsService.Response.CurrencyLabel] = [
            .init(symbol: "BTC", name: "Bitcoin"),
            .init(symbol: "ETH", name: "Ethereum"),
            .init(symbol: "OCEAN", name: "OCEAN protocol")
        ]

        coinsService = CoinsServiceProtocolMock()
        coinsService.underlyingCoins = coinsResponse
        coinsService.underlyingCurrencyLabels = currencyLabelsResponse
        sut = CoinsRepository(coinsService: coinsService)
    }

    func testRepositoryReturnsCorrectCoins() async throws {
        let coins = try await sut.coins
        XCTAssertEqual(coins, [
            Coin(name: "Bitcoin", symbol: "BTC", price: 66999.0, priceChange: 0.02815972, earnYield: false),
            Coin(name: "Ethereum", symbol: "ETH", price: 3451.5, priceChange: 0.0205198, earnYield: false),
            Coin(name: "OCEAN protocol", symbol: "OCEAN", price: 1.1334, priceChange: 0.06452522, earnYield: true)
        ])
    }
}

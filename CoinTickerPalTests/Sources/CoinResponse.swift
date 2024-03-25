//
//  CoinResponse.swift
//  CoinTickerPalTests
//
//  Created by Eduard Ani on 25.03.2024.
//

import XCTest
@testable import CoinTickerPal

final class CoinResponse: XCTestCase {
    var coinsResponse: Data!
    var currencyLabelsResponse: Data!

    override func setUpWithError() throws {
        try super.setUpWithError()

        coinsResponse = """
        [
            [
                "tBTCUSD",
                66976,
                6.03506578,
                66986,
                3.10096715,
                1835,
                0.02815972,
                66999,
                3094.43129125,
                67949,
                64670
            ],
            [
                "tETHUSD",
                3451.5,
                319.83811813,
                3451.6,
                82.20913147,
                69.4,
                0.0205198,
                3451.5,
                3668.61323397,
                3510,
                3335.3
            ],
            [
                "tOCEAN:USD",
                1.1303,
                56851.60124929,
                1.1315,
                89531.3203654,
                0.0687,
                0.06452522,
                1.1334,
                42354.53241624,
                1.1371,
                1.0432
            ]
        ]
        """.data(using: .utf8)

        currencyLabelsResponse = """
        [
            [
                ["BTC", "Bitcoin"],
                ["ETH", "Ethereum"],
                ["OCEAN", "OCEAN protocol"]
            ]
        ]
        """.data(using: .utf8)
    }

    func testCoinsResponseMapsPropertiesProperly() throws {
        let jsonDecoder = JSONDecoder()
        let coins = try jsonDecoder.decode([CoinsService.Response.Coin].self, from: coinsResponse)

        XCTAssertEqual(coins, [
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
        ])
    }

    func testCurrencyLabelsResponseMapsPropertiesProperly() throws {
        let jsonDecoder = JSONDecoder()
        let coins = try jsonDecoder.decode([[CoinsService.Response.CurrencyLabel]].self, from: currencyLabelsResponse)

        XCTAssertEqual(coins.flatMap { $0 }, [
            .init(symbol: "BTC", name: "Bitcoin"),
            .init(symbol: "ETH", name: "Ethereum"),
            .init(symbol: "OCEAN", name: "OCEAN protocol")
        ])
    }
}

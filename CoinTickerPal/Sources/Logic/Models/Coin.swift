//
//  Coin.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

struct Coin: Equatable {
    let name: String
    let symbol: String
    let price: Double
    let priceChange: Double
    let earnYield: Bool
    let imageURL: URL?
}

//
//  Coin.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

struct Coin: Hashable {
    let name: String
    let symbol: String
    let price: Double
    let priceChange: Double
}
//
//  ImageCache.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation
import class UIKit.UIImage

protocol ImageCacheProtocol {
    func image(for key: String) -> UIImage?
    func set(image: UIImage?, for key: String)
}

final class ImageCache: ImageCacheProtocol {
    private var cache: [String: UIImage] = [:]
    private let queue = DispatchQueue(label: "com.anieduard.coin-ticker-pal.image.cache", attributes: .concurrent)

    func image(for key: String) -> UIImage? {
        queue.sync {
            return cache[key]
        }
    }

    func set(image: UIImage?, for key: String) {
        queue.async(flags: .barrier) { [weak self] in
            self?.cache[key] = image
        }
    }
}

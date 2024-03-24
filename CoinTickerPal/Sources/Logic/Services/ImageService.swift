//
//  ImageService.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation
import class UIKit.UIImage

protocol ImageServiceProtocol: Service {
    func image(for url: URL) async throws -> UIImage?
}

final class ImageService: ImageServiceProtocol {
    let networkClient: NetworkClientProtocol

    private let imageCache: ImageCacheProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
        #warning("change this to be injectable")
        self.imageCache = ImageCache()
    }

    func image(for url: URL) async throws -> UIImage? {
        if let image = imageCache.image(for: url.absoluteString) {
            return image
        }

        let request = URLRequest(url: url)

        let data = try await networkClient.load(request)

        guard let image = UIImage(data: data) else { return nil }

        imageCache.set(image: image, for: url.absoluteString)

        return image
    }
}
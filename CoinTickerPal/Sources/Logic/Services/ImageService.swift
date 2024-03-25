//
//  ImageService.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation
import class UIKit.UIImage

protocol ImageServiceProtocol: APIService {
    func image(for url: URL) async throws -> UIImage?
}

final class ImageService: ImageServiceProtocol {
    private let networkClient: any NetworkClientProtocol
    private let imageCache: any ImageCacheProtocol

    init(networkClient: any NetworkClientProtocol, imageCache: ImageCacheProtocol) {
        self.networkClient = networkClient
        self.imageCache = imageCache
    }

    func image(for url: URL) async throws -> UIImage? {
        if let image = imageCache.image(for: url.absoluteString) {
            return image
        }

        let request = request(for: url)
        let data = try await networkClient.load(request)

        guard let image = UIImage(data: data) else { return nil }

        imageCache.set(image: image, for: url.absoluteString)

        return image
    }
}

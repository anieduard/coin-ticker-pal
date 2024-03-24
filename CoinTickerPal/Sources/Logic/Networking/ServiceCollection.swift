//
//  ServiceCollection.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

final class ServiceCollection {
    private var container: [String: AnyObject] = [:]

    private let networkClient: NetworkClientProtocol

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func resolve<S: Service>(type: S.Type) -> S {
        let key = String(describing: type)

        if let service = container[key] as? S {
            return service
        }

        let service = S(networkClient: networkClient)
        container[key] = service
        return service
    }

    func resetAll() {
        container = [:]
    }
}

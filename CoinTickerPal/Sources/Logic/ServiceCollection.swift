//
//  ServiceCollection.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

final class ServiceCollection {
    private var services: [ObjectIdentifier: Any]

    init() {
        services = [:]
    }

    private init(services: [ObjectIdentifier : Any]) {
        self.services = services
    }

    func register<S: Service>(_ factory: () -> S) -> ServiceCollection {
        let key = ObjectIdentifier(S.self)
        let service = factory()

        services[key] = service

        return .init(services: services)
    }

    func resolve<S: Service>(_ type: S.Type) -> S {
        let key = ObjectIdentifier(type)

        guard let service = services[key] as? S else {
            fatalError("\(type) is not registered. You should register it beforehand.")
        }

        return service
    }

    func resetAll() {
        services = [:]
    }
}

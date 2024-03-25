//
//  Container.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

final class Container {
    private var resolvables: [ObjectIdentifier: Any]

    init() {
        resolvables = [:]
    }

    private init(resolvables: [ObjectIdentifier : Any]) {
        self.resolvables = resolvables
    }

    func register<R: Resolvable>(_ factory: () -> R) -> Container {
        let key = ObjectIdentifier(R.self)
        let resolvable = factory()

        resolvables[key] = resolvable

        return .init(resolvables: resolvables)
    }

    func resolve<R: Resolvable>(_ type: R.Type) -> R {
        let key = ObjectIdentifier(type)

        guard let resolvable = resolvables[key] as? R else {
            fatalError("\(type) is not registered. You should register it beforehand.")
        }

        return resolvable
    }

    func resetAll() {
        resolvables = [:]
    }
}

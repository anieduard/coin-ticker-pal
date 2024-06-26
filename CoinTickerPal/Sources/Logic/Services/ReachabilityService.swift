//
//  ReachabilityService.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 24.03.2024.
//

import Combine
import Network

// sourcery: AutoMockable
protocol ReachabilityServiceProtocol: Resolvable {
    var hasActiveNetwork: AnyPublisher<Bool, Never> { get }

    func startMonitoring()
    func stopMonitoring()
}

final class ReachabilityService: ReachabilityServiceProtocol {
    var hasActiveNetwork: AnyPublisher<Bool, Never> { $_hasActiveNetwork.eraseToAnyPublisher() }

    private let monitor: NWPathMonitor
    private let queue: DispatchQueue

    @Published
    private var _hasActiveNetwork = true

    init() {
        monitor = NWPathMonitor()
        queue = .global()

        monitor.pathUpdateHandler = { [self] path in
            switch path.status {
            case .satisfied:
                _hasActiveNetwork = true
            case .unsatisfied, .requiresConnection:
                _hasActiveNetwork = false
            @unknown default:
                _hasActiveNetwork = false
            }
        }
    }

    func startMonitoring() {
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
    }
}

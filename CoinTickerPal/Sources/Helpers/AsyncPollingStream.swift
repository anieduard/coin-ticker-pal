//
//  AsyncPollingStream.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 25.03.2024.
//

import Combine

class AsyncPollingStream<T> {
    private let pollingInterval: Duration
    private let pollingBlock: () async throws -> T

    init(pollingInterval: Duration = .seconds(5), pollingBlock: @escaping () async throws -> T) {
        self.pollingInterval = pollingInterval
        self.pollingBlock = pollingBlock
    }

    func start() -> AsyncStream<Result<T, Error>> {
        return AsyncStream<Result<T, Error>> { continuation in
            let task = Task {
                while !Task.isCancelled {
                    do {
                        let result = try await pollingBlock()
                        continuation.yield(.success(result))
                    } catch {
                        continuation.yield(.failure(error))
                    }

                    try? await Task.sleep(for: pollingInterval)
                }
                continuation.finish()
            }

            continuation.onTermination = { @Sendable _ in
                task.cancel()
            }
        }
    }
}

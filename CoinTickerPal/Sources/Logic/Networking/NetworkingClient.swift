//
//  NetworkingClient.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

protocol NetworkClientProtocol: AnyObject {
    var baseURL: URLComponents { get }

    func load(_ request: URLRequest) async throws -> Data
    func load<T: Decodable>(_ request: URLRequest) async throws -> T
}

final class NetworkClient: NetworkClientProtocol {
    private(set) lazy var baseURL: URLComponents = {
        var components = URLComponents()
        components.scheme = APIConstants.URL.scheme
        components.host = APIConstants.URL.host
        return components
    }()

    private let session: URLSession

    private lazy var jsonDecoder: JSONDecoder = {
        let jsonDecoder = JSONDecoder()
        return jsonDecoder
    }()

    init(session: URLSession = .shared) {
        self.session = session
    }

    func load(_ request: URLRequest) async throws -> Data {
        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else { throw NetworkError.invalidResponse }

        return data
    }

    func load<T: Decodable>(_ request: URLRequest) async throws -> T {
        let data = try await load(request)
        print(String(data: data, encoding: .utf8))
        return try jsonDecoder.decode(T.self, from: data)
    }
}

enum NetworkError: LocalizedError {
    case invalidResponse

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned invalid response."
        }
    }
}

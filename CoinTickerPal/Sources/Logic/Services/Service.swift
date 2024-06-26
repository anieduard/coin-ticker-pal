//
//  Service.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

protocol Resolvable { }

protocol Service: Resolvable { }

extension Service {
    private var baseURL: URLComponents {
        var components = URLComponents()
        components.scheme = APIConstants.URL.scheme
        components.host = APIConstants.URL.host
        return components
    }

    private func url(for path: APIConstants.Path, queryItems: [URLQueryItem]? = nil) -> URL {
        var components = baseURL
        components.path = path.rawValue
        components.queryItems = queryItems
        guard let url = components.url else { fatalError("The URL couldn't be formed from the specified components: \(components).") }
        return url
    }

    func request(for url: URL) -> URLRequest {
        URLRequest(url: url)
    }

    func request(for path: APIConstants.Path, queryItems: [URLQueryItem]? = nil) -> URLRequest {
        let url = url(for: path, queryItems: queryItems)
        return URLRequest(url: url)
    }
}

enum APIConstants {
    enum URL {
        static let scheme: String = "https"
        static let host: String   = "api-pub.bitfinex.com"
    }

    enum Path: String {
        case tickers = "/v2/tickers"
        case currencyLabel = "/v2/conf/pub:map:currency:label"
    }
}

extension URLQueryItem {
    static let symbols = URLQueryItem(
        name: "symbols",
        value: "tBTCUSD,tETHUSD,tBORG:USD,tLTCUSD,tXRPUSD,tDSHUSD,tRRTUSD,tEOSUSD,tDOGE:USD,tMATIC:USD,tNEXO:USD,tOCEAN:USD,tBEST:USD,tAAVE:USD,tPLUUSD,tFILUSD"
    )
}

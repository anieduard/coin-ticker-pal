//
//  Service.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import Foundation

protocol Service: AnyObject {
    var networkClient: NetworkClientProtocol { get }

    init(networkClient: NetworkClientProtocol)
}

extension Service {
    private func url(for path: APIConstants.Path, queryItems: [URLQueryItem]? = nil) -> URL {
        var components = networkClient.baseURL
        components.path = path.rawValue
        components.queryItems = queryItems
        guard let url = components.url else { fatalError("The URL couldn't be formed from the specified components: \(components).") }
        return url
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
        value: "tBTCUSD,tETHUSD,tCHSB:USD,tLTCUSD,tXRPUSD,tDSHUSD,tRRTUSD,tEOSUSD,tSANUSD,tDATUSD,tSNTUSD,tDOGE:USD,tLUNA:USD,tMATIC:USD,tNEXO:USD,tOCEAN:USD,tBEST:USD,tAAVE:USD,tPLUUSD,tFILUSD"
    )
}

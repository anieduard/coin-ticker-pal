// Generated using Sourcery 2.1.8 — https://github.com/krzysztofzablocki/Sourcery
// DO NOT EDIT

// swiftlint:disable line_length
// swiftlint:disable variable_name

import Foundation
#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif


@testable import CoinTickerPal






















class CoinsServiceProtocolMock: CoinsServiceProtocol {


    var coinsCallsCount = 0
    var coinsCalled: Bool {
        return coinsCallsCount > 0
    }

    var coins: [CoinsService.Response.Coin] {
        get async throws {
            coinsCallsCount += 1
            if let error = coinsThrowableError {
                throw error
            }
            if let coinsClosure = coinsClosure {
                return try await coinsClosure()
            } else {
                return underlyingCoins
            }
        }
    }
    var underlyingCoins: [CoinsService.Response.Coin]!
    var coinsThrowableError: Error?
    var coinsClosure: (() async throws -> [CoinsService.Response.Coin])?
    var currencyLabelsCallsCount = 0
    var currencyLabelsCalled: Bool {
        return currencyLabelsCallsCount > 0
    }

    var currencyLabels: [CoinsService.Response.CurrencyLabel] {
        get async throws {
            currencyLabelsCallsCount += 1
            if let error = currencyLabelsThrowableError {
                throw error
            }
            if let currencyLabelsClosure = currencyLabelsClosure {
                return try await currencyLabelsClosure()
            } else {
                return underlyingCurrencyLabels
            }
        }
    }
    var underlyingCurrencyLabels: [CoinsService.Response.CurrencyLabel]!
    var currencyLabelsThrowableError: Error?
    var currencyLabelsClosure: (() async throws -> [CoinsService.Response.CurrencyLabel])?



}

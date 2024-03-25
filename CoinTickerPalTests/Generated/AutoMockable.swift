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

import Combine

@testable import CoinTickerPal






















class CoinsListViewModelDelegateMock: CoinsListViewModelDelegate {




    //MARK: - didFailLoadingCoins

    var didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCallsCount = 0
    var didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCalled: Bool {
        return didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCallsCount > 0
    }
    var didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments: (error: Error, onRetry: Bool)?
    var didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedInvocations: [(error: Error, onRetry: Bool)] = []
    var didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidClosure: ((Error, Bool) -> Void)?

    func didFailLoadingCoins(with error: Error, onRetry: Bool) {
        didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCallsCount += 1
        didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments = (error: error, onRetry: onRetry)
        didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedInvocations.append((error: error, onRetry: onRetry))
        didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidClosure?(error, onRetry)
    }

    //MARK: - showNoInternetConnectionToast

    var showNoInternetConnectionToastVoidCallsCount = 0
    var showNoInternetConnectionToastVoidCalled: Bool {
        return showNoInternetConnectionToastVoidCallsCount > 0
    }
    var showNoInternetConnectionToastVoidClosure: (() -> Void)?

    func showNoInternetConnectionToast() {
        showNoInternetConnectionToastVoidCallsCount += 1
        showNoInternetConnectionToastVoidClosure?()
    }


}
class CoinsRepositoryProtocolMock: CoinsRepositoryProtocol {


    var coinsCallsCount = 0
    var coinsCalled: Bool {
        return coinsCallsCount > 0
    }

    var coins: [Coin] {
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
    var underlyingCoins: [Coin]!
    var coinsThrowableError: Error?
    var coinsClosure: (() async throws -> [Coin])?



}
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
class ImageServiceProtocolMock: ImageServiceProtocol {




    //MARK: - image

    var imageForUrlURLUIImageThrowableError: (any Error)?
    var imageForUrlURLUIImageCallsCount = 0
    var imageForUrlURLUIImageCalled: Bool {
        return imageForUrlURLUIImageCallsCount > 0
    }
    var imageForUrlURLUIImageReceivedUrl: (URL)?
    var imageForUrlURLUIImageReceivedInvocations: [(URL)] = []
    var imageForUrlURLUIImageReturnValue: UIImage?
    var imageForUrlURLUIImageClosure: ((URL) async throws -> UIImage?)?

    func image(for url: URL) async throws -> UIImage? {
        imageForUrlURLUIImageCallsCount += 1
        imageForUrlURLUIImageReceivedUrl = url
        imageForUrlURLUIImageReceivedInvocations.append(url)
        if let error = imageForUrlURLUIImageThrowableError {
            throw error
        }
        if let imageForUrlURLUIImageClosure = imageForUrlURLUIImageClosure {
            return try await imageForUrlURLUIImageClosure(url)
        } else {
            return imageForUrlURLUIImageReturnValue
        }
    }


}
class ReachabilityServiceProtocolMock: ReachabilityServiceProtocol {


    var hasActiveNetwork: AnyPublisher<Bool, Never> {
        get { return underlyingHasActiveNetwork }
        set(value) { underlyingHasActiveNetwork = value }
    }
    var underlyingHasActiveNetwork: (AnyPublisher<Bool, Never>)!


    //MARK: - startMonitoring

    var startMonitoringVoidCallsCount = 0
    var startMonitoringVoidCalled: Bool {
        return startMonitoringVoidCallsCount > 0
    }
    var startMonitoringVoidClosure: (() -> Void)?

    func startMonitoring() {
        startMonitoringVoidCallsCount += 1
        startMonitoringVoidClosure?()
    }

    //MARK: - stopMonitoring

    var stopMonitoringVoidCallsCount = 0
    var stopMonitoringVoidCalled: Bool {
        return stopMonitoringVoidCallsCount > 0
    }
    var stopMonitoringVoidClosure: (() -> Void)?

    func stopMonitoring() {
        stopMonitoringVoidCallsCount += 1
        stopMonitoringVoidClosure?()
    }


}

//
//  CoinsListViewModelTests.swift
//  CoinTickerPalTests
//
//  Created by Eduard Ani on 25.03.2024.
//

import Combine
import XCTest
@testable import CoinTickerPal

final class CoinsListViewModelTests: XCTestCase {
    var coinsRepository: CoinsRepositoryProtocolMock!
    var imageService: ImageServiceProtocolMock!
    var reachabilityService: ReachabilityServiceProtocolMock!
    var delegate: CoinsListViewModelDelegateMock!
    var sut: CoinsListViewModel!

    @Published
    var hasActiveNetwork = true

    @MainActor
    override func setUpWithError() throws {
        try super.setUpWithError()

        coinsRepository = CoinsRepositoryProtocolMock()

        imageService = ImageServiceProtocolMock()

        reachabilityService = ReachabilityServiceProtocolMock()
        reachabilityService.underlyingHasActiveNetwork = $hasActiveNetwork.eraseToAnyPublisher()

        delegate = CoinsListViewModelDelegateMock()

        sut = CoinsListViewModel(coinsRepository: coinsRepository, imageService: imageService, reachabilityService: reachabilityService, delegate: delegate)
    }

    @MainActor
    func testCreatesShimmeringDataSource() {
        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, (0..<15).map { .loading($0) })
    }

    func testCallsStartMonitoring() {
        XCTAssertTrue(reachabilityService.startMonitoringVoidCalled)
    }

    @MainActor
    func testCallsDelegateOnNoInternetConnection() {
        hasActiveNetwork = false

        let expectation = XCTestExpectation(description: "Delegate method called")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [self] in
            XCTAssertTrue(delegate.showNoInternetConnectionToastVoidCalled)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoadCoinsSucceeds() async throws {
        let coins = [
            Coin(name: "Bitcoin", symbol: "BTC", price: 66999.0, priceChange: 0.02815972, earnYield: false),
            Coin(name: "Ethereum", symbol: "ETH", price: 3451.5, priceChange: 0.0205198, earnYield: false),
            Coin(name: "OCEAN protocol", symbol: "OCEAN", price: 1.1334, priceChange: 0.06452522, earnYield: true)
        ]
        coinsRepository.underlyingCoins = coins

        // loading for the first time
        try await sut.loadCoins()

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.map { .coin($0) })

        // pull to refresh succeeds
        try await sut.loadCoins()

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.map { .coin($0) })

        // pull to refresh fails
        coinsRepository.coinsThrowableError = AnyError.just

        try? await sut.loadCoins()

        XCTAssertTrue(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCalled)
        XCTAssertEqual(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments?.error as? AnyError, AnyError.just)
        XCTAssertEqual(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments?.onRetry, true)
    }

    @MainActor
    func testLoadCoinsFails() async {
        coinsRepository.coinsThrowableError = AnyError.just

        // loading for the first time
        try? await sut.loadCoins()

        XCTAssertTrue(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidCalled)
        XCTAssertEqual(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments?.error as? AnyError, AnyError.just)
        XCTAssertEqual(delegate.didFailLoadingCoinsWithErrorErrorOnRetryBoolVoidReceivedArguments?.onRetry, false)
    }

    func testLoadImageSucceeds() async {
        let expectedImage = UIImage()
        imageService.imageForUrlURLUIImageReturnValue = expectedImage

        let image = await sut.loadImage(for: URL(string: "www.google.com")!)

        XCTAssertEqual(image, expectedImage)
    }

    func testLoadImageFails() async {
        imageService.imageForUrlURLUIImageThrowableError = AnyError.just

        let image = await sut.loadImage(for: URL(string: "www.google.com")!)

        XCTAssertEqual(image, nil)
    }

    @MainActor
    func testPolling() async throws {
        var coins = [
            Coin(name: "Bitcoin", symbol: "BTC", price: 66999.0, priceChange: 0.02815972, earnYield: false),
            Coin(name: "Ethereum", symbol: "ETH", price: 3451.5, priceChange: 0.0205198, earnYield: false),
            Coin(name: "OCEAN protocol", symbol: "OCEAN", price: 1.1334, priceChange: 0.06452522, earnYield: true)
        ]
        coinsRepository.underlyingCoins = coins

        // loading for the first time
        try await sut.loadCoins()

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.map { .coin($0) })

        // polling
        coins = [
            Coin(name: "Bitcoin", symbol: "BTC", price: 67999.0, priceChange: 0.03815972, earnYield: false),
            Coin(name: "Ethereum", symbol: "ETH", price: 3551.5, priceChange: 0.0305198, earnYield: false),
            Coin(name: "OCEAN protocol", symbol: "OCEAN", price: 1.2334, priceChange: 0.07452522, earnYield: true)
        ]
        coinsRepository.underlyingCoins = coins

        _ = sut.startPolling()

        // make AsyncPollingStream injectable so we don't make the test wait for 5 seconds
        try? await Task.sleep(for: .seconds(5))

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.map { .coin($0) })
    }

    @MainActor
    func testSearch() async throws {
        let coins = [
            Coin(name: "Bitcoin", symbol: "BTC", price: 66999.0, priceChange: 0.02815972, earnYield: false),
            Coin(name: "Ethereum", symbol: "ETH", price: 3451.5, priceChange: 0.0205198, earnYield: false),
            Coin(name: "OCEAN protocol", symbol: "OCEAN", price: 1.1334, priceChange: 0.06452522, earnYield: true)
        ]
        coinsRepository.underlyingCoins = coins

        // loading for the first time
        try await sut.loadCoins()

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.map { .coin($0) })

        var result = sut.searchCoins(text: "BTC")

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.prefix(1).map { .coin($0) })
        XCTAssertTrue(result)

        // searching the same item doesn't trigger reload
        result = sut.searchCoins(text: "BTC")

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertEqual(sut.dataSourceSnapshot.itemIdentifiers, coins.prefix(1).map { .coin($0) })
        XCTAssertFalse(result)

        // no results
        result = sut.searchCoins(text: "BORG")

        XCTAssertEqual(sut.dataSourceSnapshot.sectionIdentifiers, [.coins])
        XCTAssertTrue(sut.dataSourceSnapshot.itemIdentifiers.isEmpty)
        XCTAssertTrue(result)
    }
}

private enum AnyError: Error {
    case just
}

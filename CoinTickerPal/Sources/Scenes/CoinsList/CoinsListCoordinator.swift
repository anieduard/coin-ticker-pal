//
//  CoinsListCoordinator.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class CoinsListCoordinator: UIViewController {
    private enum State {
        case coins
        case error(Error)
    }

    private let coinsRepository: CoinsRepositoryProtocol
    private let imageService: ImageServiceProtocol
    private let reachabilityService: ReachabilityServiceProtocol

    private var state: State? {
        didSet {
            let rootViewController: UIViewController

            switch (oldValue, state) {
            case (.none, .coins), (.error, .coins):
                let viewModel = CoinsListViewModel(coinsRepository: coinsRepository, imageService: imageService, reachabilityService: reachabilityService, delegate: self)
                rootViewController = CoinsListViewController(viewModel: viewModel)
            case (.coins, .error):
                rootViewController = CoinsListErrorViewController(delegate: self)
            default:
                fatalError("Unexpected state change, oldValue: \(String(describing: oldValue)), newValue: \(String(describing: state))")
            }

            let navigationController = UINavigationController(rootViewController: rootViewController)
            self.rootViewController = navigationController
        }
    }

    private var rootViewController: UIViewController! {
        didSet {
            oldValue?.willMove(toParent: nil)
            oldValue?.view.removeFromSuperview()
            oldValue?.removeFromParent()

            addChild(rootViewController)
            rootViewController.view.frame = view.frame
            view.addSubview(rootViewController.view)
            rootViewController.didMove(toParent: self)
        }
    }

    init(coinsRepository: CoinsRepositoryProtocol, imageService: ImageServiceProtocol, reachabilityService: ReachabilityServiceProtocol) {
        self.coinsRepository = coinsRepository
        self.imageService = imageService
        self.reachabilityService = reachabilityService
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        state = .coins
    }
}

// MARK: - CoinsListViewModelDelegate

extension CoinsListCoordinator: CoinsListViewModelDelegate {
    func didFailLoadingCoins(with error: Error, onRetry: Bool) {
        if onRetry {
            Toast.presentError("There was an error when trying to refresh.")
        } else {
            state = .error(error)
        }
    }

    func showNoInternetConnectionToast() {
        Toast.presentError("No internet connection available. Please connect to the internet.")
    }
}

// MARK: - CoinsListErrorViewControllerDelegate

extension CoinsListCoordinator: CoinsListErrorViewControllerDelegate {
    func didTapRetry() {
        state = .coins
    }
}

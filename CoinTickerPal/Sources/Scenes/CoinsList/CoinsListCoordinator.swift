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

    private var state: State? {
        didSet {
            let rootViewController: UIViewController

            switch (oldValue, state) {
            case (.none, .coins), (.error, .coins):
                let viewModel = CoinsListViewModel(delegate: self)
                rootViewController = CoinsListViewController(viewModel: viewModel)
            case (.coins, .error):
                rootViewController = .init()
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

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        state = .coins
    }
}

// MARK: - CoinsListViewModelDelegate

extension CoinsListCoordinator: CoinsListViewModelDelegate {
    func didFailLoadingCoins(with error: Error) {
        state = .error(error)
    }
}

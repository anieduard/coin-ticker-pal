//
//  CoinsListViewController.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class CoinsListViewController: UIViewController {
    private let viewModel: CoinsListViewModelProtocol

    private lazy var tableView = UITableView()

    private lazy var dataSource: UITableViewDiffableDataSource<CoinsListViewModel.Section, CoinsListViewModel.Section.Item> = {
        let dataSource = UITableViewDiffableDataSource<CoinsListViewModel.Section, CoinsListViewModel.Section.Item>(tableView: tableView) { tableView, indexPath, item in
            switch item {
            case .loading:
                let cell: ShimmerTableViewCell = tableView.dequeueReusableCell(for: indexPath)
                return cell
            case .coin(let coin):
                let cell: CoinTableViewCell = tableView.dequeueReusableCell(for: indexPath)

                let task = Task<UIImage?, Never> {
//                    if Bool.random() { return nil }
//                    try? await Task.sleep(nanoseconds: UInt64(Int.random(in: 0...3) * 1_000_000_000))
                    return await self.viewModel.loadImage(for: URL(string: "https://assets.coingecko.com/coins/images/1/small/bitcoin.png?1696501400")!)
                }

                cell.reuseClosure = {
                    task.cancel()
                }

                cell.item = .from(
                    coin,
                    image: { await task.value },
                    earnYield: Bool.random()
                )

                return cell
            }
        }

        dataSource.defaultRowAnimation = .fade

        return dataSource
    }()

    init(viewModel: CoinsListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        title = "Coin Tickers"
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = tableView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        initView()

        // Apply data source with loading cells.
        dataSource.apply(viewModel.dataSourceSnapshot)

        // Refresh data with coin cells.
        Task {
            do {
                tableView.isScrollEnabled = false
                try await viewModel.loadCoins()
                tableView.isScrollEnabled = true

                dataSource.apply(viewModel.dataSourceSnapshot, completion: nil)
            }
        }
    }

    private func initView() {
        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.refreshControl = {
            let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
            return refreshControl
        }()
        tableView.register(ShimmerTableViewCell.self)
        tableView.register(CoinTableViewCell.self)
    }

    @objc private func refreshControlValueChanged() {
        Task {
            do {
                try await viewModel.loadCoins()

                tableView.refreshControl?.endRefreshing()
                dataSource.apply(viewModel.dataSourceSnapshot, completion: nil)
            }
        }
    }
}

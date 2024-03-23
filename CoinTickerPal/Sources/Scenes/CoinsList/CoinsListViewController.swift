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
                
                cell.item = .init(
                    image: .init(),
                    name: "Tether USD",
                    price: "USDT",
                    earnYield: Bool.random(),
                    symbol: "$0.8615",
                    priceChange: .higher("+4.55%")
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
        tableView.separatorStyle = .none
        tableView.register(ShimmerTableViewCell.self)
        tableView.register(CoinTableViewCell.self)
    }
}

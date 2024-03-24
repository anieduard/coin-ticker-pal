//
//  CoinsListViewController.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class CoinsListViewController: UIViewController {
    enum RefreshControl {
        case active, none
    }

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

    private lazy var searchController = UISearchController()

    private var refreshControl: RefreshControl = .none {
        didSet {
            tableView.refreshControl?.endRefreshing()

            switch refreshControl {
            case .active:
                tableView.refreshControl = {
                    let refreshControl = UIRefreshControl()
                    refreshControl.addTarget(self, action: #selector(refreshControlValueChanged), for: .valueChanged)
                    return refreshControl
                }()
            case .none:
                tableView.refreshControl = nil
            }
        }
    }

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
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .automatic

        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Coins"

        tableView.backgroundColor = .systemGroupedBackground
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.keyboardDismissMode = .interactive
        tableView.register(ShimmerTableViewCell.self)
        tableView.register(CoinTableViewCell.self)

        refreshControl = .active

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func refreshControlValueChanged() {
        Task {
            do {
                try await viewModel.loadCoins()

                tableView.refreshControl?.endRefreshing()
                dataSource.apply(viewModel.dataSourceSnapshot, completion: nil)
            } catch {
                tableView.refreshControl?.endRefreshing()
            }
        }
    }

    @objc private func keyboardWillShow(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }

        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)

        tableView.contentInset.bottom = keyboardViewEndFrame.height - view.safeAreaInsets.bottom
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

    @objc private func keyboardWillHide(notification: Notification) {
        tableView.contentInset = .zero
        tableView.scrollIndicatorInsets = tableView.contentInset
    }
}

// MARK: - UISearchResultsUpdating

extension CoinsListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        refreshControl = searchController.isActive ? .none : .active

        viewModel.searchCoins(text: searchController.searchBar.text)

        dataSource.apply(viewModel.dataSourceSnapshot, completion: nil)
    }
}

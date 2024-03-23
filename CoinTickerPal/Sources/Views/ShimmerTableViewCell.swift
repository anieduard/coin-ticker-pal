//
//  ShimmerTableViewCell.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class ShimmerTableViewCell: UITableViewCell {
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    private lazy var circleShimmerView: ShimmerView = {
        let shimmerView = ShimmerView()
        shimmerView.backgroundColor = .systemGray3
        return shimmerView
    }()

    private lazy var detailStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 16
        return stackView
    }()

    private lazy var topShimmerView: ShimmerView = {
        let shimmerView = ShimmerView()
        shimmerView.backgroundColor = .systemGray3
        return shimmerView
    }()

    private lazy var bottomShimmerView: ShimmerView = {
        let shimmerView = ShimmerView()
        shimmerView.backgroundColor = .systemGray3
        return shimmerView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        selectionStyle = .none

        contentView.addSubview(stackView)

        stackView.addArrangedSubview(circleShimmerView)
        stackView.addArrangedSubview(detailStackView)

        detailStackView.addArrangedSubview(topShimmerView)
        detailStackView.addArrangedSubview(bottomShimmerView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            circleShimmerView.widthAnchor.constraint(equalToConstant: 40),
            circleShimmerView.heightAnchor.constraint(equalToConstant: 40),

            topShimmerView.widthAnchor.constraint(equalTo: detailStackView.widthAnchor, multiplier: 0.5),
            topShimmerView.heightAnchor.constraint(equalToConstant: 8),

            bottomShimmerView.widthAnchor.constraint(equalTo: detailStackView.widthAnchor),
            bottomShimmerView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }
}

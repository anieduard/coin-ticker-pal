//
//  ShimmerTableViewCell.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class ShimmerTableViewCell: UITableViewCell {
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 8
        view.layer.shadowOpacity = 0.15
        view.layer.shadowRadius = 4
        view.layer.shadowOffset = .zero
        view.layer.shadowColor = UIColor.black.cgColor
        return view
    }()

    private lazy var containerStackView: UIStackView = {
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
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)

        containerView.addSubview(containerStackView)

        containerStackView.addArrangedSubview(circleShimmerView)
        containerStackView.addArrangedSubview(detailStackView)

        detailStackView.addArrangedSubview(topShimmerView)
        detailStackView.addArrangedSubview(bottomShimmerView)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            circleShimmerView.widthAnchor.constraint(equalToConstant: .circleSize),
            circleShimmerView.heightAnchor.constraint(equalToConstant: .circleSize),

            topShimmerView.widthAnchor.constraint(equalTo: detailStackView.widthAnchor, multiplier: 0.5),
            topShimmerView.heightAnchor.constraint(equalToConstant: 8),

            bottomShimmerView.widthAnchor.constraint(equalTo: detailStackView.widthAnchor),
            bottomShimmerView.heightAnchor.constraint(equalToConstant: 8)
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        circleShimmerView.layer.masksToBounds = true
        circleShimmerView.layer.cornerRadius = circleShimmerView.frame.size.height / 2
    }
}

private extension CGFloat {
    static let circleSize: CGFloat = 40
}

//
//  CoinTableViewCell.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

final class CoinTableViewCell: UITableViewCell {
    var item: Item? {
        didSet {
            imageTask = Task {
                let image = await item?.image()

                // Resize images so we don't get huge image sizes that would affect scrolling performance.
                avatarImageView.image = image?.resize(to: CGSize(width: .imageSize, height: .imageSize))

                earnYiedLabel.backgroundColor = image?.dominantColor
            }

            nameLabel.text = item?.name
            priceLabel.text = item?.price

            earnYiedLabel.isHidden = !(item?.earnYield ?? false)
            symbolLabel.text = item?.symbol

            priceChangeLabel.text = item?.priceChange.value
            priceChangeLabel.textColor = item?.priceChange.color
        }
    }

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

    private lazy var avatarImageView: ShimmerImageView = {
        let imageView = ShimmerImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var detailsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 4
        return stackView
    }()

    private lazy var topStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        return label
    }()

    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        return label
    }()

    private lazy var bottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        return stackView
    }()

    private lazy var symbolStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    private lazy var earnYiedLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.text = "EARN YIELD"
        label.textColor = .systemBackground
        label.font = .systemFont(ofSize: UIFont.smallSystemFontSize)
        label.layer.cornerRadius = 4
        label.layer.masksToBounds = true
        label.insets = UIEdgeInsets(horizontal: 4, vertical: 2)
        return label
    }()

    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        return label
    }()

    private lazy var priceChangeLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        return label
    }()

    private var imageTask: Task<Void, Never>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initView()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(containerView)

        containerView.addSubview(containerStackView)

        containerStackView.addArrangedSubview(avatarImageView)
        containerStackView.addArrangedSubview(detailsStackView)

        detailsStackView.addArrangedSubview(topStackView)

        topStackView.addArrangedSubview(nameLabel)
        topStackView.addArrangedSubview(.empty)
        topStackView.addArrangedSubview(priceLabel)

        detailsStackView.addArrangedSubview(bottomStackView)

        bottomStackView.addArrangedSubview(symbolStackView)

        symbolStackView.addArrangedSubview(earnYiedLabel)
        symbolStackView.addArrangedSubview(symbolLabel)

        bottomStackView.addArrangedSubview(.empty)
        bottomStackView.addArrangedSubview(priceChangeLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),

            containerStackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            containerStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            containerStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            containerStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),

            avatarImageView.widthAnchor.constraint(equalToConstant: .imageSize),
            avatarImageView.heightAnchor.constraint(equalToConstant: .imageSize)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        avatarImageView.layer.masksToBounds = true
        avatarImageView.layer.cornerRadius = avatarImageView.frame.size.height / 2
    }
}

extension CoinTableViewCell {
    struct Item {
        struct PriceChange {
            let value: String
            let color: UIColor

            init(value: Double) {
                self.value = value.formatted(.percent.sign(strategy: .always(includingZero: false)).precision(.fractionLength(2)))

                if value > 0 {
                    self.color = .systemGreen
                } else if value < 0 {
                    self.color = .systemRed
                } else {
                    self.color = .systemGray
                }
            }
        }

        let image: () async -> UIImage?
        let name: String
        let price: String
        let earnYield: Bool
        let symbol: String
        let priceChange: PriceChange

        static func from(_ coin: Coin, image: @escaping () async -> UIImage?) -> Self {
            let price = coin.price.formatted(.currency(code: "USD").presentation(.narrow))
            let priceChange = PriceChange(value: coin.priceChange)

            return Self(
                image: image,
                name: coin.name,
                price: price,
                earnYield: coin.earnYield,
                symbol: coin.symbol,
                priceChange: priceChange
            )
        }
    }
}

private extension CGFloat {
    static let imageSize: CGFloat = 40
}

private extension UIImage {
    func resize(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}

//
//  CoinsListErrorViewController.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 25.03.2024.
//

import UIKit

protocol CoinsListErrorViewControllerDelegate: AnyObject {
    func didTapRetry()
}

final class CoinsListErrorViewController: UIViewController {
    private unowned let delegate: CoinsListErrorViewControllerDelegate

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 24
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 48, left: 32, bottom: 48, right: 32)
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "illustration_error.png"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Something went wrong..."
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: UIFont.labelFontSize)
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = "Please try again later."
        label.textColor = .secondaryLabel
        label.font = .systemFont(ofSize: UIFont.systemFontSize)
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .boldSystemFont(ofSize: UIFont.buttonFontSize)
        button.setTitle("Retry", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(retryButtonTouched), for: .touchUpInside)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 2
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 24
        return button
    }()

    init(delegate: CoinsListErrorViewControllerDelegate) {
        self.delegate = delegate
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = stackView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }

    private func initView() {
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        let spacerView = UIView()
        stackView.addArrangedSubview(spacerView)

        stackView.addArrangedSubview(retryButton)

        stackView.setCustomSpacing(8, after: titleLabel)

        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),

            retryButton.widthAnchor.constraint(equalTo: stackView.widthAnchor, constant: -64),
            retryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func retryButtonTouched() {
        delegate.didTapRetry()
    }
}

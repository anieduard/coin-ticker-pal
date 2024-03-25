//
//  ShimmerImageView.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 24.03.2024.
//

import UIKit

final class ShimmerImageView: UIImageView {
    override var image: UIImage? {
        didSet {
            backgroundColor = image == nil ? .systemGray3 : .clear
            shimmerView.removeFromSuperview()
        }
    }

    private lazy var shimmerView: ShimmerView = {
        let shimmerView = ShimmerView()
        shimmerView.translatesAutoresizingMaskIntoConstraints = false
        shimmerView.backgroundColor = .systemGray3
        return shimmerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        initView(hasImage: false)
    }

    override init(image: UIImage?) {
        super.init(image: image)
        initView(hasImage: image != nil)
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        initView(hasImage: image != nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView(hasImage: Bool) {
        guard !hasImage else { return }

        addSubview(shimmerView)

        NSLayoutConstraint.activate([
            shimmerView.topAnchor.constraint(equalTo: topAnchor),
            shimmerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            shimmerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            shimmerView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
}

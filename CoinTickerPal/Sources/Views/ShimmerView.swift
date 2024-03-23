//
//  ShimmerView.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import Combine
import UIKit

final class ShimmerView: UIView {
    private static let now = CACurrentMediaTime()
    private let animationMask = CALayer()
    private var cancellables: Set<AnyCancellable> = []

    override public init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.startAnimation()
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.stopAnimation()
            }
            .store(in: &cancellables)
    }

    private func startAnimation() {
        guard window != nil else { return }

        animationMask.removeAnimation(forKey: "pulse")

        let startColor = UIColor.systemGray.withAlphaComponent(1).cgColor
        let endColor = UIColor.systemGray.withAlphaComponent(0.5).cgColor

        animationMask.backgroundColor = startColor
        layer.mask = animationMask
        animationMask.frame = layer.bounds

        let animation = CABasicAnimation(keyPath: "backgroundColor")
        animation.fromValue = [startColor]
        animation.toValue = [endColor]
        animation.duration = 1
        animation.repeatCount = .infinity
        animation.autoreverses = true
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.beginTime = Self.now
        animationMask.add(animation, forKey: "pulse")
    }

    private func stopAnimation() {
        animationMask.removeAnimation(forKey: "pulse")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        // Adjust mask frame if needed.
        startAnimation()

        layer.masksToBounds = true
        layer.cornerRadius = frame.size.height / 2
    }

    override public func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            stopAnimation()
        } else {
            startAnimation()
        }
    }
}

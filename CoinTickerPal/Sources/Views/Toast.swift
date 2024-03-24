//
//  Toast.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 24.03.2024.
//

import UIKit

private final class ToastView: UIView {
    enum Style {
        case error(message: String)

        var icon: UIImage {
            switch self {
            case .error:
                return #imageLiteral(resourceName: "icon_exclamation.png")
            }
        }

        var message: String {
            switch self {
            case .error(let message):
                return message
            }
        }
    }

    weak var topConstraint: NSLayoutConstraint?

    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .tertiarySystemGroupedBackground
        return view
    }()

    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 16
        return stackView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .boldSystemFont(ofSize: UIFont.systemFontSize)
        return label
    }()

    init(style: Style) {
        super.init(frame: .zero)
        
        initView()

        imageView.image = style.icon
        label.text = style.message
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func initView() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.25
        layer.shadowRadius = 4

        addSubview(containerView)
        containerView.addSubview(stackView)

        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(label)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(lessThanOrEqualTo: containerView.trailingAnchor, constant: -16),

            imageView.widthAnchor.constraint(equalToConstant: 24),
            imageView.heightAnchor.constraint(equalToConstant: 24)
        ])

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        addGestureRecognizer(tapGestureRecognizer)
    }

    @objc private func tapGestureHandler(_ sender: UITapGestureRecognizer) {
        dismiss()
    }

    func dismiss() {
        UIView.animate(withDuration: .animationDuration, animations: { [self] in
            transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            alpha = 0
        }, completion: { [self] _ in
            removeFromSuperview()
        })
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = containerView.frame.height / 2
    }
}

private extension UIView {
    func presentErrorToast(_ message: String) {
        let toast = ToastView(style: .error(message: message))
        presentToast(toast, animated: true, completion: nil)
    }

    func presentToast(_ toast: ToastView, animated: Bool, completion: ((Bool) -> Void)?) {
        toast.translatesAutoresizingMaskIntoConstraints = false
        addSubview(toast)

        for view in subviews {
            guard view is ToastView, view != toast else { continue }
            toast.topAnchor.constraint(greaterThanOrEqualTo: view.bottomAnchor, constant: 8).isActive = true
        }

        let topConstraint = toast.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor)
        toast.topConstraint = topConstraint
        NSLayoutConstraint.activate([
            topConstraint,
            toast.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            toast.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])

        toast.alpha = 0

        UIView.animate(withDuration: .animationDuration, animations: {
            toast.alpha = 1
        }, completion: completion)

        DispatchQueue.main.asyncAfter(deadline: .now() + .duration, execute: toast.dismiss)

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        toast.addGestureRecognizer(panGestureRecognizer)
    }

    @objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let toastView = gestureRecognizer.view as? ToastView else {
            return
        }

        let translation = gestureRecognizer.translation(in: toastView.superview)
        let velocity = gestureRecognizer.velocity(in: toastView.superview)

        func verticallyOffset(toastView: ToastView, offset: CGFloat) {
            UIView.animate(withDuration: 0.1) { [weak toastView] in
                toastView?.topConstraint?.constant = offset
                toastView?.superview?.layoutIfNeeded()
            }
        }

        switch gestureRecognizer.state {
        case .cancelled:
            verticallyOffset(toastView: toastView, offset: 0)
        case .ended:
            if translation.y < 0 && (abs(translation.y) > (toastView.bounds.height / 2) || velocity.y < -100) {
                verticallyOffset(toastView: toastView, offset: -1000)
                toastView.dismiss()
            } else {
                verticallyOffset(toastView: toastView, offset: 0)
            }
        default:
            let smoothTranslation: CGFloat
            if translation.y < 0 {
                smoothTranslation = translation.y
            } else {
                smoothTranslation = pow(translation.y, 0.8)
            }

            toastView.topConstraint?.constant = smoothTranslation
        }
    }
}

@MainActor
public enum Toast {
    private static let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
    private static let window = windowScene?.keyWindow

    public static func presentError(_ message: String) {
        guard !message.isEmpty else { return }
        window?.presentErrorToast(message)
    }
}

private extension TimeInterval {
    static let duration: TimeInterval = 3
    static let animationDuration: TimeInterval = 0.33
}

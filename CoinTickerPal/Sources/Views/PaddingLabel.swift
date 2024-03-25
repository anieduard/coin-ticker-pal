//
//  PaddingLabel.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import UIKit

final class PaddingLabel: UILabel {
    var insets: UIEdgeInsets = .zero {
        didSet { invalidateIntrinsicContentSize() }
    }

    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: insets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        return textRect.inset(by: insets * -1)
    }

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
}

//
//  UIEdgeInsets+Extension.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 23.03.2024.
//

import UIKit

extension UIEdgeInsets {
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
    }

    static func all(_ value: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: value, left: value, bottom: value, right: value)
    }

    static func * (lhs: UIEdgeInsets, rhs: CGFloat) -> UIEdgeInsets {
        UIEdgeInsets(top: lhs.top * rhs, left: lhs.left * rhs, bottom: lhs.bottom * rhs, right: lhs.right * rhs)
    }

    static func * (lhs: CGFloat, rhs: UIEdgeInsets) -> UIEdgeInsets {
        UIEdgeInsets(top: lhs * rhs.top, left: lhs * rhs.left, bottom: lhs * rhs.bottom, right: lhs * rhs.right)
    }
}

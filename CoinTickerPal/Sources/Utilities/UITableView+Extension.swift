//
//  UITableView+Extension.swift
//  CoinTickerPal
//
//  Created by Eduard Ani on 21.03.2024.
//

import UIKit

extension UITableViewCell {
    static var reuseIdentifier: String { String(describing: self) }

    var reuseIdentifier: String { type(of: self).reuseIdentifier }
}

extension UITableView {
    func register<T: UITableViewCell>(_ type: T.Type) {
        register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UITableViewCell>(for indexPath: IndexPath) -> T {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

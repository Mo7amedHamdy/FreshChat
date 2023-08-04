//
//  UIView+PinnedSubView.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 05/01/2023.
//

import UIKit

extension UIView {
    func addPinnedSubView(_ subview: UIView, height: CGFloat? = nil, insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        subview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        subview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left).isActive = true
        subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -1 * insets.right).isActive = true
        if let height = height {
            subview.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
}

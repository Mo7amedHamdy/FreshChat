//
//  CustomFooter.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 15/01/2023.
//

import UIKit

class CustomHeader: UITableViewHeaderFooterView {
    
    var dateLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents() {
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(dateLabel)
        NSLayoutConstraint.activate([
            dateLabel.centerXAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerXAnchor),
            dateLabel.centerYAnchor.constraint(equalTo: contentView.layoutMarginsGuide.centerYAnchor),
            dateLabel.widthAnchor.constraint(equalToConstant: 105),
            dateLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
        dateLabel.layer.cornerRadius = 9
        dateLabel.layer.masksToBounds = true
        dateLabel.backgroundColor = #colorLiteral(red: 1, green: 0.9369981885, blue: 0.8543820977, alpha: 1)
        dateLabel.textAlignment = .center
        dateLabel.sizeToFit()
        dateLabel.textColor = #colorLiteral(red: 0.2266764641, green: 0.229804337, blue: 0.2378562987, alpha: 1)
        dateLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
    }
}

//
//  CustomToolBar.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 16/03/2023.
//

import UIKit

protocol ToolBarButtons {
    func didPressDelete(_ isPressed: Bool)
}

class CustomDeleteToolbar: UIToolbar {
    var toolBarButtonDelegate: ToolBarButtons?
    
    var selectedRowscountLabel = UILabel()
    var selectedStringLabel = UILabel()
    var deleteButton = UIBarButtonItem()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        //configura items
        deleteButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(activateDeleteButton))
        setItems([deleteButton], animated: true)
//        deleteButton.tintColor = .systemRed
        
        configureToolBarCustomViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //configure tool bar custom views
    func configureToolBarCustomViews() {
        //appearance for toolbar
        let appearance = UIToolbarAppearance()
        appearance.backgroundColor = #colorLiteral(red: 1, green: 0.8904700875, blue: 0.8717817664, alpha: 1)
        standardAppearance = appearance
        
        //selected string label setup
        selectedStringLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectedStringLabel)
        selectedStringLabel.text = "Selected"
        selectedStringLabel.textColor = .black
        selectedStringLabel.textAlignment = .center
        selectedStringLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        selectedStringLabel.sizeToFit()
        
        //selected rows count label setup
        selectedRowscountLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(selectedRowscountLabel)
        selectedRowscountLabel.text = "0"
        selectedRowscountLabel.textColor = .black
        selectedRowscountLabel.textAlignment = .center
        selectedRowscountLabel.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        selectedRowscountLabel.sizeToFit()
        
        //constrains for labels
        NSLayoutConstraint.activate([
            selectedStringLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            selectedStringLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            selectedRowscountLabel.trailingAnchor.constraint(equalTo: selectedStringLabel.leadingAnchor, constant: -5),
            selectedRowscountLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        
    }
    
    //did press delete button
    @objc func activateDeleteButton() {
        toolBarButtonDelegate?.didPressDelete(true)
        print("did press delete button 999999999222222222222")
    }
}

//
//  ProfileNameEditTableViewCell.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 30/06/2023.
//

import UIKit

class ProfileNameEditTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameTextField: UITextField!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        nameTextField.placeholder = "enter your name"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

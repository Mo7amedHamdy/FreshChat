//
//  ProfilePicEditTableViewCell.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 30/06/2023.
//

import UIKit

class ProfilePicEditTableViewCell: UITableViewCell {

    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    var onPressEdit: (Bool)->() = { _ in }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        profilePic.layer.cornerRadius = 40
        
        editButton.addTarget(self, action: #selector(editPressed), for: .touchUpInside)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func editPressed() {
        onPressEdit(true)
    }

}

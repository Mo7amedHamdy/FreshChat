//
//  NavbarCustomItem.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 25/10/2022.
//

import UIKit

class NavbarCustomItem: UIView {
   
    @IBOutlet weak var otherUserProfileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        otherUserProfileImageView.layer.cornerRadius = 20
        otherUserProfileImageView.layer.masksToBounds = true
        otherUserProfileImageView.layer.borderWidth = 1
        otherUserProfileImageView.layer.borderColor = UIColor.red.cgColor
    }
}

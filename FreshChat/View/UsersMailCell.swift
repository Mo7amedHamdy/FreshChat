//
//  UsersMailCell.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 31/10/2022.
//

import UIKit

class UsersMailcell: UITableViewCell {
    
    @IBOutlet weak var userProfilePicture: UIImageView!
    @IBOutlet weak var userName: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userProfilePicture.layer.cornerRadius = 25
        userProfilePicture.layer.masksToBounds = true
    }
}

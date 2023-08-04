//
//  ChatRoomCell.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 19/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class ChatRoomCell: UITableViewCell {
    
    @IBOutlet weak var otherUserImage: UIImageView!
    @IBOutlet weak var otherUserName: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel! //time for last message
    @IBOutlet weak var imageViewCheckMark: UIImageView!
    @IBOutlet weak var imageViewCheckMark2: UIImageView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    
    var idRef: String!
        
    override func awakeFromNib() {
        super.awakeFromNib()
        otherUserImage.layer.cornerRadius = 25
        otherUserImage.layer.masksToBounds = true
        
        lastMessageLabel.text = ""
        
        imageViewCheckMark.alpha = 0.0
        imageViewCheckMark2.alpha = 0.0
        
//        notificationCountLabel.alpha = 0.0
        notificationCountLabel.transform = CGAffineTransform(translationX: 40, y: 0)
        notificationCountLabel.layer.cornerRadius = 10
        notificationCountLabel.layer.masksToBounds = true
        notificationCountLabel.textAlignment = .center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        otherUserImage.image = UIImage(systemName: "person.circle.fill")
        imageViewCheckMark.alpha = 0.0
        imageViewCheckMark2.alpha = 0.0
        notificationCountLabel.alpha = 0.0
    }
    
    func configureNonCheck() {
        imageViewCheckMark.alpha = 0.0
        imageViewCheckMark2.alpha = 0.0
        imageViewCheckMark.image = nil
        imageViewCheckMark2.image = nil
    }
    
    func configureSentCheck() {
        imageViewCheckMark.image = UIImage(systemName: "checkmark")
        imageViewCheckMark.alpha = 1
        imageViewCheckMark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark.contentMode = .bottomRight
        imageViewCheckMark.tintColor = .systemGray
        
        imageViewCheckMark2.image = UIImage(systemName: "checkmark")
        imageViewCheckMark2.alpha = 0
        imageViewCheckMark2.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark2.contentMode = .bottomRight
        imageViewCheckMark2.tintColor = .systemGray
    }
    
    func configuredeliveredCheck() {
        imageViewCheckMark.image = UIImage(systemName: "checkmark")
        imageViewCheckMark.alpha = 1
        imageViewCheckMark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark.contentMode = .bottomRight
        imageViewCheckMark.tintColor = .systemGray
        
        imageViewCheckMark2.image = UIImage(systemName: "checkmark")
        imageViewCheckMark2.alpha = 1
        imageViewCheckMark2.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark2.contentMode = .bottomRight
        imageViewCheckMark2.tintColor = .systemGray
    }
    
    func configureSeenCheck() {
        imageViewCheckMark.image = UIImage(systemName: "checkmark")
        imageViewCheckMark.alpha = 1
        imageViewCheckMark.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark.contentMode = .bottomRight
        imageViewCheckMark.tintColor = #colorLiteral(red: 0, green: 0.8055182099, blue: 0.8414185047, alpha: 1)
        
        imageViewCheckMark2.image = UIImage(systemName: "checkmark")
        imageViewCheckMark2.alpha = 1
        imageViewCheckMark2.preferredSymbolConfiguration = UIImage.SymbolConfiguration(scale: .medium)
        imageViewCheckMark2.contentMode = .bottomRight
        imageViewCheckMark2.tintColor = #colorLiteral(red: 0, green: 0.8055182099, blue: 0.8414185047, alpha: 1)
    }
}

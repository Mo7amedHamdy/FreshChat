//
//  MessageCell.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 28/07/2022.
//

import UIKit

class MessageCell: UITableViewCell {

    @IBOutlet weak var messageBubbleStack: UIStackView!
    @IBOutlet weak var messageBubbleView: ChatBubble!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageTimeLabel: UILabel!
    @IBOutlet weak var imageViewCheckMark: UIImageView!
    @IBOutlet weak var imageViewCheckMark2: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        backgroundConfiguration?.backgroundColor = .clear
    }
    
    override func prepareForReuse() {
        imageViewCheckMark?.alpha = 0
        imageViewCheckMark2?.alpha = 0
    }
}

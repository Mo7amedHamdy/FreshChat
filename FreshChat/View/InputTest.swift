//
//  InputTest.swift
//  Test2
//
//  Created by Mohamed Hamdy on 26/08/2022.
//

import UIKit

protocol SendData {
    func passText(_ text: String)
}

class InputTest: UIView {
    
    var heightConstriantForTextView: NSLayoutConstraint!
    var placeHolderConstrains = [NSLayoutConstraint]()
    
    var placeholderLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    
    var delegate2: SendData?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        heightConstriantForTextView = NSLayoutConstraint(item: textView!, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: textView.intrinsicContentSize.height)
        textView.addConstraint(heightConstriantForTextView)
        textView.layer.cornerRadius = 18
        textView.layer.borderWidth = 0.5
        sendButton.layer.cornerRadius = 20
        sendButton.isEnabled = false
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 6, bottom: 8, right: sendButton.frame.width + 6)
        placeholderLabel = placeHolderForMessageInputViewTextView()
        textView.addSubview(placeholderLabel)
        placeHolderConstrains = [placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 8),
                                 placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 12),
                                 placeholderLabel.bottomAnchor.constraint(equalTo: textView.bottomAnchor, constant: -8),
                                 placeholderLabel.centerYAnchor.constraint(equalTo: textView.centerYAnchor)]
        NSLayoutConstraint.activate(placeHolderConstrains)
    }
    
    @IBAction func didPressSend(_ sender: Any) {
        guard let text = textView.text else { return }
        delegate2?.passText(text)
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 0.0, height: 0.0)
    }
    
    func placeHolderForMessageInputViewTextView() -> UILabel{
        let placeholderLabel = UILabel()
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.text = "Text Message"
        placeholderLabel.textColor = .lightGray
        placeholderLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
//        placeholderLabel.font = .systemFont(ofSize: (textView.font?.pointSize)!)
//        placeholderLabel.frame.origin = CGPoint(x: 12, y: textView.textContainerInset.top)
        
        if #unavailable (iOS 16) {
            placeholderLabel.layer.drawsAsynchronously = true //very important for ios 15 and earlier
        }
        //other way
//        if #available (iOS 16, *) {} else {
//            placeholderLabel.layer.drawsAsynchronously = true //very important for ios 15 and earlier
//        }
        
        placeholderLabel.sizeToFit()
        return placeholderLabel
    }
    
}

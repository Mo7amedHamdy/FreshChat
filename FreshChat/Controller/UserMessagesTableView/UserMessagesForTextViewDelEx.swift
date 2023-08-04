//
//  UserMessagesForTextViewDelEx.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 25/10/2022.
//

import UIKit

extension UserMessagesViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.isScrollEnabled = false
//        print(messageInputView.textView.intrinsicContentSize.height)
//        print(messageInputView.textView.frame.height)
//        print(messageInputView.frame.height)
        if messageInputView.textView.intrinsicContentSize.height < 150 {
            maxHeightForTextView = messageInputView.textView.intrinsicContentSize.height
            self.messageInputView.heightConstriantForTextView.constant = self.maxHeightForTextView
            UIView.animate(withDuration: 0.2) {
                self.inputAccessoryView?.layer.layoutIfNeeded() //another magic property
            }
        }else {
            //note:- you shoud handle maxHeightForTextView
            //if you change the font size for text view
            if maxHeightForTextView == nil || maxHeightForTextView < 45 {
                maxHeightForTextView = 145
                messageInputView.heightConstriantForTextView.constant = maxHeightForTextView
                textView.contentOffset.y = textView.intrinsicContentSize.height - textView.frame.height
                messageInputView.textView.isScrollEnabled = true
            }
            else {
                //intrinsic content size > 150 && max height has value > 40
                messageInputView.heightConstriantForTextView.constant = maxHeightForTextView
                textView.contentOffset.y = textView.intrinsicContentSize.height - textView.frame.height
                messageInputView.textView.isScrollEnabled = true
            }
        }
        
//        maxHeightForTextView = messageInputView.textView.intrinsicContentSize.height
//        if maxHeightForTextView > 130 {
//            textView.isScrollEnabled = true
//            textView.addConstraint(heightConstriantForTextView)
//        }else if maxHeightForTextView <= 130 {
//            heightConstriantForTextView.constant = maxHeightForTextView
//            textView.isScrollEnabled = false
//        }
        
        messageInputView.sendButton.isEnabled = messageInputView.textView.text.isEmpty ? false : true
        
        if !messageInputView.textView.text.isEmpty {
            messageInputView.placeholderLabel.text = ""
            NSLayoutConstraint.deactivate(messageInputView.placeHolderConstrains)
        }
        else {
            messageInputView.placeholderLabel.text = "Text Message"
            NSLayoutConstraint.activate(messageInputView.placeHolderConstrains)
        }
    }
}


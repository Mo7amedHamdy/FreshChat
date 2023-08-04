//
//  UserMessagesViewController+Keyboard.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 16/03/2023.
//

import UIKit

extension UserMessagesViewController {
    
    //Mark:- handling keyboard appearance
    @objc func handleKeyboard(notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        keyboardHeight = keyboardSize.height
        //show keyboard
        if notification.name == UIResponder.keyboardWillShowNotification {
//            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom:(keyboardHeight - view.safeAreaInsets.bottom) + 5, right: 0)
            //for reversed table...
            if !isScroll {
                let contentInset = UIEdgeInsets(top: (keyboardHeight - view.safeAreaInsets.bottom) + 5, left: 0, bottom: 0, right: 0)
                self.chatTable.contentInset = contentInset
                self.chatTable.verticalScrollIndicatorInsets = contentInset
            }
            //first show for keyboard
            if  keyboardHeight > 200 && isChangingFrame == false {
                //for reversed table .. you should care that content offset y is minus
//                self.chatTable.contentOffset.y = ((self.chatTable.contentOffset.y - keyboardHeight) + (messageInputView.frame.height + view.safeAreaInsets.bottom))
                print("chatTable contentOffset y before keyboard: \(self.chatTable.contentOffset.y)")
                self.chatTable.contentOffset.y = ((self.chatTable.contentOffset.y - keyboardHeight) + (view.safeAreaInsets.bottom))
                print("chatTable contentOffset y after keyboard: \(self.chatTable.contentOffset.y)")
                print("message input view height at keyboard: \(messageInputView.frame.height)")
                print("keyboard height at keyboard: \(keyboardHeight)")
                
                   //here like start app you shoud get content offset from this equation
                  //to get the exact content offset.y (not in reversed table)
//                self.chatTable.contentOffset.y = (self.chatTable.contentSize.height + self.chatTable.contentInset.bottom) - self.chatTable.frame.height
//                print("chat table content offset after send message: \(self.chatTable.contentOffset.y)")

                tap.isEnabled = true
                isChangingFrame = true
            }
            
            //Mark:- this note is very important😃😃
            //change frame of keyboard
            //this code has a bug and can't change frame of keyboard in will change frame
            //because this code perform the new contentInset.bottom befor contentOffset.y
            //and this decreases contentOffset.y
            //and this behavior is not what we want
//            else if keyboardHeight > 100 && isChangingFrame {
//                let heightPlus = keyboardHeight - inputHeight
//                print("keyboardHeight: \(keyboardHeight)")
//                print("inputHeight: \(inputHeight)")
//                print("heightPlus: \(heightPlus)")
//                self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y) + heightPlus
//                print("keyboardHeight: \(keyboardHeight)")
//                print("inputHeight: \(inputHeight)")
//                print("is changed 33333333000000")
//                print("content offset change frame: \(self.chatTable.contentOffset.y)")
//                print("contentInset change frame: \(self.chatTable.contentInset.bottom)")
//            }
        }
        
        //change frame
        //it is best place to change frame of keyboard
        else if notification.name == UIResponder.keyboardWillChangeFrameNotification {
            if isChangingFrame {
                //for reversed table
                self.chatTable.contentOffset.y = -(keyboardHeight - view.safeAreaInsets.bottom + 5)
                
                //TODO think to do content inset here and vertical scroll indicator ??
            }
        }
        
        //hide keyboard
        else if notification.name == UIResponder.keyboardWillHideNotification {
            //in case dismiss keyboard with tap gesture
            if isTappedGesture && chatTable.contentSize.height > chatTable.frame.height {
                //Mark:- at hide keyboard:  messageInputView.frame.height = inputAreaHeight + safeAreaInset.bottom
//                self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y - self.keyboardHeight) + (self.messageInputView.frame.height)
                //for reversed table .. you should care content offset y is minus
                self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y + self.keyboardHeight) - (self.messageInputView.frame.height)
            }
            else {
//                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (messageInputView.frame.height - view.safeAreaInsets.bottom) + 5, right: 0)
                //for reversed table
                let contentInset = UIEdgeInsets(top: (messageInputView.frame.height - view.safeAreaInsets.bottom) + 5, left: 0, bottom: 0, right: 0)
                self.chatTable.contentInset = contentInset
                self.chatTable.verticalScrollIndicatorInsets = contentInset
            }
            isChangingFrame = false
            isMessageSent = false  //TODO make sure you may delete this var
            isTappedGesture = false
            tap.isEnabled = false
            inputHeight = 0
        }
    }
    
    
    //Mark:- handling keyboard appearance
//    @objc func handleKeyboard(notification: Notification) {
//        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
//        keyboardHeight = keyboardSize.height
//        //show keyboard
//        if notification.name == UIResponder.keyboardWillShowNotification {
//            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (keyboardHeight - view.safeAreaInsets.bottom) + 5 , right: 0)
//            self.chatTable.contentInset = contentInset
//            self.chatTable.verticalScrollIndicatorInsets = contentInset
//            print("keyboard height: \(keyboardHeight)")
//            print("content inset at start: \(self.chatTable.contentInset.bottom)")
//            print("messageInputView.textView.height at start \(messageInputView.frame.height)")
//            //first show for keyboard
//            if  keyboardHeight > 200 && isChangingFrame == false {
//                if self.chatTable.contentSize.height > self.chatTable.frame.height {
//                    if !isMessageSent {
//                        self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y + keyboardHeight) - (messageInputView.frame.height + view.safeAreaInsets.bottom)
//                        //not suitable here
////                        self.chatTable.contentOffset.y = (self.chatTable.contentSize.height + self.chatTable.contentInset.bottom) - self.chatTable.frame.height
//                        print("is showing 3333333333000000000")
//                        print("contentSize.height > frame.height 99999999")
//                        print("content offset show  \(chatTable.contentOffset.y)")
//                        print("content inset show  \(chatTable.contentInset.bottom)")
//                        print("messageInputView.textView.height  \(messageInputView.frame.height)")
//                    }
//                    else {
//                        //here like start app you shoud get content offset from this equation
//                        //to get the exact content offset.y
//                        self.chatTable.contentOffset.y = (self.chatTable.contentSize.height + self.chatTable.contentInset.bottom) - self.chatTable.frame.height
//                        print("chat table content offset after send message: \(self.chatTable.contentOffset.y)")
//                    }
//                    isChangingFrame = true
//                }
//                //scroll to last row in case contentSize.height < frame.height
//                else if self.chatTable.contentSize.height < self.chatTable.frame.height {
//                    if !groupedMessages.isEmpty {
//                        let lastSection = self.groupedMessages.count - 1
//                        let lastRow = (self.groupedMessages.last?.messages.count)! - 1
//                        let indexPath = IndexPath(row: lastRow, section: lastSection)
//                        self.chatTable.scrollToRow(at: indexPath, at: .bottom, animated: false)
//                        tap.isEnabled = true
//                        print("contentSize.height < frame.height 88888888")
//                    }
//                }
//                tap.isEnabled = true
//            }
//
//            //Mark:- this note is very important😃😃
//            //change frame of keyboard
//            //this code has a bug and can't change frame of keyboard in will change frame
//            //because this code perform the new contentInset.bottom befor contentOffset.y
//            //and this decreases contentOffset.y
//            //and this behavior is not what we want
////            else if keyboardHeight > 100 && isChangingFrame {
////                let heightPlus = keyboardHeight - inputHeight
////                print("keyboardHeight: \(keyboardHeight)")
////                print("inputHeight: \(inputHeight)")
////                print("heightPlus: \(heightPlus)")
////                self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y) + heightPlus
////                print("keyboardHeight: \(keyboardHeight)")
////                print("inputHeight: \(inputHeight)")
////                print("is changed 33333333000000")
////                print("content offset change frame: \(self.chatTable.contentOffset.y)")
////                print("contentInset change frame: \(self.chatTable.contentInset.bottom)")
////            }
//
//            inputHeight = keyboardHeight
//        }
//
//        //change frame
//        //it is best place to change frame of keyboard
//        else if notification.name == UIResponder.keyboardWillChangeFrameNotification {
//            if isChangingFrame {
//                let heightPlus = keyboardHeight - inputHeight
//                print("keyboardHeight: \(keyboardHeight)")
//                print("inputHeight: \(inputHeight)")
//                print("heightPlus: \(heightPlus)")
//                self.chatTable.contentOffset.y = self.chatTable.contentOffset.y + heightPlus
//                print("is changed 33333333000000")
//                print("content offset change frame: \(self.chatTable.contentOffset.y)")
//                print("contentInset change frame: \(self.chatTable.contentInset.bottom)")
//                inputHeight = keyboardHeight
//            }
//        }
//
//        //hide keyboard
//        else if notification.name == UIResponder.keyboardWillHideNotification {
//            //in case dismiss keyboard with tap gesture
//            if isTappedGesture && chatTable.contentSize.height > chatTable.frame.height {
//                //Mark:- at hide keyboard:  messageInputView.frame.height = inputAreaHeight + safeAreaInset.bottom
//                self.chatTable.contentOffset.y = (self.chatTable.contentOffset.y - self.keyboardHeight) + (self.messageInputView.frame.height)
//                print("keyboardHeight: \(keyboardHeight)")
//                print("messageInputView.height: \(messageInputView.frame.height)")
//                print("messageImput.height + safeArea.bottom: \(messageInputView.frame.height + view.safeAreaInsets.bottom)")
//                print("safeAreaInsets.bottom: \(self.view.safeAreaInsets.bottom)")
//                print("contentOffset after tap: \(chatTable.contentOffset.y)")
//            }
//            else {
//                let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (messageInputView.frame.height - view.safeAreaInsets.bottom) + 5, right: 0)
//                self.chatTable.contentInset = contentInset
//                self.chatTable.verticalScrollIndicatorInsets = contentInset
//            }
//            isChangingFrame = false
//            isMessageSent = false
//            isTappedGesture = false
//            tap.isEnabled = false
//            inputHeight = 0
//            print("555555555555555")
//            print("is hiding")
//        }
//    }
}

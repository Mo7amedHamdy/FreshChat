//
//  UserMessagesViewController+ContextMenuInteraction.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 15/03/2023.
//

import UIKit
import FirebaseAuth

extension UserMessagesViewController: ToolBarButtons {
    
    //delete selected rows
    func didPressDelete(_ isPressed: Bool) {
        isFetching = true
        presentActionSheet()
    }
    
    func presentActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        var messagesToDel = [Message]()
        //Mark:- delete action
        let sheetTitle = self.deletToolbar.selectedRowscountLabel.text == "1" ? "Delete for Me" : "Delete \(self.deletToolbar.selectedRowscountLabel.text!) for Me"
        let deleteAction = UIAlertAction(title: sheetTitle, style: .destructive) { action in
            self.isDeleted = true
            //delete rows or sections
            while self.chatTable.indexPathsForSelectedRows != nil {
                guard let firstIndex = self.chatTable.indexPathsForSelectedRows?.first else { return }
                let messageToDelete = self.groupedMessages[firstIndex.section].messages[firstIndex.row]
                messagesToDel.append(messageToDelete)
                //delete selected row or section
                self.chatTable.performBatchUpdates {
                    if self.indexForEdit != nil {
                        self.chatTable.deleteRows(at: [self.indexForEdit], with: .fade)
                        self.groupedMessages[self.indexForEdit.section].messages.remove(at: self.indexForEdit.row)
                        self.groupedMessagesTest[self.indexForEdit.section].messages.remove(at: self.indexForEdit.row)
                        self.indexForEdit = nil
                    }
                    else if self.groupedMessages[firstIndex.section].messages.count == 1 {
                        let indexSet = IndexSet(arrayLiteral: firstIndex.section)
                        self.chatTable.deleteSections(indexSet, with: .none)
                        self.groupedMessages.remove(at: firstIndex.section)
                        self.groupedMessagesTest.remove(at: firstIndex.section)
                        print("section deleted 99999999")
                    }
                    else {
                        self.chatTable.deleteRows(at: [firstIndex], with: .none)
                        self.groupedMessages[firstIndex.section].messages.remove(at: firstIndex.row)
                        self.groupedMessagesTest[firstIndex.section].messages.remove(at: firstIndex.row)
                        print("row deleted 8888888")
                    }
                }
                
                //TODO read snapshot doc in firestore
                //you need to update chat table after delete data ??
                
                //delete message from firestore
                self.db.collection("users").document(self.currentUser.email).collection("chatRooms").document(self.chatRoomDocumentID).collection("roomMessages").document(messageToDelete.messageId).delete { error in
                    print("4545454545454545454")
                }
                //update last message
//                if !self.groupedMessages.isEmpty {
//                    if let lastMessage = self.groupedMessages[0].messages.first {
//                        self.updateChatRoomForCurrentUser(lastMessage: lastMessage, state: lastMessage.messageState ?? "")
//                        let room = ChatRoom(id: lastMessage.roomId, lastMessage: lastMessage.body, lastMessageTime: lastMessage.sendTime, otherUserEmial: self.otherUser.email, otherUserFirstName: self.otherUser.firstName, otherUserLastName: self.otherUser.lastName, senderLastMessage: lastMessage.sender, messageId: lastMessage.messageId, messageState: lastMessage.messageState, deliveredMessagesCount: 0)
//                        print("nillllllllllll")
//                        self.onChange(room)
//                    }
//                }
            }
            self.chatTable.setEditing(false, animated: true)
            self.navigationItem.rightBarButtonItem = nil
            self.hideDeleteToolbar()
        }
        
        //Mark:- cancel action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }

    
    //for selected rows count label
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let rowsCountString = tableView.indexPathsForSelectedRows?.count else { return }
        deletToolbar.selectedRowscountLabel.text = "\(rowsCountString)"
        deletToolbar.deleteButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let rowsCountString = tableView.indexPathsForSelectedRows?.count {
            deletToolbar.selectedRowscountLabel.text = "\(rowsCountString)"
        }else {
            deletToolbar.selectedRowscountLabel.text = "0"
            deletToolbar.deleteButton.isEnabled = false
        }
    }
    
    
    //context menu for row
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        if indexPath.section == indexForEdit?.section && indexPath.row == indexForEdit?.row {
            return nil
        }
        let menu = contextMenuForRow(at: indexPath)
        if chatTable.isEditing {
            return nil
        }else {
            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider:  { menuElements in
                return menu
            })
        }
    }

    func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }

    func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        return makeTargetedPreview(for: configuration)
    }
    
    //context menu for message bubble view
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
//        guard let indexPath = chatTable.indexPathForRow(at: interaction.location(in: chatTable)) else { return nil}
//        let menu = contextMenuForRow(at: indexPath)
//        if chatTable.isEditing {
//            return nil
//        }else {
//            return UIContextMenuConfiguration(identifier: indexPath as NSCopying, actionProvider:  { menuElements in
//                return menu
//            })
//        }
//    }
//
//    //@available(iOS 16.0, *)
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, highlightPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
//        return makeTargetedPreview(for: configuration)
//    }
//
//    //@available(iOS 16.0, *)
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configuration: UIContextMenuConfiguration, dismissalPreviewForItemWithIdentifier identifier: NSCopying) -> UITargetedPreview? {
//        return makeTargetedPreview(for: configuration)
//    }
    
    //configure preview for context menu
    private func makeTargetedPreview(for configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        // Ensure we can get the expected identifier.
        if let indexPath = configuration.identifier as? IndexPath {
            // Get the cell for the index of the model.
            let message = groupedMessages[indexPath.section].messages[indexPath.row]
            guard let cell = chatTable.cellForRow(at: indexPath) as? MessageCell else { return nil }
            guard let targetView = cell.messageBubbleView else { return nil }
            let parameters = UIPreviewParameters()
            let visiblePath = messageBubblePreview(for: targetView.frame, drawWithTail: targetView.drawWithTail, message: message)
            parameters.visiblePath = visiblePath
            return UITargetedPreview(view: targetView, parameters: parameters)
        } else {
            return nil
        }
    }

    
    //visible path of preview
    func messageBubblePreview(for rect: CGRect, drawWithTail: Bool, message: Message) -> UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2
        let bottom = rect.height
        let right = rect.width
        let top = 0.0
//        let left = 0.0

        //preview with tail
        if drawWithTail {
            //current user
            if message.sender == Auth.auth().currentUser?.email {
                bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
                bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
                bezierPath.addCurve(to: CGPoint(x: 10, y: bottom - 17), controlPoint1: CGPoint(x: 13 , y: bottom), controlPoint2: CGPoint(x: 10, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: 10 , y: 17))
                bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 10 , y: 6), controlPoint2: CGPoint(x: 13, y: top))
                bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
                bezierPath.addCurve(to: CGPoint(x: right - 10, y: 17), controlPoint1: CGPoint(x: right - 13 , y: top), controlPoint2: CGPoint(x: right - 10, y: 6))
                bezierPath.addLine(to: CGPoint(x: right - 10 , y: bottom - 10))
                bezierPath.addCurve(to: CGPoint(x: right - 4, y: bottom), controlPoint1: CGPoint(x: right - 10.00, y: bottom - 4.00), controlPoint2: CGPoint(x: right - 6, y: bottom ))
                bezierPath.close()
        
            }
            //other user
            else {
                bezierPath.move(to: CGPoint(x: 10.00, y: 17.00))
                bezierPath.addLine(to: CGPoint(x: 10.00, y: bottom - 10.00))
                bezierPath.addCurve(to: CGPoint(x: 4, y: bottom), controlPoint1: CGPoint(x: 10.00, y: bottom - 4.00), controlPoint2: CGPoint(x: 6, y: bottom))
                bezierPath.addLine(to: CGPoint(x: right - 30.00, y: bottom))
                bezierPath.addCurve(to: CGPoint(x: right - 10.00, y: bottom - 17.00), controlPoint1: CGPoint(x: right - 13.00, y: bottom), controlPoint2: CGPoint(x: right - 10.00, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: right - 10.00, y: 17.00))
                bezierPath.addCurve(to: CGPoint(x: right - 30.00, y: top), controlPoint1: CGPoint(x: right - 10 , y: 6), controlPoint2: CGPoint(x: right - 13.00, y: top))
                bezierPath.addLine(to: CGPoint(x: 30, y: top))
                bezierPath.addCurve(to: CGPoint(x: 10.00, y: 17), controlPoint1: CGPoint(x: 13 , y: top), controlPoint2: CGPoint(x: 10.00, y:6))
                bezierPath.close()
            }
        }
        //preview without tail
        else {
            bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
            bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
            bezierPath.addCurve(to: CGPoint(x: 10, y: bottom - 17), controlPoint1: CGPoint(x: 13 , y: bottom), controlPoint2: CGPoint(x: 10, y: bottom - 6.00))
            bezierPath.addLine(to: CGPoint(x: 10 , y: 17))
            bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 10 , y: 6), controlPoint2: CGPoint(x: 13, y: top))
            bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
            bezierPath.addCurve(to: CGPoint(x: right - 10, y: 17), controlPoint1: CGPoint(x: right - 13 , y: top), controlPoint2: CGPoint(x: right - 10, y: 6))
            bezierPath.addLine(to: CGPoint(x: right - 10 , y: bottom - 17))
            bezierPath.addCurve(to: CGPoint(x: right - 30, y: bottom), controlPoint1: CGPoint(x: right - 10, y: bottom - 6.00), controlPoint2: CGPoint(x: right - 13, y: bottom))
            bezierPath.close()
        }
        return bezierPath
    }
            
    //UIMenu for selected row
    func contextMenuForRow(at indexPath: IndexPath) -> UIMenu {
        let deleteAction = UIAction(title: "Delete", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
            DispatchQueue.main.async {
                let message = self.groupedMessages[indexPath.section].messages[indexPath.row]
                if message.sender == self.currentUser.email {
                    self.chatTable.beginUpdates()
                    self.chatTable.reloadRows(at: [indexPath], with: .none) //for row when select it
                    self.chatTable.endUpdates()
                }
                self.chatTable.allowsMultipleSelectionDuringEditing = true
                DispatchQueue.main.async {
                    UIView.animate(withDuration: 1) {
                        self.messageInputView.textView.resignFirstResponder()
                        self.view.layer.setNeedsLayout()
                    }
                }
                self.chatTable.setEditing(true, animated: true)
                self.chatTable.selectRow(at: indexPath, animated: true, scrollPosition: .none)
                self.deletToolbar.selectedRowscountLabel.text = "\((self.chatTable.indexPathsForSelectedRows?.count)!)"
                self.showDeleteToolbar()
            }
            //right bar button item
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelContextMenu))
        }
        return UIMenu(children: [deleteAction])
    }
    
    @objc func cancelContextMenu() {
        chatTable.setEditing(false, animated: true)
        navigationItem.rightBarButtonItem = nil
        hideDeleteToolbar()
    }
    
    //show delete toolbar
    func showDeleteToolbar() {
        //keyboard not shown
        UIView.animate(withDuration: 0.3) {
            self.messageInputView.transform = .identity
        }completion: { isCompleted in
            UIView.animate(withDuration: 0.3, delay: 0.3) {
                self.messageInputView.transform = CGAffineTransform(translationX: 0, y: self.keyboardHeight)
                self.deletToolbar.transform = .identity
            }
        }
    }
    
    //hide delete toolbar
    func hideDeleteToolbar() {
        //keyboard not shown
        UIView.animate(withDuration: 0.4) {
            self.deletToolbar.transform = CGAffineTransform(translationX: 0, y: self.keyboardHeight)
            self.messageInputView.transform = .identity
        }
    }
    
}

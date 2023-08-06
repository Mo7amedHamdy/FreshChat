//
//  UserMessagesForSendButtonEx.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 25/10/2022.
//

import UIKit
import FirebaseAuth

extension UserMessagesViewController: SendData {
    func passText(_ text: String) {
        didPressSendButton()
    }
    
    //save data to firestore
    func didPressSendButton() {
        
        if self.indexForEdit != nil {
            self.chatTable.performBatchUpdates {
                self.chatTable.deleteRows(at: [self.indexForEdit], with: .fade)
                self.groupedMessages[self.indexForEdit.section].messages.remove(at: self.indexForEdit.row)
                self.groupedMessagesTest[self.indexForEdit.section].messages.remove(at: self.indexForEdit.row)
//                self.indexForEdit = nil
            }completion: { isCompleted in
                guard let index = self.indexForEdit else {return}
                let indexPath = IndexPath(row: index.row + 1, section: index.section)
                self.indexForEdit = nil
                UIView.animate(withDuration: 0.2) {
                    self.chatTable.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        isModified = false  //temporary think to handle this with doc added
        isDeleted = false
//        isChangingFrame = false
        isMessageSent = true  //TODO make sure you may delete this var
                
        if let messageBody = messageInputView.textView.text, let messagesender = Auth.auth().currentUser?.email {
            self.messageInputView.textView.text = ""
            self.messageInputView.textView.isScrollEnabled = false
            self.messageInputView.heightConstriantForTextView.constant = self.messageInputView.textView.intrinsicContentSize.height
            UIView.animate(withDuration: 0.3) {
                self.inputAccessoryView?.layer.layoutIfNeeded() //when send message to return text view height to its origin
            }
            self.messageInputView.placeholderLabel.text = "Text Message"
            NSLayoutConstraint.activate(messageInputView.placeHolderConstrains)
            //note:- you should equal max height with text view intrinsic content height
            //because after send data it still has last height
            //even though text view became empty
            maxHeightForTextView = messageInputView.textView.intrinsicContentSize.height
            self.messageInputView.sendButton.isEnabled = false
            lastMessageV = Message(roomId: "", sender: messagesender, body: messageBody, sendTime: Date().timeIntervalSince1970, messageState: "sent")
            
            //mark:- configure chat room messages if not found
            if groupedMessages.isEmpty {
//                if conversationIsFound == false {
//                    print("isFound is false")
//                    guard let chatRoomDocId = chatRoomDocumentID else { return }
//                    guard let chatRoomDocId2 = chatRoomDocumentID2 else { return }
//                    db.collection("conversations").document(chatRoomDocumentID).setData(["id": [chatRoomDocId, chatRoomDocId2]])
//                    configureChatRoomForCurrentUser(lastMessage: lastMessageV)
//                    configureChatRoomForOtherUser(lastMessage: lastMessageV)
//                }
//
//                else if conversationIsFound == true {
//                    print("isFound is true ")
//                    configureChatRoomForCurrentUser(lastMessage: lastMessageV)
//
////                    if chatRoomOtherUserIsFound == false {
////                        configureChatRoomForOtherUser(lastMessage: lastMessageV)
////                    }
//                }
//
//                //insert section for first message for current user
                let date = Date(timeIntervalSince1970: lastMessageV.sendTime)
                let formattedDate = date.formatted(.dateTime.year().month().day())
                let newGroup = GroupedMessages(date: formattedDate, messages: [lastMessageV])
                self.chatTable.performBatchUpdates {
                    let indexSet = IndexSet(arrayLiteral: 0)
                    self.chatTable.insertSections(indexSet, with: .top)
                    self.groupedMessages.append(newGroup)
                    self.groupedMessagesTest.append(newGroup)

                    //TODO load listener here think ??
                }
                let chatRoomId2 = ("\(otherUser.email)_\(currentUser.email)")
                self.queryInConversationsForOtherUser(ChatRoomIdOU: chatRoomId2, lastMessage: lastMessageV)
                
            }
//            else { //in case grouped messages not empty
//                if chatRoomOtherUserIsFound == false {
//                    configureChatRoomForOtherUser(lastMessage: lastMessageV)
//                }
//            }
            
            //save messages in current user messages
            let conversationReferenceCU =  db.collection("users").document(messagesender)
            
            conversationReferenceCU.collection("chatRooms")
                .document(chatRoomDocumentID)
                .collection("roomMessages")
                .document(lastMessageV.messageId)
                .setData([
                "roomId": chatRoomDocumentID!,
                "messageId": lastMessageV.messageId,
                "body" : messageBody,
                "messageState": "sent",
                "sender" : messagesender,
                "sendTime" : Date().timeIntervalSince1970,
                "otherUserEmail": otherUser.email,
                "otherUserFirstName": otherUser.firstName,
                "otherUserLastName": otherUser.lastName,
                "currentUserEmail": currentUser.email

            ]) { error in
                if let err = error {
                    print("error in saving data to firestore, \(err.localizedDescription)")
                }else {
                    print("succesfully saved data in current user messages.")

                    if self.groupedMessages.count == 1 {
                        self.loadMessagesFromFirestoreWithListener()
                    }
                }
            }
            updateChatRoomForCurrentUser(lastMessage: lastMessageV, state: "sent")
            
            //save messages in other user messages in conversation
            let chatRoomId2 = ("\(otherUser.email)_\(currentUser.email)")
            let conversationReferenceOU = db.collection("users").document(otherUser.email)
            conversationReferenceOU.collection("chatRooms")
                .document(chatRoomId2)
                .collection("roomMessages")
                .document(lastMessageV.messageId)
                .setData([
                "roomId": chatRoomId2,
                "messageId": lastMessageV.messageId,
                "body" : messageBody,
                "sender" : messagesender,
                "sendTime" : Date().timeIntervalSince1970,
                "otherUserEmail": currentUser.email,
                "otherUserFirstName": currentUser.firstName,
                "otherUserLastName": currentUser.lastName,
                "currentUserEmail": otherUser.email
            ]) { error in
                if let err = error {
                    print("error in saving data to firestore, \(err.localizedDescription)")
                }else {
                    print("succesfully saved data in other user messages.")
                    
                    //get all unseen messages
                    self.getDeliveredMessagesCount { unseenMessagesCount in
                        self.getOtherUserPresent { present in
                            if present == "true" {
                                self.updateChatRoomForOtherUser(lastMessage: self.lastMessageV, deliveredMessagesCount: 0)
                            }
                            else {
                                self.updateChatRoomForOtherUser(lastMessage: self.lastMessageV, deliveredMessagesCount: unseenMessagesCount + 1)
                            }
                        }

                    }
                    
                    if self.groupedMessages.count == 1 {
                        self.db.collection("users").document(self.currentUser.email).updateData(["configured": "true"])
                    }
                }
            }
            
            //TODO update message status here ??
//            self.getAllSentMessages(roomId: self.chatRoomDocumentID, currentUserEmail: self.currentUser.email) { count1 in
//                //update chat room for other user
//                self.getAllDeliveredMessages(roomId: self.chatRoomDocumentID, currentUserEmail: self.currentUser.email) { count2 in
//                    self.getOtherUserPresent { present in
//                        if present == "true" {
//                            self.updateChatRoomForOtherUser(lastMessage: self.lastMessageV, deliveredMessagesCount: 0)
//                        }
//                        else {
//                            self.updateChatRoomForOtherUser(lastMessage: self.lastMessageV, deliveredMessagesCount: count1 + count2)
//                        }
//                    }
//                }
//            }
        }
    }
    
    //get all delivered and sent messages
//    func getAllDeliveredAndSentMessages(roomId: String, currentUserEmail: String, completion: @escaping (Int)->Void) {
//        let query = self.db.collection("users").document(currentUserEmail).collection("chatRooms").document(roomId).collection("roomMessages").whereField("messageState", isNotEqualTo: "seen")
//        query.getDocuments(source: .server) { snapshot, error in
//            if let error2 = error {
//                print(error2.localizedDescription)
//            }
//            else {
//                guard let docs = snapshot?.documents else {return}
//                completion(docs.count)
//            }
//        }
//    }
    
    //get all delivered and sent messages
    func getDeliveredMessagesCount(completion: @escaping (Int)->Void) {
        let query = self.db.collection("users").document(otherUser.email).collection("chatRooms").document("\(otherUser.email)_\(currentUser.email)")
        query.getDocument(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let doc = snapshot else {return}
                guard let data = doc.data() else {return}
                guard let newMessagesCount = data["deliveredMessagesCount"] as? Int else {return}
                completion(newMessagesCount)
            }
        }
    }
    

    
    //check present of other user when send message
    func getOtherUserPresent(completion: @escaping (String)->Void) {
        let query = self.db.collection("users").document(otherUser.email).collection("chatRooms").document("\(otherUser.email)_\(currentUser.email)")
        query.getDocument(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let doc = snapshot else {return}
                guard let data = doc.data() else {return}
                guard let present = data["present"] as? String else {return}
                completion(present)
            }
        }
    }
    
    
    //fetch conversations when start new conversation
//    func queryInConversationsForCurrentUser() {  //messages is empty
//
//        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
//        let querySearch = "\(currentUserEmail)_\(otherUser.email)"
//        db.collection("conversations").whereField("id", arrayContains: querySearch).getDocuments { querySnapshot, error in
//            if let error2 = error {
//                print(error2.localizedDescription)
//                print("There is no conversation with this id !")
//            }
//            else {
//                print("conversation is checked!")
//                if let docs = querySnapshot?.documents {
//                    if docs.isEmpty {   //conversation not found
//                        print("is empty")
//                        self.conversationIsFound = false
//                        self.chatRoomDocumentID2 = "\(self.otherUser.email)_\(currentUserEmail)"
//                    }
//                    else{  //conversation found
//                        print("if found")
//                        self.conversationIsFound = true
//                        self.chatRoomDocumentID = docs[0].documentID
//                    }
//
//                }
//            }
//        }
//    }
    
    
    //fetch conversations when messages is not empty
    func queryInConversationsForOtherUser(ChatRoomIdOU: String, lastMessage: Message) { //messages is not empty
        db.collection("users").document(currentUser.email).collection("chatRooms").whereField("id", isEqualTo: ChatRoomIdOU).getDocuments { qSnapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
                print("There is no conversation with this name")
            }
            else {
                if let data = qSnapshot?.documents {
                    if data.isEmpty {
                        print("there is no conversation with this name")
                        self.chatRoomOtherUserIsFound = false
                        self.configureChatRoomForOtherUser(lastMessage: lastMessage, deliveredMessagesCount: 0)
                    }
                    else {
                        print("there is conversation with this name")
                        self.chatRoomOtherUserIsFound = true
                    }
                }
            }
        }
    }
}


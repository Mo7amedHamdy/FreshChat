//
//  UserMessagesViewController+FetchMessagesForNotification.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 16/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension UserMessagesViewController {
    
    //TODO modify path of document ??
    
    //get data from notification
    func getMessagesThroughNotification(onChange: (([GroupedMessages], IndexPath?)->Void)?) {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        db.collection("users").document(currentUserEmail).collection("chatRooms")
            .document(chatRoomDocumentID!).collection("roomMessages")
            .order(by: "sendTime", descending: true)
            .limit(to: 40).getDocuments(source: .server) { querySnapshot, error in
                //handle error
                if let error2 = error {
                    print("error is: \(error2.localizedDescription)")
                    return
                }
                
                guard let snapshot = querySnapshot else { return }
                
                snapshot.documentChanges.forEach({ docChange in
                    
                    //Mark:- start case or add message
                    if docChange.type == .added && self.isDeleted == false {
                        let doc = docChange.document
                        print("added : 11111111")
                        
                        let data = doc.data()
                        if let messageSender = data["sender"] as? String,
                           let messageBody = data["body"] as? String,
                           let sendTime = data["sendTime"] as? TimeInterval,
                           let roomId = data["roomId"] as? String,
                           let messageId = data["messageId"] as? String {
                            
                            let messageState = data["messageState"] as? String ?? nil
                            
                            let newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: messageState, messageId: messageId)

                            //handle messages grouped by date
                            let date = Date(timeIntervalSince1970: sendTime)
                            let dateFormat = date.formatted(.dateTime.year().month().day())
                            
                            if self.groupedMessagesTest.isEmpty {
                                let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                self.groupedMessagesTest.append(newGroup)
                            }
                            //group message found
                            else if self.groupedMessagesTest.contains(where: {$0.date == dateFormat}) {
                                let groupedMessagesArrWithDateString = self.groupedMessagesTest.filter({$0.date == dateFormat})
                                var groupedMessagesUpdated = groupedMessagesArrWithDateString[0]
                                
                                if groupedMessagesUpdated.messages.contains(where: {$0.messageId == newMessage.messageId}) {
                                    //TODO what ??
                                }
                                else {
                                    groupedMessagesUpdated.messages.append(newMessage)
                                    let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                    self.groupedMessagesTest[index] = groupedMessagesUpdated
                                }
                            }
                            //add new group
                            else {
                                let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                self.groupedMessagesTest.append(newGroup)
                            }
                            
                        }
                    }
                })
                
                //new notifications data
                let pref = UserDefaults.init(suiteName: "group.mohamed.FreshChat")
                guard let data = pref?.value(forKey: "notification") as? [[String: String]] else {return}
                print("data count : \(data.count) 909090909090")
                
                //get notification messgaes
                self.notificationMessages = []  //because of listener is called twice when click on notification
                for message in data {
                    guard let messageId = message["messageId"],
                          let messageBody = message["body"],
                          let sendTimeString = message["sendTime"] else {return}
                    let sendTimeInterval2 = Substring(sendTimeString)
                    let sendTimeInterval = TimeInterval(sendTimeInterval2)
                    let notMessage = NotificationData(messageId: messageId, messageBody: messageBody, sendTime: sendTimeInterval!)
                    self.notificationMessages.append(notMessage)
                }
                let notMessages2 = self.notificationMessages.sorted(by: {$0.sendTime > $1.sendTime})
                print("not messages 2 : \(notMessages2.count) 999999999")
                
                //configure unread cell
                for i in 0..<self.groupedMessagesTest.count {
                    for j in 0..<self.groupedMessagesTest[i].messages.count {
                        if notMessages2[notMessages2.count - 1].messageId == self.groupedMessagesTest[i].messages[j].messageId {
                            let indexPath = IndexPath(row: j + 1, section: i)
                            self.indexForEdit = indexPath
                            let messageForUnreadCell = Message(roomId: "", sender: "", body: "UnReadMessages", sendTime: notMessages2[notMessages2.count - 1].sendTime)
                            self.groupedMessagesTest[i].messages.insert(messageForUnreadCell, at: j + 1)
                            print("noty 8888888")
                            break
                        }
                    }
                }
                
//                var messages = [Message]()
//                let date = Date(timeIntervalSince1970: notMessages2[notMessages2.count - 1].sendTime)
//                let dateFormat = date.formatted(.dateTime.year().month().day())
//                for i in 0...self.groupedMessagesTest.count - 1 {    //TODO handle this ??
//                    for j in 0...self.groupedMessagesTest[0].messages.count - 1 {
//                        if notMessages2.last?.messageId == self.groupedMessagesTest[0].messages[j].messageId {
//                            let newMessage = Message(roomId: "unreadmessages9999", sender: "", body: "UnReadMessages", sendTime: self.groupedMessagesTest[i].messages[j].sendTime)
//                            self.groupedMessagesTest[i].messages.insert(newMessage, at: j + 1)
//                            print("999999999999999999999999")
//
//                            for message in self.groupedMessagesTest[0].messages[0...j] {
//                                messages.append(message)
//                                self.groupedMessagesTest[0].messages.remove(at: 0)
//                            }
//                            let groupNotification = GroupedMessages(date: dateFormat, messages: messages)
//                            self.groupedMessagesTest.insert(groupNotification, at: 0)
//                            break
//                        }
//                    }
//                    break
//                }
                
                self.groupedMessages = self.groupedMessagesTest
                onChange?(self.groupedMessages, self.indexForEdit)
            }
    }
    
    
    //load data from firestore  //test paginate data
    func loadMessagesFromFirestoreWithListenerForNotification() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        //Mark:- listner for notifications data
        cloudFirestoreQuery = db.collection("users")
            .document(currentUserEmail).collection("chatRooms")
            .document(chatRoomDocumentID!).collection("roomMessages")
            .order(by: "sendTime", descending: true).limit(to: 40)
        messagesListener = cloudFirestoreQuery.addSnapshotListener { querySnapshot, error in
            
            //handle error
            if let error2 = error {
                print(error2.localizedDescription)
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            snapshot.documentChanges.forEach({ docChange in
                print("doc change type: \(docChange.type) 9999999999")
                
                //Mark:- start case or add message
                if docChange.type == .added && self.isDeleted == false {
                    let doc = docChange.document
                    print("added : 11111111")
                    self.documentStart = snapshot.documents.last //document to start paginating from
                    let data = doc.data()
                    if let messageSender = data["sender"] as? String,
                       let messageBody = data["body"] as? String,
                       let sendTime = data["sendTime"] as? TimeInterval,
                       let roomId = data["roomId"] as? String,
                       let messageId = data["messageId"] as? String {
                        
                        let messageState = data["messageState"] as? String ?? nil
                            
                        let newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: messageState, messageId: messageId)

                        //handle messages grouped by date
                        let date = Date(timeIntervalSince1970: sendTime)
                        let dateFormat = date.formatted(.dateTime.year().month().day())
                        
                        //first message with first group
                        if self.groupedMessagesTest.isEmpty {
                            let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                            self.groupedMessagesTest.append(newGroup)
                            self.groupedMessages = self.groupedMessagesTest
                        }
                        
                        //group message found
                        else if self.groupedMessagesTest.contains(where: {$0.date == dateFormat}) {
                            let groupedMessagesArrWithDateString = self.groupedMessagesTest.filter({$0.date == dateFormat})

                            var groupedMessagesUpdated = groupedMessagesArrWithDateString[0]
                            let groupedMessagesUpdated2 = groupedMessagesArrWithDateString.count == 2 ? groupedMessagesArrWithDateString[1] : nil

                            if groupedMessagesUpdated.messages.contains(where: {$0.messageId == newMessage.messageId}) {
                                //TODO what ??
                                    
                            }
                            //to prevent listener to add messages to unreadsection
                            //that found in previous section with the same date
                            else if let grouped = groupedMessagesUpdated2,
                                    grouped.messages.contains(where: {$0.messageId == newMessage.messageId}) {
                                //TODO what ??
                            }
                            else {
                                if self.isScroll2 {  //load data at first time .. no need to this
                                    groupedMessagesUpdated.messages.append(newMessage)
                                    let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                    self.groupedMessagesTest[index] = groupedMessagesUpdated
                                    self.groupedMessages = self.groupedMessagesTest
                                }
                                else if self.isMessageSent { //send new message
                                    groupedMessagesUpdated.messages.insert(newMessage, at: 0)
//                                    let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                    self.groupedMessagesTest[0] = groupedMessagesUpdated
                                    self.groupedMessages = self.groupedMessagesTest
                                    self.insertNewRowOrSectionForSend()
                                }
                                else {  //other user receive new messsage
                                    groupedMessagesUpdated.messages.insert(newMessage, at: 0)
                                    let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                    self.groupedMessagesTest[index] = groupedMessagesUpdated
                                    self.groupedMessages = self.groupedMessagesTest
                                    print("kkkkk888888")
                                    self.insertNewRowOrSectionForSend()
                                }
                            }
                        }
                        //add new group
                        else {
                            let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                            if self.isScroll2 { //load data at first time
                                self.groupedMessagesTest.append(newGroup)
                                self.groupedMessages = self.groupedMessagesTest
                            }
                            else if self.isMessageSent {  //send new message with new group
                                self.groupedMessagesTest.insert(newGroup, at: 0)
                                self.groupedMessages = self.groupedMessagesTest
                                self.insertNewRowOrSectionForSend()
                            }
                            else { //other user receive new messsage with new group
                                self.groupedMessagesTest.insert(newGroup, at: 0)
                                self.groupedMessages = self.groupedMessagesTest
                                self.insertNewRowOrSectionForSend()
                            }
                        }
                    }
                }
                
                //Mark:- removed messages
                else if docChange.type == .removed && self.isDeleted == true {
                    print("removed : 2222222")
                    //no need to reload table
                    //better solution is to redraw cell with tail
                    //redraw the last cell with tail
                    let indexPath = IndexPath(row: 0, section: 0)
                    let cell = self.chatTable.cellForRow(at: indexPath) as? MessageCell
                    let message = self.groupedMessages[indexPath.section].messages[indexPath.row]
                    cell?.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
                    cell?.messageBubbleView.setNeedsDisplay()
                }
                
                //Mark:- modified messages
                else if docChange.type == .modified && self.isModified == false {
                    let modifiedDoc = docChange.document
                    let modifiedData = modifiedDoc.data()
                    
                    var newMessage: Message!
                    if let messageSender = modifiedData["sender"] as? String,
                       let messageBody = modifiedData["body"] as? String,
                       let sendTime = modifiedData["sendTime"] as? TimeInterval,
                       let roomId = modifiedData["roomId"] as? String {
                        
                        //temporary solution
                        if let messageId = modifiedData["messageId"] as? String {
                            newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: modifiedData["messageStatus"] as? String ?? nil, messageId: messageId)
                        }else {
                            newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: modifiedData["messageStatus"] as? String ?? nil, messageId: "")
                        }
                    }
                    
                    for i in 0..<self.groupedMessages.count {
                        for j in 0..<self.groupedMessages[i].messages.count {
                            if self.groupedMessages[i].messages[j].messageId == modifiedDoc.documentID {
                                self.groupedMessages[i].messages[j].messageState = newMessage?.messageState
                                self.groupedMessagesTest = self.groupedMessages
                                let cell = self.chatTable.cellForRow(at: IndexPath(row: j, section: i)) as! MessageCell
                                
                                if newMessage?.messageState == "delivered" {
                                    cell.imageViewCheckMark2.alpha = 1
                                    cell.imageViewCheckMark2.tintColor = .systemGray4
                                }
                                else if newMessage?.messageState == "seen" {
                                    cell.imageViewCheckMark2.alpha = 1
                                    cell.imageViewCheckMark.tintColor = .green
                                    cell.imageViewCheckMark2.tintColor = .green
                                }
                                break 
                            }
                        }
                    }
                    self.isModified = true
                }
                
                //TODO you may need one step from other func of listener during deleting data??
            })
            
            //reload chat table at start
            if !self.groupedMessages.isEmpty {
                print("kkkkk22222222222")
                if self.isScroll2 == true  && self.isPushingBackgroundNotificationToApp == true { //at start
                    DispatchQueue.main.async {
                        print("kkkkk4444444444")
                        self.chatTable.reloadData()
                        self.isScroll2 = false
                        
                    }
                }
            }
            
            self.isScroll2 = false
        }
    }
    
}

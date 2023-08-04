//
//  UserMessagesViewController+FetchMessages.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 04/02/2023.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

extension UserMessagesViewController {
    
    //test other user online state
    func fetchOtherUserState() {
        onlineStateListener = db.collection("users").document(otherUser.email).addSnapshotListener { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let snapshot2 = snapshot,
                      let data = snapshot2.data(),
                      let state = data["state"] as? String else {return}
                if state == "online" {
                    //online state
                    self.customViewForLeftBarButton.stateLabel.text = "online"
                }
                else {
                    //offline state
                    guard let offlineTime = data["stateTime"] as? TimeInterval else {return}
                    let time = Date(timeIntervalSince1970: offlineTime)
                    let dayMonth = time.formatted(.dateTime.month(.abbreviated).day())
                    let dayWeek = time.formatted(.dateTime.weekday(.wide))
                    let hour = time.formatted(.dateTime.hour(.defaultDigits(amPM: .wide)).minute(.twoDigits))
                    
                    if Locale.current.calendar.isDateInToday(time) {
                        let stringOff = String(format: "last seen today at %@", hour)
                        self.customViewForLeftBarButton.stateLabel.text = stringOff
                    }
                    else if Locale.current.calendar.isDateInYesterday(time) {
                        let stringOff = String(format: "last seen yesterday at %@", hour)
                        self.customViewForLeftBarButton.stateLabel.text = stringOff
                    }
                    else if let lastWeekDate = Locale.current.calendar.date(byAdding: .weekOfMonth, value: -1, to: Date()), lastWeekDate > time {
                        let stringOff = String(format: "last seen %@ at %@", dayMonth, hour)
                        self.customViewForLeftBarButton.stateLabel.text = stringOff
                    }
                    else {
                        let stringOff = String(format: "last seen %@ at %@", dayWeek, hour)
                        self.customViewForLeftBarButton.stateLabel.text = stringOff
                    }
                }
                
            }
        }
    }
    
    
    //get data from notification
//    func getMessagesFirstTime(chatRoomId: String, onChange: (([GroupedMessages])->Void)?) {
//
//        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
//        db.collection("users").document(currentUserEmail).collection("chatRooms")
//            .document(chatRoomId).collection("roomMessages")
//            .order(by: "sendTime", descending: true).limit(to: 40).getDocuments(source: .cache) { querySnapshot, error in
//            //handle error
//            if let error2 = error {
//                print("error is: \(error2.localizedDescription)")
//                return
//            }
//
//            guard let snapshot = querySnapshot else { return }
//
//            print("doc changes count 88 : \(snapshot.documentChanges.count)")
//            snapshot.documentChanges.forEach({ docChange in
//
//                //Mark:- start case or add message
//                if docChange.type == .added && self.isDeleted == false {
//                    let doc = docChange.document
//                    print("added : 11111111")
//                    let data = doc.data()
//                    if let messageSender = data["sender"] as? String,
//                       let messageBody = data["body"] as? String,
//                       let sendTime = data["sendTime"] as? TimeInterval,
//                       let roomId = data["roomId"] as? String,
//                       let messageId = data["messageId"] as? String {
//
//                        let messageState = data["messageState"] as? String ?? nil
//
//                        let newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: messageState, messageId: messageId)
//
//                        //handle messages grouped by date
//                        let date = Date(timeIntervalSince1970: sendTime)
//                        let dateFormat = date.formatted(.dateTime.year().month().day())
//
//                        if self.groupedMessagesTest.isEmpty {
//                            let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
//                            self.groupedMessagesTest.append(newGroup)
//                            print("added : 222222222")
//                        }
//                        //group message found
//                        else if self.groupedMessagesTest.contains(where: {$0.date == dateFormat}) {
//                            let groupedMessagesArrWithDateString = self.groupedMessagesTest.filter({$0.date == dateFormat})
//                            var groupedMessagesUpdated = groupedMessagesArrWithDateString[0]
//
//                            if groupedMessagesUpdated.messages.contains(where: {$0.messageId == newMessage.messageId}) {
//                                //TODO what ??
//                            }
//                            else {
//                                groupedMessagesUpdated.messages.append(newMessage)
//                                let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
//                                self.groupedMessagesTest[index] = groupedMessagesUpdated
//                                print("added : 3333333")
//                            }
//                        }
//                        //add new group
//                        else {
//                            let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
//                            self.groupedMessagesTest.append(newGroup)
//                        }
//
//                    }
//                }
//            })
//            self.groupedMessages = self.groupedMessagesTest
//            onChange?(self.groupedMessages)
//        }
//    }

    
    
    //get all undelivered notifications data
//    func getAllNewMessages(newMessagesCount: Int, otherUser: User, RoomId: String, completion: @escaping (([Message])->Void)) {
//        let query = self.db.collection("users").document(otherUser.email).collection("chatRooms").document(RoomId).collection("roomMessages").whereField("messageState", isNotEqualTo: "seen")
//        query.getDocuments(source: .server) { snapshot, error in
//            if let error2 = error {
//                print(error2.localizedDescription)
//            }
//            else {
//                guard let docs = snapshot?.documents else {return}
//                for doc in docs {
//                    let data = doc.data()
//                    if let messageSender = data["sender"] as? String,
//                       let messageBody = data["body"] as? String,
//                       let sendTime = data["sendTime"] as? TimeInterval,
//                       let roomId = data["roomId"] as? String,
//                       let messageId = data["messageId"] as? String {
//                        
//                        let messageState = data["messageState"] as? String ?? nil
//                        
//                        let newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: messageState, messageId: messageId)
//                        self.messages.append(newMessage)
//                    }
//                }
//                let messages2 = self.messages.sorted {$0.sendTime > $1.sendTime}
//                completion(messages2)
//            }
//        }
//    }
    
    
    //get all undelivered notifications data
    func getAllNewMessages(newMessagesCount: Int, currentUserEmail: String, RoomId: String, completion: @escaping (([Message])->Void)) {
        let query = self.db.collection("users").document(currentUserEmail).collection("chatRooms").document(RoomId).collection("roomMessages").order(by: "sendTime", descending: true).limit(to: newMessagesCount)
        query.getDocuments(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let docs = snapshot?.documents else {return}
                for doc in docs {
                    let data = doc.data()
                    if let messageSender = data["sender"] as? String,
                       let messageBody = data["body"] as? String,
                       let sendTime = data["sendTime"] as? TimeInterval,
                       let roomId = data["roomId"] as? String,
                       let messageId = data["messageId"] as? String {
                        
                        let messageState = data["messageState"] as? String ?? nil
                        
                        let newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: messageState, messageId: messageId)
                        self.messages.append(newMessage)
                    }
                }
//                let messages2 = self.messages.sorted {$0.sendTime > $1.sendTime}
                completion(self.messages)
            }
        }
    }
    
    
    //get data from notification
    func getMessagesFirstTimeFromCach(chatRoomId: String, onChange: (([GroupedMessages], IndexPath?)->Void)?) {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        db.collection("users").document(currentUserEmail).collection("chatRooms")
            .document(chatRoomId).collection("roomMessages")
            .order(by: "sendTime", descending: true).limit(to: 40).getDocuments(source: .cache) { querySnapshot, error in
            //handle error
            if let error2 = error {
                print("error is: \(error2.localizedDescription)")
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            print("doc changes count 88 : \(snapshot.documentChanges.count)")
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
                            print("added : 222222222")
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
                                print("added : 3333333")
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
                self.groupedMessages = self.groupedMessagesTest
                onChange?(self.groupedMessages, self.indexForEdit ?? nil)
        }
    }
    
    //get data from notification
    func getMessagesFirstTimeFromServer(newMessages: [Message], deliveredMC: Int, chatRoomId: String, onChange: (([GroupedMessages], IndexPath?)->Void)?) {
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        db.collection("users").document(currentUserEmail).collection("chatRooms")
            .document(chatRoomId).collection("roomMessages")
            .order(by: "sendTime", descending: true).limit(to: 40).getDocuments(source: .server) { querySnapshot, error in
            //handle error
            if let error2 = error {
                print("error is: \(error2.localizedDescription)")
                return
            }
            
            guard let snapshot = querySnapshot else { return }
            
            print("doc changes count 88 : \(snapshot.documentChanges.count)")
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
                            print("added : 222222222")
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
                                print("added : 3333333")
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
                
                if deliveredMC > 0 {
                    for i in 0..<self.groupedMessagesTest.count {
                        for j in 0..<self.groupedMessagesTest[i].messages.count {
                            if newMessages[newMessages.count - 1].messageId == self.groupedMessagesTest[i].messages[j].messageId {
                                let indexPath = IndexPath(row: j + 1, section: i)
                                self.indexForEdit = indexPath
                                let messageForUnreadCell = Message(roomId: "", sender: "", body: "UnReadMessages", sendTime: self.messages[self.messages.count - 1].sendTime)
                                self.groupedMessagesTest[i].messages.insert(messageForUnreadCell, at: j + 1)
                                break
                            }
                        }
                    }
                }
                self.groupedMessages = self.groupedMessagesTest
                onChange?(self.groupedMessages, self.indexForEdit ?? nil)
        }
    }
    

    func loadMessagesFromFirestoreWithListener() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        //Mark:- listner for normal start
        cloudFirestoreQuery = db.collection("users")
            .document(currentUserEmail).collection("chatRooms")
            .document(chatRoomDocumentID!).collection("roomMessages").order(by: "sendTime", descending: true).limit(to: 40)
        messagesListener = cloudFirestoreQuery.addSnapshotListener { querySnapshot, error in
                //handle error
                if let error2 = error {
                    print("errrrrr: \(error2.localizedDescription)")
                    return
                }
                
                print("is scroll2: \(self.isScroll2)")
                print("keyboard is displayed: \(self.keyboardIsDisplayed)")
                
                guard let snapshot = querySnapshot else { return }
                
                snapshot.documentChanges.forEach({ docChange in
                    print("doc changes count: \(snapshot.documentChanges.count)")
                    print("doc change type: \(docChange.type)")
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
                            
                            if self.groupedMessagesTest.isEmpty {
                                let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                self.groupedMessagesTest.append(newGroup)
                                self.groupedMessages = self.groupedMessagesTest
                                self.insertNewRowOrSectionForSend()
                            }
                            //group message found
                            else if self.groupedMessagesTest.contains(where: {$0.date == dateFormat}) {
                                let groupedMessagesArrWithDateString = self.groupedMessagesTest.filter({$0.date == dateFormat})
                                
                                //TODO try to handle this when add unread messages section??
                                
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
                                    if self.isScroll2 {  //load data at first time
                                        groupedMessagesUpdated.messages.append(newMessage)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                    }
                                    else if self.isMessageSent { //send new message
                                        groupedMessagesUpdated.messages.insert(newMessage, at: 0)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                        self.insertNewRowOrSectionForSend()
                                    }
                                    //when come new messages and the user in the main page(chat rooms)
                                    //good thinking to use delivered messages count not state to use it one time
                                    else if self.isScroll2 == false && self.deliveredMessagesCount > 0 {
                                        self.messages.append(newMessage)
                                        print("unread 222222222")
                                        groupedMessagesUpdated.messages.insert(newMessage, at: 0)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        let messages = groupedMessagesUpdated.messages.sorted { $0.sendTime > $1.sendTime }
                                        groupedMessagesUpdated.messages = messages
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                    }
                                    
                                    else {
                                        //other user receive new messsage and chat is opened
                                        groupedMessagesUpdated.messages.insert(newMessage, at: 0)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                        print("kkkkkkk44")
                                        self.insertNewRowOrSectionForSend()
                                    }
                                }
                            }
                            //add new group
                            else {
                                //(done)
                                //TODO handle new group coming when sending messages with
                                //new group and the user in the main page(chat rooms)
                                //and app is crashed when send one message with new group like I said below
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
                                else {
                                    //other user receive new messsage with new group
                                    self.groupedMessagesTest.insert(newGroup, at: 0)
                                    self.groupedMessages = self.groupedMessagesTest
                                    if self.deliveredMessagesState {
                                        self.messages.append(newMessage)
                                    }else {
                                        self.insertNewRowOrSectionForSend()
                                    }
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
                        if !self.groupedMessages.isEmpty {
                            let lastMessage = self.groupedMessages[0].messages[0]
                            self.updateChatRoomForCurrentUser(lastMessage: lastMessage, state: lastMessage.messageState ?? "")
                            let room = ChatRoom(id: lastMessage.roomId, lastMessage: lastMessage.body, lastMessageTime: lastMessage.sendTime, otherUserEmial: self.otherUser.email, otherUserFirstName: self.otherUser.firstName, otherUserLastName: self.otherUser.lastName, senderLastMessage: lastMessage.sender, messageId: lastMessage.messageId, messageState: lastMessage.messageState, deliveredMessagesCount: 0)
                            self.onChange(room)
                            
                            let indexPath = IndexPath(row: 0, section: 0)
                            let cell = self.chatTable.cellForRow(at: indexPath) as? MessageCell
                            let message = self.groupedMessages[indexPath.section].messages[indexPath.row]
                            cell?.messageBubbleView.checkMessageSender(message: message, drawWithTail: true)
//                            cell?.messageBubbleView.layer.setNeedsDisplay()
                            
                            UIView.animate(withDuration: 0.4) {
                                cell?.messageBubbleView.layer.setNeedsDisplay()
                                cell?.layer.setNeedsLayout()
                                self.view.layer.setNeedsLayout()
                            }
                            
                        }
                            
                    }
                    
                    
                    //Mark:- fetch old messages when delete rows
                    else if docChange.type == .added && self.isDeleted == true {
                        let doc = docChange.document
                        print("added after delete : 22222222")
                        self.documentStart = snapshot.documents.last //document to start paginating from
                        let data = doc.data()
//                        let id = doc.documentID
                        if let messageSender = data["sender"] as? String,
                           let messageBody = data["body"] as? String,
                           let sendTime = data["sendTime"] as? TimeInterval,
                           let roomId = data["roomId"] as? String {
                            
                            //temporary solution
                            var newMessage: Message!
                            if let messageId = data["messageId"] as? String {
                                //TODO try to fix room id here
                                newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: data["messageStatus"] as? String ?? nil, messageId: messageId)
                            }else {
                                newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: data["messageStatus"] as? String ?? nil, messageId: "")
                            }
//                            print("new message id: \(newMessage.messageId)")
                            //handle messages grouped by date
                            let date = Date(timeIntervalSince1970: sendTime)
                            let dateFormat = date.formatted(.dateTime.year().month().day())
                            
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
                                    let sec = self.groupedMessages.count - 1
                                    let row = self.groupedMessages[sec].messages.count - 1
                                    //handle data in other user after delete and listener load old messsages
                                    if self.groupedMessages[sec].messages[row].sendTime > sendTime {
                                        groupedMessagesUpdated.messages.append(newMessage)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                        self.insertRowOrSectionForDeleteAndNextBatch()
                                    }
                                    else { //handle data in other user after delete and receive new message
                                        groupedMessagesUpdated.messages.insert(newMessage, at: 0)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
                                        self.insertNewRowOrSectionForSend()
                                    }
                                }
                            }
                            //add new group
                            
                            //TODO need to handle data in other user after delete
                            //and receive new message with new section
                            
                            else {
                                let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                self.groupedMessagesTest.append(newGroup)
                                self.groupedMessages = self.groupedMessagesTest
                                self.insertRowOrSectionForDeleteAndNextBatch()
                            }
                        }
                    }
                    
                    //Mark:- modified messages  //I think..no need to isModified var again ??
                    else if docChange.type == .modified && self.isModified == false {
                        print("data modified 9090909090")
                        let modifiedDoc = docChange.document
                        let modifiedData = modifiedDoc.data()
                        
                        var newMessage: Message!
                        if let messageSender = modifiedData["sender"] as? String,
                           let messageBody = modifiedData["body"] as? String,
                           let sendTime = modifiedData["sendTime"] as? TimeInterval,
                           let roomId = modifiedData["roomId"] as? String {
                            
                            //temporary solution
                            if let messageId = modifiedData["messageId"] as? String {
                                newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: modifiedData["messageState"] as? String ?? nil, messageId: messageId)
                            }else {
                                newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: modifiedData["messageState"] as? String ?? nil, messageId: "")
                            }
                        }
                        for i in 0..<self.groupedMessages.count {
                            for j in 0..<self.groupedMessages[i].messages.count {
                                if self.groupedMessages[i].messages[j].messageId == modifiedDoc.documentID {
                                    self.groupedMessages[i].messages[j].messageState = newMessage?.messageState
                                    self.groupedMessagesTest = self.groupedMessages
                                    let cell = self.chatTable.cellForRow(at: IndexPath(row: j, section: i)) as! MessageCell
                                    
                                    if newMessage?.messageState == "delivered" {
                                        cell.imageViewCheckMark2?.alpha = 1
                                        cell.imageViewCheckMark2?.tintColor = .systemGray4
                                    }
                                    else if newMessage?.messageState == "seen" {
                                        cell.imageViewCheckMark2?.alpha = 1
                                        cell.imageViewCheckMark?.tintColor = .green
                                        cell.imageViewCheckMark2?.tintColor = .green
                                    }
                                    break
                                }
                            }
                        }
//                        self.isModified = true
                    }
                })
                
                //reload chat table at start
                if !self.groupedMessages.isEmpty {
                    print("kkkkk22222222222")
                    if self.isScroll2 == true && self.deliveredMessagesCount > 0 && self.isPushingBackgroundNotificationToApp == false { //at start
                        DispatchQueue.main.async {
                            print("kkkkk4444444444")
                            self.chatTable.reloadData()
                            //these two functions need to trigger viewWillLayoutSubviews()
                            //after reload table to hide pinned header at start
//                            self.view.layoutIfNeeded()
//                            self.view.setNeedsLayout()
//                            self.keyboardIsDisplayed = true
                            self.isScroll2 = false
                            
                        }
                    }
                }
                
//                //unread messages
//                //good thinking to use delivered messages count not state to use it one time
//                if self.isScroll2 == false && self.deliveredMessagesCount > 0 {
//                    var messages2 = [Message]()
//                    for j in 0...self.groupedMessagesTest[0].messages.count - 1 {
//                        if self.messages[self.messages.count - 1].messageId == self.groupedMessagesTest[0].messages[j].messageId {
//                            for message in self.groupedMessagesTest[0].messages[0...j] {
//                                messages2.append(message)
//                                self.groupedMessagesTest[0].messages.remove(at: 0)
//                            }
//                            let time = messages2[messages2.count - 1].sendTime
//                            let date = Date(timeIntervalSince1970: time)
//                            let dateFormat = date.formatted(.dateTime.year().month().day())
//                            let groupNotification = GroupedMessages(date: dateFormat, messages: messages2)
//                            self.groupedMessagesTest.insert(groupNotification, at: 0)
//                            break
//                        }
//                    }
//                    self.groupedMessages = self.groupedMessagesTest
//                    DispatchQueue.main.async {
//                        self.chatTable.reloadData()
//                        self.messages = []
//                    }
//                }
            
            //new
//            if self.isScroll2 == false && self.deliveredMessagesCount > 0 {
//                for i in 0..<self.groupedMessagesTest.count {
//                    for j in 0..<self.groupedMessagesTest[i].messages.count {
//                        if self.messages[self.messages.count - 1].messageId == self.groupedMessagesTest[i].messages[j].messageId {
//                            let indexPath = IndexPath(row: j + 1, section: i)
//                            self.indexForEdit = indexPath
//                            let messageForUnreadCell = Message(roomId: "", sender: "", body: "UnReadMessages", sendTime: self.messages[self.messages.count - 1].sendTime)
//                            self.groupedMessagesTest[i].messages.insert(messageForUnreadCell, at: j + 1)
//                            break
//                        }
//                    }
//                }
//                self.groupedMessages = self.groupedMessagesTest
//                DispatchQueue.main.async {
//                    self.chatTable.reloadData()
//                    self.messages = []
//                }
//            }
                
            self.isScroll2 = false
            if self.deliveredMessagesCount > 0 {
                self.deliveredMessagesState = true
            }
        }
    }
    
    
    
    //add new row or section for send message
    func insertNewRowOrSectionForSend() {
        self.chatTable.performBatchUpdates {
            if self.groupedMessages.first?.messages.count == 1 {
                //add new section
                let indexSet = IndexSet(arrayLiteral: 0)
                self.chatTable.insertSections(indexSet, with: .top)
            }
            //add new row
            self.chatTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .top)
            print("row is inserted successfully! 90909090")
        }
        //redraw the previous cell without tail
        let indexPath = IndexPath(row: 1, section: 0)
        let indexPath2 = IndexPath(row: 0, section: 0)
        if self.groupedMessages[indexPath.section].messages.count > 1 { //not excute when inserting new section with one message
            let cell = self.chatTable.cellForRow(at: indexPath) as? MessageCell
            let message = self.groupedMessages[indexPath.section].messages[indexPath.row]
            cell?.messageBubbleView.checkMessageSender(message: message, drawWithTail: false)
            if self.groupedMessages[indexPath2.section].messages[indexPath2.row].sender == message.sender {
                cell?.messageBubbleView.setNeedsDisplay()
                print("uuuuuuuuuuuu")
            }
        }
    }

    //insert row or section for deletion
    func insertRowOrSectionForDeleteAndNextBatch() {
        let groupsCount = groupedMessages.count - 1
        let rowCount = groupedMessages[groupsCount].messages.count - 1
        let indexPath = IndexPath(row: rowCount, section: groupsCount)
        UIView.performWithoutAnimation {
            self.chatTable.performBatchUpdates {
                if self.groupedMessages[groupsCount].messages.count == 1 {
                    //add new section
                    let indexSet = IndexSet(arrayLiteral: groupsCount)
                    self.chatTable.insertSections(indexSet, with: .top)
                }
                //add new row
                self.chatTable.insertRows(at: [indexPath], with: .top)
                print("row is inserted successfully! 67676767676767")
            }
        }
        
    }
    
    
    //load next batch of messages
    @objc func loadNextBatch() {
        print("Mark:- load next batch")
        isFetching = true
        guard let document = documentStart else {
            return
        }
        cloudFirestoreQuery.start(afterDocument: document).getDocuments { querySnapshot, error in
            if let err = error {
                print("there is an error in retrieving data from firestore, \(err) ")
            }else {
                if let querySnapshot2 = querySnapshot?.documents {
                    
                    //to know the value of document start
                    if let lastDocument = querySnapshot2.last {
                        self.documentStart = lastDocument //document to start paginating from
                        self.chatTable.tableFooterView?.alpha = 1
                        print("document999999: \(self.documentStart!)")
                        
                        for doc in querySnapshot2 {
                            let data = doc.data()
                            let id = doc.documentID
                            if let messageSender = data["sender"] as? String,
                               let messageBody = data["body"] as? String,
                               let sendTime = data["sendTime"] as? TimeInterval,
                               let roomId = data["roomId"] as? String {
                                
                                //temporary solution
                                var newMessage: Message!
                                if let messageId = data["messageId"] as? String {
                                    //TODO try to fix room id here
                                    newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: data["messageState"] as? String ?? nil, messageId: messageId)
                                }else {
                                    newMessage = Message(roomId: roomId, sender: messageSender, body: messageBody, sendTime: sendTime, messageState: data["messageState"] as? String ?? nil, messageId: "")
                                }
                                
                                //handle messages grouped by date
                                let date = Date(timeIntervalSince1970: sendTime)
                                let dateFormat = date.formatted(.dateTime.year().month().day())
                                
                                if self.groupedMessagesTest.isEmpty {
                                    let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                    self.groupedMessagesTest.append(newGroup)
                                    self.groupedMessages = self.groupedMessagesTest
//                                    let oldContentOffsetY = self.chatTable.contentSize.height - self.chatTable.frame.height
                                    self.insertRowOrSectionForDeleteAndNextBatch()
//                                    self.chatTable.contentOffset.y = oldContentOffsetY
                                }
                                //group message found
                                else if self.groupedMessagesTest.contains(where: {$0.date == dateFormat}) {
                                    let groupedMessagesArrWithDateString = self.groupedMessagesTest.filter({$0.date == dateFormat})
                                    var groupedMessagesUpdated = groupedMessagesArrWithDateString[0]
                                    
                                    if groupedMessagesUpdated.messages.contains(where: {$0.roomId == id}) {
                                        //TODO what ??
                                    }
                                    else {
                                        groupedMessagesUpdated.messages.append(newMessage)
                                        let index = self.groupedMessagesTest.firstIndex(where: {$0.date == dateFormat})!
                                        self.groupedMessagesTest[index] = groupedMessagesUpdated
                                        self.groupedMessages = self.groupedMessagesTest
//                                        let oldContentOffsetY = self.chatTable.contentSize.height - self.chatTable.frame.height
                                        self.insertRowOrSectionForDeleteAndNextBatch()
                                        print("next .. next 99999")
//                                        self.chatTable.contentOffset.y = oldContentOffsetY
                                    }
                                }
                                else {
                                    let newGroup = GroupedMessages(date: dateFormat, messages: [newMessage])
                                    self.groupedMessagesTest.append(newGroup)
                                    self.groupedMessages = self.groupedMessagesTest
//                                    let oldContentOffsetY = self.chatTable.contentSize.height - self.chatTable.frame.height
                                    self.insertRowOrSectionForDeleteAndNextBatch()
                                    print("next .. next 666666")
//                                    self.chatTable.contentOffset.y = oldContentOffsetY
                                }
                            }
                        }
                        //configure sorted array
//                        for i in 0...self.groupedMessagesTest.count - 1 {
//                            let messages = self.groupedMessagesTest[i].messages.sorted {$0.sendTime > $1.sendTime}
//                            self.groupedMessagesTest[i].messages = messages
//                        }
//                        self.groupedMessages = self.groupedMessagesTest
//                        let oldContentOffsetY = self.chatTable.contentSize.height - self.chatTable.frame.height
                        
                        
                        let dispatchWork = DispatchWorkItem {
//                            self.chatTable.reloadData()
                            
                            
                            //Mark:-> for reversed table
//                            self.chatTable.contentOffset.y = oldContentOffsetY
//                            self.isFetching = false
                            
//                            self.chatTable.tableFooterView = nil
                            
                        }
                        
//                        let dispatchWork2 = DispatchWorkItem {
//                            self.removePinnedHeadersAfterScroll()
//                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000), execute: dispatchWork)
//                        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1200), execute: dispatchWork2)
                    }
                    else {
//                        self.documentStart = nil
                        self.chatTable.tableFooterView = nil
                    }
                }
            }
        }
    }
    

    //get current user data
    func getCurrentUserData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        db.collection("users").document(currentUserEmail).getDocument { querySnapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                if let qSnapshot = querySnapshot?.data(){
                    let firstName = qSnapshot["firstName"] as! String
                    let lastName = qSnapshot["lastName"] as! String
                    let email = qSnapshot["email"] as! String
                    let profilePictureString = qSnapshot["profilePicture"] as! String
                    self.currentUser = User(email: email, firstName: firstName, lastName: lastName, profilePictureString: profilePictureString)
                    print(self.currentUser.email)
                    
                }
            }
        }
    }
    
    //configure conversation
    func configureChatRoomForCurrentUser(lastMessage: Message) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        guard let id = chatRoomDocumentID else {
            print("chat document id is nil")
            return }
        
        //add chat room to current user
        self.db.collection("users")
            .document(currentUserEmail)  
            .collection("chatRooms")
            .document(id)
            .setData(["id": id,
                      "lastMessage": lastMessage.body,
                      "lastMessageSendTime": lastMessage.sendTime,
                      "sender": lastMessage.sender,
                      "otherUserEmail": self.otherUser.email,
                      "otherUserFirstName": self.otherUser.firstName,
                      "otherUserLastName": self.otherUser.lastName,
                      "messageId": lastMessage.messageId,
                      "messageState": "sent",
                      "deliveredMessagesCount": 0])
    }
    
    func configureChatRoomForOtherUser(lastMessage: Message, deliveredMessagesCount: Int) {
        //add chat room to other user
        let chatRoomId2 = ("\(otherUser.email)_\(currentUser.email)")
        self.db.collection("users")
            .document("\(self.otherUser.email)")
            .collection("chatRooms")
            .document(chatRoomId2)
            .setData(["id": chatRoomId2,
                      "lastMessage": lastMessage.body,
                      "lastMessageSendTime": lastMessage.sendTime,
                      "sender": lastMessage.sender,
                      "otherUserEmail": self.currentUser.email,
                      "otherUserFirstName": self.currentUser.firstName,
                      "otherUserLastName": self.currentUser.lastName,
                      "messageId": lastMessage.messageId,
                      "messageState": "",
                      "deliveredMessagesCount": deliveredMessagesCount])
        
    }
    
    
    //update conversations
    func updateChatRoomForCurrentUser(lastMessage: Message, state: String) {
        //add chat room to current user
        self.db.collection("users")
            .document(currentUser.email)  //TODO handle this
            .collection("chatRooms")
            .document(chatRoomDocumentID)
            .updateData(["lastMessage": lastMessage.body,
                         "lastMessageSendTime": lastMessage.sendTime,
                         "sender": lastMessage.sender,
                         "messageId": lastMessage.messageId,
                         "messageState": state])
        
    }
    
    func updateChatRoomForOtherUser(lastMessage: Message, deliveredMessagesCount: Int) {
        //add chat room to other user
        let chatRoomId2 = ("\(otherUser.email)_\(currentUser.email)")
        self.db.collection("users")
            .document("\(self.otherUser.email)")
            .collection("chatRooms")
            .document(chatRoomId2)
            .updateData(["lastMessage": lastMessage.body,
                         "lastMessageSendTime": lastMessage.sendTime,
                         "sender": lastMessage.sender,
                         "messageId": lastMessage.messageId,
                         "messageState": "",
                         "deliveredMessagesCount": deliveredMessagesCount]) { error in
                if let error2 = error {
                    print(error2.localizedDescription)
                    print("there is no chat room with this id!")
                }
            }
                
    }
    
    //configure ref for storage
    //upload profile photo
    func uploadProfilePhotoInStorage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        guard let image = UIImage(named: "Mahmoud") else { return }
        let storageRef = storage.reference(withPath: "users/\(userId)/profilePictureFile/profilePicture.jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { downloadMetadata, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }else {
                if let downloadMetadata2 = downloadMetadata {
                    print("put is completed and got this \(downloadMetadata2)")
                    self.dowmloadprofilePicUrl(from: storageRef)
                }
            }
        }
    }
    
    func dowmloadprofilePicUrl(from storage: StorageReference) {
        storage.downloadURL { url, error in
            if let error2 = error {
                print(error2.localizedDescription)
                return
            }
            if let url2 = url {
                print("url is: \(url2.absoluteString)")
                self.db.collection("users").document("\(self.currentUser.email)").updateData(["profilePicture": url2.absoluteString]) { error in
                    if let error2 = error {
                        print(error2.localizedDescription)
                        return
                    }
                }
            }
        }
    }
    
    //download profile photo for current user
    func downloadProfilePhotoFromStorage() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let storageRef = storage.reference(withPath: "users/\(userId)/profilePictureFile/profilePicture.jpg")
        storageRef.getData(maxSize: 4 * 1024 * 1024) { [weak self] data, error in
            if let error2 = error {
                print(error2.localizedDescription)
                return
            }
            else {
                if let data2 = data {
                    DispatchQueue.main.async {
                        self?.otherUserPhotoAndNameView.otherUserProfileImageView.image = UIImage(data: data2) //TODO should handle this
                    }
                }
            }
        }
    }
}

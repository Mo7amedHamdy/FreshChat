//
//  ChatsViewController+FetchRooms.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 29/07/2023.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

extension ChatsViewController {
    
    //fetch chat rooms with listener2
    func fetchchatRoomsWithListener2() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        chatRoomslistener = db.collection("users").document(currentUserEmail).collection("chatRooms").order(by: "lastMessageSendTime", descending: true).addSnapshotListener { querySnapshot, error in
//            self.rooms = []
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                if let qSnapShot = querySnapshot {
                    qSnapShot.documentChanges.forEach { docChange in
                        
                        //Mark:- Room Added
                        if docChange.type == .added {
                            print("doc added")
                            let docData = docChange.document.data()
                            guard let id = docData["id"] as? String,
                                  let lastMessage = docData["lastMessage"] as? String,
                                  let email = docData["otherUserEmail"] as? String,
                                  let firstName = docData["otherUserFirstName"] as? String,
                                  let lastName = docData["otherUserLastName"] as? String,
                                  let lastMessageTime = docData["lastMessageSendTime"] as? TimeInterval,
                                  let sender = docData["sender"] as? String,
                                  let messageId = docData["messageId"] as? String,
                                  let messageState = docData["messageState"] as? String,
                                  let deliveredMessagesCount = docData["deliveredMessagesCount"] as? Int  else {return}
                            
                            let room = ChatRoom(id: id,
                                                lastMessage: lastMessage,
                                                lastMessageTime: lastMessageTime,
                                                otherUserEmial: email,
                                                otherUserFirstName: firstName,
                                                otherUserLastName: lastName,
                                                senderLastMessage: sender,
                                                messageId: messageId,
                                                messageState: messageState,
                                                deliveredMessagesCount: deliveredMessagesCount)
                            
                            if !self.rooms.contains(where: {$0.id == room.id}) {
                                if self.isFetching == false { //first load
                                    self.rooms.append(room)
                                }
                                //listener to add new room
                                else if self.isFetching == true {
                                    let indexPath = IndexPath(row: 0, section: 0)
                                    self.chatsTableView.performBatchUpdates {
                                        self.rooms.insert(room, at: 0)
                                        self.chatsTableView.insertRows(at: [indexPath], with: .none)
                                    }
                                    let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell
                                    if deliveredMessagesCount > 0 {
//                                        cell?.lastMessageLabel.font = UIFont.systemFont(ofSize: 19, weight: .bold)
//                                        cell?.lastMessageLabel.textColor = .black
                                        cell?.lastMessageLabel.text = room.lastMessage
                                        cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                        cell?.configureNonCheck()
//                                        cell?.notificationCountLabel.alpha = 1
                                        UIView.animate(withDuration: 0.2) {
                                            cell?.notificationCountLabel.transform = .identity
                                        }
                                        cell?.notificationCountLabel.text = "\(room.deliveredMessagesCount)"
                                    }else {
//                                        cell?.lastMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//                                        cell?.lastMessageLabel.textColor = #colorLiteral(red: 0.4761645794, green: 0.4775262475, blue: 0.4954573512, alpha: 1)
                                        cell?.lastMessageLabel.text = room.lastMessage
                                        cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                        cell?.configureNonCheck()
//                                        cell?.notificationCountLabel.alpha = 0
                                        cell?.notificationCountLabel.transform = CGAffineTransform(translationX: 40, y: 0)
                                    }
                                }
                            }
                        }
                        
                        
                        
                        //Mark:- Room Modified
                        else if docChange.type == .modified && self.newRoom == nil {
                            //doc modified
                            print("doc modified ooooooooooo")
                            guard let index = self.rooms.firstIndex(where: {$0.id == docChange.document.documentID}) else {return}
                            let indexPath = IndexPath(row: index, section: 0)
                            
                            let docData = docChange.document.data()
                            guard let id = docData["id"] as? String,
                                  let lastMessage = docData["lastMessage"] as? String,
                                  let email = docData["otherUserEmail"] as? String,
                                  let firstName = docData["otherUserFirstName"] as? String,
                                  let lastName = docData["otherUserLastName"] as? String,
                                  let lastMessageTime = docData["lastMessageSendTime"] as? TimeInterval,
                                  let sender = docData["sender"] as? String,
                                  let messageId = docData["messageId"] as? String,
                                  let messageState = docData["messageState"] as? String,
                                  let deliveredMessagesCount = docData["deliveredMessagesCount"] as? Int  else {return}
                            
                            let room = ChatRoom(id: id,
                                                lastMessage: lastMessage,
                                                lastMessageTime: lastMessageTime,
                                                otherUserEmial: email,
                                                otherUserFirstName: firstName,
                                                otherUserLastName: lastName,
                                                senderLastMessage: sender,
                                                messageId: messageId,
                                                messageState: messageState,
                                                deliveredMessagesCount: deliveredMessagesCount)
                            
                            //message sender
                            if sender == currentUserEmail {
//                                self.rooms[indexPath.row] = room
                                let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell
                                cell?.lastMessageLabel.text = room.lastMessage
                                cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                self.checkLastMessageState(for: room, with: indexPath)
                                
                                //TODO like message receiver
                                if self.rooms[indexPath.row].lastMessageTime != room.lastMessageTime {
                                    //add new message
                                    if self.rooms[indexPath.row].lastMessageTime < room.lastMessageTime {
//                                        cell?.lastMessageLabel.text = room.lastMessage
//                                        cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
//                                        self.checkLastMessageState(for: room, with: indexPath)
                                        
                                        if indexPath.row != 0 {
                                            self.chatsTableView.performBatchUpdates {
                                                self.rooms.remove(at: indexPath.row)
                                                self.rooms.insert(room, at: 0)
                                                self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                                            }
                                        }
                                        else {
                                            self.rooms[indexPath.row] = room
                                        }
                                    }
                                    //delete message
//                                    else if self.rooms[indexPath.row].lastMessageTime > room.lastMessageTime {
////                                        if self.rooms.count > 1 {
//                                            for i in 0..<self.rooms.count {
//                                                if self.rooms[i].lastMessageTime < room.lastMessageTime {
//                                                    self.rooms.remove(at: indexPath.row)
//                                                    self.rooms.insert(room, at: i - 1)
//                                                    self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: i - 1, section: 0))
//                                                    break
//                                                }
//                                            }
//                                            self.rooms[indexPath.row] = room
////                                        }
//                                    }
                                }
                                //no change in last message .. no add or delete message
                                else {
                                    print("doc modified successfully")
//                                    cell?.lastMessageLabel.text = room.lastMessage
//                                    cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
//                                    self.checkLastMessageState(for: room, with: indexPath)
                                    self.rooms[indexPath.row] = room
                                }
                                
                            }
                            
                            //message receiver
                            else if sender == email { //email is other user email
                                print("count from room property: \(room.deliveredMessagesCount) 4444444444")
                                //notifications
                                if deliveredMessagesCount > 0 {
                                    let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell
//                                    cell?.lastMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//                                    cell?.lastMessageLabel.textColor = .black
                                    cell?.lastMessageLabel.text = room.lastMessage
                                    cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                    cell?.configureNonCheck()
//                                    cell?.notificationCountLabel.alpha = 1
                                    UIView.animate(withDuration: 0.2) {
                                        cell?.notificationCountLabel.transform = .identity
                                        cell?.notificationCountLabel.text = "\(room.deliveredMessagesCount)"
                                    }
                                    self.chatsTableView.performBatchUpdates {
                                        if indexPath.row != 0 {
                                            self.rooms.remove(at: indexPath.row)
                                            self.rooms.insert(room, at: 0)
                                            self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                                        }else {
                                            self.rooms[indexPath.row] = room
                                        }
                                    }
                                    
                                }
                                
                                else {
                                    //cancel bold font
                                    let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell
                                    
                                    if self.rooms[indexPath.row].lastMessageTime != room.lastMessageTime {
                                        //add new message
                                        if self.rooms[indexPath.row].lastMessageTime < room.lastMessageTime {
//                                            cell?.lastMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//                                            cell?.lastMessageLabel.textColor = #colorLiteral(red: 0.4761645794, green: 0.4775262475, blue: 0.4954573512, alpha: 1)
                                            cell?.lastMessageLabel.text = room.lastMessage
                                            cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                            cell?.configureNonCheck()
//                                            cell?.notificationCountLabel.alpha = 0
                                            cell?.notificationCountLabel.transform = CGAffineTransform(translationX: 40, y: 0)
                                            self.chatsTableView.performBatchUpdates {
                                                if indexPath.row != 0 {
                                                    self.rooms.remove(at: indexPath.row)
                                                    self.rooms.insert(room, at: 0)
                                                    self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: 0, section: 0))
                                                }else {
                                                    self.rooms[indexPath.row] = room
                                                }
                                            }
                                        }
                                        
                                        //delete message
//                                        else if self.rooms[indexPath.row].lastMessageTime > room.lastMessageTime {
//                                            if self.rooms.count > 1 {
//                                            for i in 0..<self.rooms.count {
//                                                if self.rooms[i].lastMessageTime < room.lastMessageTime {
//                                                    self.rooms.remove(at: indexPath.row)
//                                                    self.rooms.insert(room, at: i - 1)
//                                                    self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: i - 1, section: 0))
//                                                    break
//                                                }
//                                            }
//                                            self.rooms[indexPath.row] = room
//                                            }
//                                        }
                                    }
                                    else {
//                                        cell?.lastMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
//                                        cell?.lastMessageLabel.textColor = #colorLiteral(red: 0.4761645794, green: 0.4775262475, blue: 0.4954573512, alpha: 1)
                                        cell?.lastMessageLabel.text = room.lastMessage
                                        cell?.timeLabel.text = self.configureDateFormat(room.lastMessageTime)
                                        cell?.configureNonCheck()
//                                        cell?.notificationCountLabel.alpha = 0
                                        cell?.notificationCountLabel.transform = CGAffineTransform(translationX: 40, y: 0)
                                        self.rooms[indexPath.row] = room
                                    }
                                }
                            }
                        }
                        
                        //Mark:- room removed
                        else if docChange.type == .removed {
                            //doc removed
                            print("doc removed")
                            let docData = docChange.document.data()
                            guard let id = docData["id"] as? String,
                                  let lastMessage = docData["lastMessage"] as? String,
                                  let email = docData["otherUserEmail"] as? String,
                                  let firstName = docData["otherUserFirstName"] as? String,
                                  let lastName = docData["otherUserLastName"] as? String,
                                  let lastMessageTime = docData["lastMessageSendTime"] as? TimeInterval,
                                  let sender = docData["sender"] as? String,
                                  let messageId = docData["messageId"] as? String,
                                  let messageState = docData["messageState"] as? String,
                                  let deliveredMessagesCount = docData["deliveredMessagesCount"] as? Int  else {return}
                            
                            let room = ChatRoom(id: id,
                                                lastMessage: lastMessage,
                                                lastMessageTime: lastMessageTime,
                                                otherUserEmial: email,
                                                otherUserFirstName: firstName,
                                                otherUserLastName: lastName,
                                                senderLastMessage: sender,
                                                messageId: messageId,
                                                messageState: messageState,
                                                deliveredMessagesCount: deliveredMessagesCount)
                            
                            for i in 0..<self.rooms.count {
                                if self.rooms[i].id == room.id {
                                    let indexPath = IndexPath(row: i, section: 0)
                                    self.chatsTableView.performBatchUpdates {
                                        self.rooms.remove(at: i)
                                        self.chatsTableView.deleteRows(at: [indexPath], with: .automatic)
                                        print("doc is removed successfully")
                                    }
                                    break
                                }
                            }
                            
                        }
                    }
                }
                
            //Mark:- first start needs load table
                if self.isFetching == false {
                    DispatchQueue.main.async {
                        self.chatsTableView.reloadData()
                        self.isFetching = true
                    }
                }
            }
        }
    }
}

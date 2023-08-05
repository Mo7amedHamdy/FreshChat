//
//  ChatsTableViewEx.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 25/10/2022.
//

import UIKit
import FirebaseAuth


extension ChatsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatRoomCell", for: indexPath) as! ChatRoomCell
        cell.separatorInset = UIEdgeInsets(top: 0, left: 80, bottom: 0, right: 0)
        let room = rooms[indexPath.row]
        let id = room.id
        cell.idRef = id
        let mail = room.otherUserEmial
        let userName = room.otherUserFirstName + " " + room.otherUserLastName
        let lastMessage = room.lastMessage
        
        //other user name
        cell.otherUserName.text = userName.capitalized
        
        //last messsage time
        let lastMessageTimeInterval = room.lastMessageTime
        let lastMessageTimeString = configureDateFormat(lastMessageTimeInterval)
        cell.timeLabel.text = lastMessageTimeString
        
        //last message state
        if room.senderLastMessage != room.otherUserEmial && room.messageState != nil {
            cell.lastMessageLabel.text = lastMessage
            cell.lastMessageLabel.decideTextDirection()
            let state = room.messageState
            if state == "sent" { //TODO this with enum and switch cases
                cell.configureSentCheck()
            }
            else if state == "delivered" {
                cell.configuredeliveredCheck()
            }
            else if state == "seen" {
                cell.configureSeenCheck()
            }

        }
        else { //TODO try to handle this 
            if room.deliveredMessagesCount > 0 {
//                cell.lastMessageLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
//                cell.lastMessageLabel.textColor = #colorLiteral(red: 0.4761645794, green: 0.4775262475, blue: 0.4954573512, alpha: 1)
                cell.lastMessageLabel.text = lastMessage
                cell.lastMessageLabel.decideTextDirection()
                cell.configureNonCheck()
                UIView.animate(withDuration: 0.2) {
//                    cell.notificationCountLabel.alpha = 1
                    UIView.animate(withDuration: 0.2) {
                        cell.notificationCountLabel.transform = .identity
                    }
                    cell.notificationCountLabel.text = "\(room.deliveredMessagesCount)"
                }
            }
            else{
                cell.lastMessageLabel.text = lastMessage
                cell.lastMessageLabel.decideTextDirection()
                cell.configureNonCheck()
                cell.notificationCountLabel.transform = CGAffineTransform(translationX: 40, y: 0)
//                cell.notificationCountLabel.alpha = 0
            }
        }
        
        //profile picture
        cell.otherUserImage.image = UIImage(systemName: "person.circle.fill")
        
        getProfilePicListener(userEmail: mail) { newProfilePictureString in
            if cell.idRef == room.id {
                if let url = URL(string: newProfilePictureString) {
                    let item = Item(email: "",
                                    firstName: "",
                                    lastName: "",
                                    name: "",
                                    imageUrlString: "",
                                    image: UIImage(systemName: "person.circle.fill")!,
                                    url: url)
                    UrlCachedImages().getCachedImage(url: url , item: item) { fetchedItem, image in
                        if let img = image, img != fetchedItem.image {
                            cell.otherUserImage.image = img
                        }
                    }
                }
            }
            else {
                cell.otherUserImage.image = UIImage(systemName: "person.circle.fill")
            }
        }
        return cell
    }
    
        
    //time interval into date
    func configureDateFormat(_ time: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: time)
        let timeText = date.formatted(date: .omitted, time: .shortened)
        let dayText = date.formatted(.dateTime.month(.abbreviated).day())
        let dayText2 = date.formatted(.dateTime.weekday(.wide))
        if Locale.current.calendar.isDateInToday(date) {
            return String(format: "%@", timeText)
        }
        else if let lastWeekDate = Locale.current.calendar.date(byAdding: .weekOfMonth, value: -1, to: Date()), lastWeekDate > date {
            return String(format: "%@", dayText)
        }
        else {
            return String(format: "%@", dayText2)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        let room = rooms[indexPath.row]
        otherUser = createOtherUser(room: room)
        chatRoomDocumentId = room.id
//        let roomId2 = "\(otherUser.email)_\(currentUserEmail)"
        deliveredMessagesCount = room.deliveredMessagesCount
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "messages") as? UserMessagesViewController
        
        if deliveredMessagesCount > 0 { //there are notifications
            vc?.getAllNewMessages(newMessagesCount: self.deliveredMessagesCount, currentUserEmail: currentUserEmail, RoomId: self.chatRoomDocumentId, completion: { newCommingMessages in
                vc?.getMessagesFirstTimeFromServer(newMessages: newCommingMessages, deliveredMC: self.deliveredMessagesCount, chatRoomId: self.chatRoomDocumentId, onChange: { newGroupedMessages, index in
                    self.groupedMessagesT = newGroupedMessages
                    self.indexT = index
                    self.performSegue(withIdentifier: "toChatMessages", sender: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                        self.chatsTableView.deselectRow(at: indexPath, animated: true)
                    }
                })
            })
        }
        else {  //notification == 0
            vc?.getMessagesFirstTimeFromCach(chatRoomId: self.chatRoomDocumentId, onChange: { newGroupedMessages, index in
                self.groupedMessagesT = newGroupedMessages
                self.indexT = index
                self.performSegue(withIdentifier: "toChatMessages", sender: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                    self.chatsTableView.deselectRow(at: indexPath, animated: true)
                }
            })
        }
    }

    //create other user
    func createOtherUser(room: ChatRoom)-> User {
        let userArr = otherUsersData.filter { user in
            user.email == room.otherUserEmial
        }
        let user = userArr[0]
        return user
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? UserMessagesViewController {
            des.otherUser = otherUser
            des.chatRoomDocumentID = chatRoomDocumentId
            des.groupedMessages = groupedMessagesT
            des.groupedMessagesTest = groupedMessagesT
            des.deliveredMessagesCount = deliveredMessagesCount
            des.indexForEdit = indexT
            des.onChange = { newRoom in
                self.newRoom = newRoom
            }
        }
    }
}

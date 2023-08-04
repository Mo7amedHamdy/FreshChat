//
//  ChatRoom.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 22/10/2022.
//

import UIKit

struct ChatRoom {
    var id: String
    var id2: String?
    var lastMessage: String
    var lastMessageTime: TimeInterval
    var otherUserEmial: String
    var otherUserFirstName: String
    var otherUserLastName: String
    var senderLastMessage: String?
    var messageId: String?
    var messageState: String?
    var deliveredMessagesCount: Int
    var otherUserPresent: String?  //check if other user is present in chat room
}

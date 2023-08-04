//
//  Message.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 28/07/2022.
//

import UIKit

struct Message: Equatable {
    var roomId: String
    var sender: String
    var body: String
//    var currentUserEmail: String
//    var otherUserEmail: String
//    var otherUserFirstName: String
//    var otherUserLastName: String
    var sendTime: TimeInterval
    var messageState: String?
    var messageId = UUID().uuidString
}

//
//  NotificationService.swift
//  NotificationServiceExtension
//
//  Created by Mohamed Hamdy on 19/06/2023.
//

import UserNotifications
import FirebaseMessaging
import FirebaseFirestore
import FirebaseFunctions
import FirebaseAuth
import FirebaseCore
import Network

var data = [[String: Any]]()

class NotificationService: UNNotificationServiceExtension {
        
    lazy var functions = Functions.functions()
    lazy var db = Firestore.firestore()
                        
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    let defaults = UserDefaults(suiteName: "group.mohamed.FreshChat")
    
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
       
        FirebaseApp.configure()
                
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        var count: Int = defaults?.value(forKey: "count") as! Int
        print("count is: \(count)")
        if let bestAttemptContent2 = bestAttemptContent {
            bestAttemptContent2.title = "\(bestAttemptContent!.title) "
            bestAttemptContent2.body = "\(bestAttemptContent!.body) "
            bestAttemptContent2.badge = count as NSNumber
            count = count + 1
            defaults?.set(count, forKey: "count")
            
            //get data  get only last notification unfortunately
            guard let userInfoAps = bestAttemptContent2.userInfo["aps"] as? [String: Any],
                  let userInfoAlert = userInfoAps["alert"] as? [String: Any],
                  let body = userInfoAlert["body"] as? String,
                  let messageId = bestAttemptContent2.userInfo["messageId"] as? String,
                  let currentUserEmail = bestAttemptContent2.userInfo["currentUserEmail"] as? String,
                  let otherUserEmail = bestAttemptContent2.userInfo["otherUserEmail"] as? String,
                  let chatRoomIdCU = bestAttemptContent2.userInfo["chatRoomId"] as? String,
                  let sendTime = bestAttemptContent2.userInfo["sendTime"] as? String else {
                return
            }
            //remove previous notifications data
            if bestAttemptContent2.badge == 1 {
                data.removeAll()
                print("data is removed completely!")
            }
            
            data.append(["messageId": messageId, "body": body, "sendTime": sendTime])

            let pref = UserDefaults.init(suiteName: "group.mohamed.FreshChat")
            pref?.set(data, forKey: "notification")
            
            print("badge: \(bestAttemptContent2.badge!)")
            print("body: \(body)")
            
            //call functions
            let chatRoomIdOU = "\(otherUserEmail)_\(currentUserEmail)"
            let dataToSend = ["messageId": messageId,
                              "currentUserEmail": currentUserEmail,
                              "otherUserEmail": otherUserEmail,
                              "chatRoomIdCU": chatRoomIdCU,
                              "chatRoomIdOU": chatRoomIdOU,
                              "badgeNumber":bestAttemptContent2.badge!] as [String : Any]
            
            
            //for delivered messages
            functions.httpsCallable("oncall").call(dataToSend) { result, error in
                if let error2 = error {
                    print("error is: \(error2.localizedDescription)")
                }
                else {
                    print("successfully 989898989898!")
                }
            }
                        
            contentHandler(bestAttemptContent2)
            
        }
        
    }
    
    override func serviceExtensionTimeWillExpire() {

        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
}

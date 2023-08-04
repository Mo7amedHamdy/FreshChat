//
//  AppDelegate.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 26/07/2022.
//

import UIKit
import CoreData
import FirebaseFirestore
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import FirebaseFunctions

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    lazy var functions = Functions.functions()
    var db: Firestore!
//    var settings = FirestoreSettings()
    var groupedMessagesForNotifications = [GroupedMessages]()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        db = Firestore.firestore()
        
//        settings.isPersistenceEnabled = false
//        db.settings = settings

        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        //ask permission
        center.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("notification succeeded")
            }
        }
        
        //register for remote notification
        UIApplication.shared.registerForRemoteNotifications()
        
        //firebase messaging
        Messaging.messaging().delegate = self
                        
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }


    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "FreshChat")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    //for background notifications to update app with new data at background
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        print(userInfo)
//
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(identifier: "messages") as? UserMessagesViewController else { return }
//        guard let firstName = userInfo["firstName"] as? String else { return }
//        guard let lastName = userInfo["lastName"] as? String else { return }
//        guard let email = userInfo["email"] as? String else { return }
//        guard let profilePicString = userInfo["profilePicture"] as? String else { return }
//        guard let chatRoomId = userInfo["chatRoomId"] as? String else { return }
//        guard let messageId = userInfo["messageId"] as? String else { return }
////        guard let sendTime = userInfo["sendTime"] as? String else { return }
//
//
//        let otherUser = User(email: email, firstName: firstName, lastName: lastName, profilePictureString: profilePicString)
//        vc.otherUser = otherUser
//        vc.chatRoomDocumentID = chatRoomId
//        vc.isPushingBackgroundNotificationToApp = true
//        guard let userInfoAps = userInfo["aps"] as? [String: Any],
//        let userInfoAlert = userInfoAps["alert"] as? [String: Any],
//        let body = userInfoAlert["body"] as? String else {
//            return
//        }
//        print(body)
//
//        print("00000000000000000")
//
//        //data from notification
//        let pref = UserDefaults.init(suiteName: "group.mohamed.FreshChat")
//        guard let dataNot = pref?.value(forKey: "notification") as? [[String: String]] else {return}
//        print("data notification count: \(dataNot.count)")
//        var dataNot2 = [[String:String]]()
//
//        print("11111111111111111111")
//
////        functions.httpsCallable("deliveredMessage").call(["messageId": messageId]) { result, error in
////            if let error2 = error {
////                print("error is: \(error2.localizedDescription)")
////            }
////            else {
////                print("successfully !")
////            }
////        }
//
//        //query in firestore to fetch documents it's message state is sent only
//        let query = db.collection("conversations").document(chatRoomId).collection("messages_\(email)").whereField("messageStatus", isEqualTo: "sent") //if you wanna use order here you should use the same paramter in whereField
//        query.getDocuments(source: .server) { snapshot, error in
//            if let error2 = error {
//                print(error2.localizedDescription)
//            }
//            else {
//                guard let snap = snapshot else {return}
//                let docs = snap.documents
//                print("222222222222222222")
//                //phone reconnect with net (from disconnect mode)
//                if docs.count > 1 {
//                    print("33333333333333333333")
//                    for dat in dataNot {
//                        for doc in docs {
//                            let data = doc.data()
//                            guard let messageId2 = data["messageId"] as? String else {return}
//                            guard let messageBody = data["body"] as? String else {return}
//                            guard let messageSendTime = data["sendTime"] as? TimeInterval else {return}  //time is interval not string
//
//                            self.db.collection("conversations").document(chatRoomId).collection("messages_\(email)").document(messageId2).updateData(["messageStatus": "delivered"])
//
//                            if dat["messageId"] == messageId2 {
//                                dataNot2.insert(dat, at: 0)
//                            }else {
//                                let datNew = ["messageId": messageId2, "body": messageBody, "sendTime": "\(messageSendTime)"]
//                                dataNot2.append(datNew)
//                            }
//                        }
//                    }
//                    print("data notification count00: \(dataNot.count)")
//                    pref?.set(dataNot2, forKey: "notification")
//                }
//
//                //phone connected to net
//                else if docs.count == 1 {
//                    print("444444444444444444")
//                    self.db.collection("conversations").document(chatRoomId).collection("messages_\(email)").document(messageId).updateData(["messageStatus": "delivered"])
//                }
//
//            }
//        }
//
//        completionHandler(.newData)
//    }
    
    
    //get delivered messages count for current user (receiver notification)
    func getDeliveredMessagesCountForCurrentUser(roomId: String, completion: @escaping (Int)->Void) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        let query = self.db.collection("users").document(currentUserEmail).collection("chatRooms").document(roomId)
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

    
    //get all undelivered notifications data
//    func getAllUnSeenNotifications(user: User, RoomId: String, completion: @escaping (([[String: String]])->Void)) {
//        let pref = UserDefaults.init(suiteName: "group.mohamed.FreshChat")
//        guard var dataNotify = pref?.value(forKey: "notification") as? [[String: String]] else {return}
//        dataNotify.removeAll()
//        let query = self.db.collection("users").document(user.email).collection("chatRooms").document(RoomId).collection("roomMessages").whereField("messageState", isNotEqualTo: "seen")
//        query.getDocuments(source: .server) { snapshot, error in
//            if let error2 = error {
//                print(error2.localizedDescription)
//            }
//            else {
//                guard let docs = snapshot?.documents else {return}
//                for doc in docs {
//                    let data = doc.data()
//                    guard let messageId = data["messageId"] as? String,
//                          let sendTime = data["sendTime"] as? Double,
//                          let body = data["body"] as? String else {return}
//                    let sendTimeStr = String(sendTime)
//                    dataNotify.append(["messageId": messageId, "body": body, "sendTime": sendTimeStr])
//                }
//                print("dataNotify.count: \(dataNotify.count)")
//                pref?.set(dataNotify, forKey: "notification")
//                completion(dataNotify)
//            }
//        }
//    }
    
    //open UserMessagesViewController
    private func coordinateToUserMessagesVC(userInfo: [String: Any]) {
        guard let window = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.window else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "messages") as? UserMessagesViewController else { return }
        guard let tabbarController = window.rootViewController as? UITabBarController else { return }
        guard let navController = tabbarController.selectedViewController as? UINavigationController else { return }

        guard let firstName = userInfo["firstName"] as? String else { return }
        guard let lastName = userInfo["lastName"] as? String else { return }
        guard let email = userInfo["otherUserEmail"] as? String else {return }
        guard let profilePicString = userInfo["profilePicture"] as? String else { return }
        guard let chatRoomIdCU = userInfo["chatRoomId"] as? String else { return }

        let otherUser = User(email: email, firstName: firstName, lastName: lastName, profilePictureString: profilePicString)
//        let chatRoomIdOU = "\(otherUser.email)_\(currentUserEmail)"
        vc.otherUser = otherUser
        vc.chatRoomDocumentID = chatRoomIdCU
        vc.isPushingBackgroundNotificationToApp = true
        vc.isScroll2 = true
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        getDeliveredMessagesCountForCurrentUser(roomId: chatRoomIdCU) { count in
            vc.getAllNewMessages(newMessagesCount: count, currentUserEmail: currentUserEmail, RoomId: chatRoomIdCU) { newCommingMessages in
                vc.getMessagesFirstTimeFromServer(newMessages: newCommingMessages, deliveredMC: count, chatRoomId: chatRoomIdCU) { newGroupedMessages, index in
                    vc.indexForEdit = index
                    vc.groupedMessages = newGroupedMessages
                    vc.deliveredMessagesCount = count
                    navController.pushViewController(vc, animated: true)
                }
            }
        }
        
        
//        getAllUnSeenNotifications(user: otherUser, RoomId: chatRoomIdOU) { data in
//            vc.getMessagesThroughNotification { newGroupedMessages, index in
//                vc.groupedMessages = newGroupedMessages  //need handle this to accelerate data load
//                vc.indexForEdit = index
//                navController.pushViewController(vc, animated: true)
//            }
//        }
    }
}


//MARK: - user notification
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    //handle notification when app in foreground
    //    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
    //        let userInfo = notification.request.content.userInfo
    //        print("user info: \(userInfo)")
    //        return [[.sound]]
    //    }
    
    //handle users action with notification
//    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
//        let userInfo = response.notification.request.content.userInfo
//        print("user info 2: \(userInfo)")
//        UIApplication.shared.applicationIconBadgeNumber = 0
//    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        guard let userInfo = response.notification.request.content.userInfo as? [String: Any] else { return }
        coordinateToUserMessagesVC(userInfo: userInfo)
        completionHandler()
    }
}


//MARK: - firebase messaging delegate
extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        messaging.token { token, error in
            guard let token2 = token else { return }
            print("token: \(token2)")
            
            //save fcmToken in user defaults
            if let _ = UserDefaults.standard.string(forKey: "fcmToken"){
                print("fcm token is found")
                return
            }else {
                print("fcm token not found")
                UserDefaults.standard.set(token2, forKey: "fcmToken")
            }
        }
    }
    
    
}


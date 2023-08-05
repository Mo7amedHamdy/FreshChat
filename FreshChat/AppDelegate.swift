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
    
    //MARK: - get notification data
    
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


//MARK: - handle user notifications

extension AppDelegate: UNUserNotificationCenterDelegate {
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


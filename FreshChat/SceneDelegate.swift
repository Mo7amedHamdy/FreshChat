//
//  SceneDelegate.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 26/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var sceenInBack: Bool = false

    var window: UIWindow?
    
    var db = Firestore.firestore()
    
    func changeRootVC(_ rootVC: UIViewController) {
        if let window = self.window {
            window.rootViewController = rootVC
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil)
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
//        guard let userActivity = connectionOptions.userActivities.first ?? session.stateRestorationActivity else { return }

    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
        
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        print("active")
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        
        
        UserDefaults(suiteName: "group.mohamed.FreshChat")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
        print("badge count is changed 90909090909090")
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).updateData(["state": "online",
                                                                      "stateTime": Date().timeIntervalSince(.now)])
        
        if sceenInBack == true {
            db.collection("users").document(currentUserEmail).collection("chatRooms").whereField("present", isEqualTo: "suspended").getDocuments(source: .server) { snapshot, error in
                if let error2 = error {
                    print(error2.localizedDescription)
                }
                else {
                    guard let snap = snapshot else {return}
                    guard let docId = snap.documents.first?.documentID else {
                        print("doc is nil")
                        return}
                    self.updatePresentFieldActive(with: docId, and: currentUserEmail)
                }
            }
        }

        
    }

    func sceneWillResignActive(_ scene: UIScene) {
        
        sceenInBack = true
        UserDefaults(suiteName: "group.mohamed.FreshChat")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).updateData(["state": "offline",
                                                                      "stateTime": Date().timeIntervalSince1970])

        db.collection("users").document(currentUserEmail).collection("chatRooms").whereField("present", isEqualTo: "true").getDocuments(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let snap = snapshot else {return}
                guard let docId = snap.documents.first?.documentID else {
                    print("doc is nil")
                    return}
                self.updatePresentFieldResign(with: docId, and: currentUserEmail)
            }
        }
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        print("foreground")
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).updateData(["state": "online",
                                                                      "stateTime": Date().timeIntervalSince(.now)])
    
        
    }
    
    func updatePresentFieldActive(with roomId: String, and currentUserEmail: String) {
        db.collection("users").document(currentUserEmail).collection("chatRooms").document(roomId).updateData(["present": "true"])
    }
    
    func updatePresentFieldResign(with roomId: String, and currentUserEmail: String) {
        db.collection("users").document(currentUserEmail).collection("chatRooms").document(roomId).updateData(["present": "suspended"])
    }
    
    

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        

        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).updateData(["state": "offline",
                                                                      "stateTime": Date().timeIntervalSince1970])
        
        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    
    //Mark:- state restoration
    
    func stateRestorationActivity(for scene: UIScene) -> NSUserActivity? {
        return scene.userActivity
    }

}


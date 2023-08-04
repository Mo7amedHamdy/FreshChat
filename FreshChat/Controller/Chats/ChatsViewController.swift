//
//  ChatsViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 15/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class ChatsViewController: UIViewController {
    
    var newRoom: ChatRoom!
    var groupedMessagesT: [GroupedMessages]!
    var indexT: IndexPath!
    
    var isComingNewAlert: Bool = false
    
    var deliveredMessagesCount: Int!
    
    var isFetching: Bool = false
        
    let db = Firestore.firestore()
    var userslistener: ListenerRegistration!
    var chatRoomslistener: ListenerRegistration!
    var profilePictureListener: ListenerRegistration!
    var currentUserListener: ListenerRegistration!
    
    var storage = Storage.storage()
    
    var chatRoomDocumentId: String!
    var chatRoomDocumentId2: String!
    
    var rooms = [ChatRoom]()
        
    var otherUser: User!
    
    var currentUser: [String: Any]!
        
    
    @IBOutlet weak var chatsTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        //handle this with clousers to get chat rooms after signing in ??
        
        if Auth.auth().currentUser == nil {
            //open login controller
            let welcomeVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "welcome")
            welcomeVC.modalPresentationStyle = .fullScreen
            present(welcomeVC, animated: false)
        }
                
        chatsTableView.register(UINib(nibName: "ChatRoomCell", bundle: nil), forCellReuseIdentifier: "chatRoomCell")
        chatsTableView.delegate = self
        chatsTableView.dataSource = self
        
        fetchchatRoomsWithListener2()
        
    }
    
    //Mark:- view will appear
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        fetchchatRoomsWithListener()
        if currentUser == nil {
            fetchCurrentUserData()
        }
        
        //to make present field that equal suspended for curent user in any chat room false
        getPresentFieldSuspended()
    }
    
    
    //Mark:- view did appear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if otherUsersData.isEmpty {
            loadUsers()
        }
        
        //in case new sign in
        if chatRoomslistener == nil {
            fetchchatRoomsWithListener2()
            chatsTableView.reloadData()
        }
        
        //state of current user
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).updateData(["state": "online",
                                                                      "stateTime": Date().timeIntervalSince(.now)])
        
        if self.newRoom != nil {
            updateChatRoomForDeleteMesages()
        }
        
    }
    
    func updateChatRoomForDeleteMesages() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1500)){
            //cell dat
            for i in 0..<self.rooms.count {
                if self.rooms[i].id == self.newRoom.id {
                    let indexPath = IndexPath(row: i, section: 0)
                    let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell
                    cell?.lastMessageLabel.text = self.newRoom.lastMessage
                    let lastMessageTimeString = self.configureDateFormat(self.newRoom.lastMessageTime)
                    cell?.timeLabel.text = lastMessageTimeString
                    if self.newRoom.senderLastMessage == currentUserEmail {
                        self.checkLastMessageState(for: self.newRoom, with: indexPath)
                    }else {
                        cell?.configureNonCheck()
                    }
                    
                    if self.rooms[i].lastMessageTime != self.newRoom.lastMessageTime {
                        if self.rooms[i].lastMessageTime > self.newRoom.lastMessageTime {
                            let d = i + 1
                            for j in d..<self.rooms.count {
                                if self.rooms[j].lastMessageTime < self.newRoom.lastMessageTime {
                                    if j == 1 {
                                        self.rooms[i] = self.newRoom
                                        self.newRoom = nil
//                                        break
                                    }else{
                                        self.chatsTableView.performBatchUpdates {
                                            self.rooms.remove(at: i)
                                            self.rooms.insert(self.newRoom, at: j - 1)
                                            self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: j - 1, section: 0))
                                            self.newRoom = nil
                                        }
//                                        break
                                    }
                                    break
                                }
                            }
                            //one room only found or room have less time
                            if self.newRoom != nil {
                                if self.rooms.count > 1 {
                                    let roomsCount = self.rooms.count - 1
                                    self.chatsTableView.performBatchUpdates {
                                        self.rooms.remove(at: i)
                                        self.rooms.insert(self.newRoom, at: roomsCount)
                                        self.chatsTableView.moveRow(at: indexPath, to: IndexPath(row: roomsCount, section: 0))
                                        self.newRoom = nil
                                    }
//                                    break
                                }
                                else {
                                    self.rooms[i] = self.newRoom
                                    self.newRoom = nil
//                                    break
                                }
                            }
                        }
                    }
                    break
                }
            }
        }
    }
    
    //get present field that suspended
    func getPresentFieldSuspended() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        db.collection("users").document(currentUserEmail).collection("chatRooms").whereField("present", isEqualTo: "suspended").getDocuments(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let snap = snapshot else {return}
                guard let docId = snap.documents.first?.documentID else {
                    print("doc is nil")
                    return}
                self.updatePresentFieldDisconnect(with: docId, and: currentUserEmail)
            }
        }
    }
    
    //update present in chat room to false
    func updatePresentFieldDisconnect(with roomId: String, and currentUserEmail: String) {
        db.collection("users").document(currentUserEmail).collection("chatRooms").document(roomId).updateData(["present": "false"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentUser != nil {
            currentUserListener.remove()
        }
//        chatRoomslistener.remove()
    }
    
    
    //check message state
    func checkLastMessageState(for room: ChatRoom, with indexPath: IndexPath) {
        guard let state = room.messageState else {
            print("kkkkkk4444488888888")
            return}
        guard let cell = self.chatsTableView.cellForRow(at: indexPath) as? ChatRoomCell else { return }
        if state == "sent" { //TODO this with enum and switch cases
            cell.configureSentCheck()
        }
        else if state == "delivered" {
            cell.configuredeliveredCheck()
        }
        else if state == "seen" {
            print("seeeeeeeeeeen")
            cell.configureSeenCheck()
        }
    }
    

    //firestore listener on profile picture
    func getProfilePicListener(userEmail: String, completion: @escaping (String)->Void) {
        db.collection("users").whereField("email", isEqualTo: userEmail).addSnapshotListener({ qsnap, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                if let docs = qsnap?.documentChanges {
                    for docChanged in docs {
                        let doc = docChanged.document
                        let data = doc.data()
                        let urlString = data["profilePicture"] as! String
                        completion(urlString)
                    }
                }
            }
        })
    }
    
          
    //TODO pass the selected user by using closure
    @IBAction func didPressComposeButton(_ sender: Any) {
        let vc = UsersViewController (usersData: otherUsersData){ newUser in
            self.otherUser = newUser
            for room in self.rooms {
                if room.otherUserEmial == self.otherUser.email {
                    return
                }
            }
            
//            let room = ChatRoom(id: "", lastMessage: "", otherUserEmial: newUser.email, otherUserFirstName: newUser.firstName, otherUserLastName: newUser.lastName,otherUserProfilePicture: newUser.profilePicture, otherUserProfilePictureString: newUser.profilePictureString)
//            self.rooms.append(room)
//            DispatchQueue.main.async {
//                self.chatsTableView.reloadData()
//            }
            let work = DispatchWorkItem {
                let vcNewUserMessages = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "messages") as! UserMessagesViewController
                vcNewUserMessages.otherUser = newUser
                vcNewUserMessages.isStartNewChat = true
                self.navigationController?.pushViewController(vcNewUserMessages, animated: true)
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100), execute: work)
                       
        }
        let nav = UINavigationController(rootViewController: vc)
        present(nav, animated: true)
    }
    
    
    //load users
    var otherUsersData = [User]()
    func loadUsers() {
        //TODO search bar to search about user to chat with by email
        
        userslistener = db.collection("users").order(by: "firstName", descending: false).addSnapshotListener({ querysnapshot, error in
            self.otherUsersData = []
            if let error2 = error {
                print(error2.localizedDescription)
            }else {
                guard let currentUser = Auth.auth().currentUser else {
                    print("Sorry, No one is signed in !")
                    return }
                if let qSnapshotDocs = querysnapshot?.documents {
                    for doc in qSnapshotDocs {
                        let otherUser = doc.data()
                        let otherUserEmail = otherUser["email"] as! String
                        let otherUserFirstName = otherUser["firstName"] as! String
                        let otherUserLastName = otherUser["lastName"] as! String
                        let otherUserProfilePictureString = otherUser["profilePicture"] as! String
                        
                        let other = User(email: otherUserEmail, firstName: otherUserFirstName, lastName: otherUserLastName, profilePictureString: otherUserProfilePictureString)
                        if other.email != currentUser.email {
                            self.otherUsersData.append(other)
                        }
                    }
                }
            }
        })
    }
    
    
    //get current user data
    func fetchCurrentUserData() {
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        currentUserListener = db.collection("users").document(currentUserEmail).addSnapshotListener { DocSnapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }else {
                if let data = DocSnapshot?.data() {
                    let firstName = data["firstName"] as! String
                    let lastName = data["lastName"] as! String
                    let email = data["email"] as! String
                    let proPicUrlStr = data["profilePicture"] as! String
                    self.currentUser = ["firstName": firstName,
                                               "lastName": lastName,
                                               "email": email,
                                               "profilePicStr": proPicUrlStr]
//                    UserDefaults.standard.set(self.currentUser, forKey: "currentUser")
                    
                    //save personal info
                    self.savePersonalInfo(for: self.currentUser)
                }
            }
        }
    }
    
    
    //save personal info
    func savePersonalInfo(for currentUser: [String: Any]) {
        let urlString = currentUser["profilePicStr"] as! String
        let firstName = currentUser["firstName"] as! String
        let lastName = currentUser["lastName"] as! String
        let name = firstName + " " + lastName
        let email = currentUser["email"] as! String
        if let url = URL(string: urlString) {
            let item = Item(email: "",
                            firstName: "",
                            lastName: "",
                            name: "",
                            imageUrlString: "",
                            image: UIImage(systemName: "person.circle.fill")!,
                            url: url)
            UrlCachedImages().getCachedImage(url: url , item: item) { fetchedItem, image in
                if let img = image, img != fetchedItem.image {
                    guard let data = img.pngData() else { return }
                    UserDefaults.standard.set(data, forKey: "profilePicture")
                }
            }
        }
        else {
            let img = UIImage(systemName: "person.circle.fill")
            guard let data = img?.pngData() else { return }
            UserDefaults.standard.set(data, forKey: "profilePicture")
        }
        
        UserDefaults.standard.set(name.capitalized, forKey: "profileName")
        UserDefaults.standard.set(email.capitalized, forKey: "email")
    }
}


//MARK: - preservation and restoration state
//extension ChatsViewController {
//
//    private static let restoreRoomsKey = "restoreRooms"
//
//    override func encodeRestorableState(with coder: NSCoder) {
//        super.encodeRestorableState(with: coder)
//        coder.encode(rooms, forKey: ChatsViewController.restoreRoomsKey)
//    }
//
//    override func decodeRestorableState(with coder: NSCoder) {
//        super.decodeRestorableState(with: coder)
//
//        guard let decodedrooms =
//            coder.decodeObject(forKey: ChatsViewController.restoreRoomsKey) as? [ChatRoom] else {
//            fatalError("A product did not exist in the restore. In your app, handle this gracefully.")
//        }
//        self.rooms = decodedrooms
//    }
//
//}



//MARK: - extension
extension ChatsViewController: TransRooms {
    func transfereRooms(rooms: [ChatRoom]) {
        print("new rooms are comming")
//        self.rooms = rooms
//        self.chatsTableView.reloadData()
    }
    
    
}

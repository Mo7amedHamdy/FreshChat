//
//  UserMessagesViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 27/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct NotificationData {
    var messageId: String
    var messageBody: String
    var sendTime: TimeInterval
}

class UserMessagesViewController: UIViewController {
    
    var indexForEdit: IndexPath!
    
    var onChange: ((ChatRoom)->Void)!
    
    var messages = [Message]()  //test
        
    var isModified: Bool = false //I think..no need to isModified var again ??
    
    var isPushingBackgroundNotificationToApp: Bool = false
    
    var isStartNewChat: Bool!  //to check start new chat or not
    
    var isScroll2: Bool = true
    var isScroll3: Bool = true
    var isFetching: Bool = false
//    var isFlippedSecond: Bool = false
    var isDeleted: Bool = false  //for deleting action
    var source: Bool!
    //for scroll first time and add message
    var keyboardIsDisplayed: Bool = false
    //for add or delete message
    var isScroll: Bool = true
    
    var hideFooter: Bool = false
    
    var deletToolbar = CustomDeleteToolbar()
    
    var conversationIsFound: Bool!  //in case of messages is empty
    
    var chatRoomOtherUserIsFound: Bool! //in case of messages is not empty
    
    var otherUser: User!
    var currentUser: User!
    
    var lastMessageV: Message!
    var deliveredMessagesCount: Int = 0
    var deliveredMessagesState: Bool = false
    
    var keyboardHeight: CGFloat = 0
    
    var maxHeightForTextView: CGFloat!
    
//    var heightConstriantForTextView: NSLayoutConstraint!
    
    let db = Firestore.firestore()
    var cloudFirestoreQuery: Query!
    var documentStart: QueryDocumentSnapshot!
    var messagesListener: ListenerRegistration!
    var onlineStateListener: ListenerRegistration!
    var profilePictureListener: ListenerRegistration!
    var storage = Storage.storage()
    
    var chatRoomDocumentID: String!  //handle this
    var chatRoomDocumentID2: String!
    
    @IBOutlet weak var chatTable: UITableView!
    
    //array for grouped messages with date
    var groupedMessages = [GroupedMessages]()
    var groupedMessagesTest = [GroupedMessages]()
    var notificationMessages = [NotificationData]()
    
    
    var completion: ((ChatRoom)->Void)!
    
    var otherUserPhotoAndNameView: NavbarCustomItem!
    
    var tap: UITapGestureRecognizer!
    
    //initialize message input view from nib
    var messageInputView: InputTest!
    
    var customViewForLeftBarButton: LeftBarButtonItemCustomView!
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override var inputAccessoryView: UIView? {  //TODO try swizzling ??
        return messageInputView
    }
    
    //Mark:- view did load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
                
        print("viewDidLoad is initialized successfully ppppppppppppppppppp")
        
        if chatRoomDocumentID == nil {
            if let currentUserEmail = Auth.auth().currentUser?.email {
                chatRoomDocumentID = "\(currentUserEmail)_\(otherUser.email)"
            }
        }
        
        messageInputView = Bundle.main.loadNibNamed("InputTest", owner: nil)?.first as? InputTest
                
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
       
        //navigation item appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        appearance.titleTextAttributes = [.foregroundColor: UIColor.lightText]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
        
        //custom left bar button item
        let name = otherUser.firstName + " " + otherUser.lastName
        customViewForLeftBarButton = LeftBarButtonItemCustomView()
        navigationItem.leftItemsSupplementBackButton = true
        let customView = configureCustomBarButtonItem(with: name, and: otherUser.profilePictureString)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customView)
                
        //register cells
        chatTable.register(UINib(nibName: "MessageCell", bundle: nil), forCellReuseIdentifier: "messageCell")
        chatTable.register(UINib(nibName: "MessageCell2", bundle: nil), forCellReuseIdentifier: "messageCell2")
        chatTable.register(UINib(nibName: "MessageCellWithCheckMark", bundle: nil), forCellReuseIdentifier: "messageCellWithCheckMark")
        chatTable.register(UINib(nibName: "MessageCell2WithCheckMark", bundle: nil), forCellReuseIdentifier: "messageCell2WithCheckMark")
        chatTable.register(UINib(nibName: "UnReadMessageText", bundle: nil), forCellReuseIdentifier: "unread")
        //register header from custom subclass
        chatTable.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
        chatTable.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "sectionHeader2")

        chatTable.dataSource = self
        chatTable.delegate = self
        chatTable.prefetchDataSource = self
        chatTable.estimatedRowHeight = 60
        
        //reversed tale
        chatTable.transform = CGAffineTransform(scaleX: 1, y: -1)
        
        //delete toolbar location
        deletToolbar.toolBarButtonDelegate = self
        deletToolbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(deletToolbar)
        NSLayoutConstraint.activate([
            deletToolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            deletToolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            deletToolbar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        messageInputView.delegate2 = self
        messageInputView.textView.delegate = self
        
        //load data from fierstore
        if isStartNewChat == nil && isPushingBackgroundNotificationToApp == false {  //conversation is found in chat rooms for current user
//            if !groupedMessages.isEmpty {
//                keyboardIsDisplayed = true  //TODO no need to this property again (test)
//            }
            loadMessagesFromFirestoreWithListener()
        }
        else { //start new chat room
            isStartNewChat = nil
        }
        
        //initialize tap gesture
        tap = tapToDismiss()
        view.addGestureRecognizer(tap)
        tap.isEnabled = false
        
        //handling keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboard(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

    }
    
    
    //Mark:- viewWillAppear
    override func viewWillAppear(_ animated: Bool)  {
        super.viewWillAppear(animated)
        
        getCurrentUserData()
        
        //check conversation and chat rooms is found
//        if groupedMessages.isEmpty {
//            queryInConversationsForCurrentUser()
//            queryInConversationsForOtherUser()
//        }
//        else {
//            queryInConversationsForOtherUser()
//        }
    }
    
    
    //Mark:- viewWillLayoutSubviews
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isScroll3 {
            removePinnedHeadersAtStart()
        }
    }
 
    //Mark:- viewDidLayoutSubviews
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        scrollToBottom()
        if isScroll3 {
            //transform for delete toolbar
            //don't do this out of this scope
            //because this func is called when setting edit mode
            deletToolbar.transform = CGAffineTransform(translationX: 0, y: messageInputView.frame.height + view.safeAreaInsets.bottom)

            //for reversed table
            //worked one time after reload table view at fetch messages after calling
            //view.setNeedsLayout() and view.layoutIfNeeded
            //note that message input view height after reload table becomes (messageInputView.frame.height + view.safeAreaInsets.bottom)

            let contentInset = UIEdgeInsets(top: (messageInputView.frame.height) + 3, left: 0, bottom: 0, right: 0)
            self.chatTable.contentInset = contentInset
            self.chatTable.verticalScrollIndicatorInsets = contentInset
            self.chatTable.contentOffset.y = -(messageInputView.frame.height + 3)
            print("message input view height at view did layout: \(messageInputView.frame.height)")
            print("keyboard height at view did layout: \(keyboardHeight)")

        }
    }
    
    
    //Mark:- viewDidAppear
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        
        isScroll = false
        isScroll3 = false
        if isScroll2 {
            //for notification data
            if isPushingBackgroundNotificationToApp {
                loadMessagesFromFirestoreWithListenerForNotification()
//                self.chatTable.reloadData()
//                self.isScroll2 = false
            }
            
        }
        
        //lisner for state online or offline
        fetchOtherUserState()
        
        //Func()
        //update message state after notifications
//        if !notificationMessages.isEmpty {
//            let chatRoomIdOU = "\(otherUser.email)_\(currentUserEmail)"
//            for not in notificationMessages {
//                db.collection("users").document(otherUser.email).collection("chatRooms").document(chatRoomIdOU).collection("roomMessages").document(not.messageId).updateData(["messageState": "seen"]) { error in
//                    if let error2 = error {
//                        print(error2.localizedDescription)
//                    }
//                    else {
//                        print("message state updated successfully")
//                        print("not messages count: \(self.notificationMessages.count)")
//                        print("not messages: \(not.messageBody)")
//                    }
//                }
//            }
//            //update delivered messages count to zero
//            db.collection("users").document(currentUser.email).collection("chatRooms").document(chatRoomDocumentID).updateData(["deliveredMessagesCount": 0])
//            //update last message seen state
//            db.collection("users").document(otherUser.email).collection("chatRooms").document(chatRoomIdOU).updateData(["messageState": "seen"])
//        }
        
        //Func()
        //update delivered messages to seen when open app without action with notification
        if deliveredMessagesCount > 0 {
            let chatRoomIdOU = "\(otherUser.email)_\(currentUserEmail)"
            getAlldeliveredNotifications(user: otherUser, RoomId: chatRoomIdOU) { documents in
                self.updateDeliveredMessagesToSeen(for: documents, with: chatRoomIdOU)
            }
            deliveredMessagesCount = 0
        }
        
        //Func()
        //Mark:- configure conversation and upload to server if not found
        if groupedMessages.isEmpty {
            let message = Message(roomId: chatRoomDocumentID, sender: currentUserEmail, body: "", sendTime: Date().timeIntervalSince1970)
            self.configureChatRoomForCurrentUser(lastMessage: message)
            db.collection("users").document(currentUserEmail).collection("chatRooms").document(chatRoomDocumentID).updateData(["present": "true"])
            //handle load messages listener if grouped messages is empty,
            //received messages and present is true
            db.collection("users").document(otherUser.email).addSnapshotListener { snapshot, error in
                if let error2 = error {
                    print("error2: \(error2.localizedDescription)")
                }
                else {
                    guard let doc = snapshot else {return}
                    guard let data = doc.data() else {return}
                    guard let configured = data["configured"] as? String else {return}
                    if configured == "true" {
                        self.loadMessagesFromFirestoreWithListener()
                        self.resetConfiguredProperty()
                    }
                }
            }
            
        }else {
            //update presence of user
            db.collection("users").document(currentUserEmail).collection("chatRooms").document(chatRoomDocumentID).updateData(["present": "true"])
        }
        
    }
    
    //reset configured property to false
    func resetConfiguredProperty() {
        self.db.collection("users").document(otherUser.email).updateData(["configured": "false"])
    }
    
    //Mark:- view will disappear
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if !self.groupedMessages.isEmpty && messagesListener != nil {
            messagesListener.remove()
            //you should remove listener
            //because every time you leave view controller and back again,
            //the listener repeat all events happened to the listener during activation of app
            //and this cause some strange behaviours like send messages with no animation
            //or cause two events happen at the same time or something like that
            //you don't want to happen..!
            //and also cause crash app when sign out and trying to sign in with another account
            //causing fatal error : index out of range ??
        }
        
        //remove listner for online state
        if onlineStateListener != nil {
            onlineStateListener.remove()
        }
        
        //remove keyboard observer
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        
        db.collection("users").document(currentUser.email).collection("chatRooms").document(chatRoomDocumentID).updateData(["present": "false"])
        changeNotificationCount()
        deliveredMessagesState = false
        
        
        //remove chat room if grouped messages is empty
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        if groupedMessages.isEmpty {
            db.collection("users").document(currentUserEmail).collection("chatRooms").document(chatRoomDocumentID).delete { error in
                if let error2 = error {
                    print(error2.localizedDescription)
                }else {
                    print("doc is removed from firestore")
                }
            }
        }
    }
    
    
    func changeNotificationCount() {
        UserDefaults(suiteName: "group.mohamed.FreshChat")?.set(1, forKey: "count")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    //get all delivered notifications data
    func getAlldeliveredNotifications(user: User, RoomId: String, completion: @escaping ([QueryDocumentSnapshot])->Void) {
        let query = self.db.collection("users").document(user.email).collection("chatRooms").document(RoomId).collection("roomMessages").whereField("messageState", isNotEqualTo: "seen")
        query.getDocuments(source: .server) { snapshot, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }
            else {
                guard let docs = snapshot?.documents else {return}
                completion(docs)
            }
        }
    }

    
    //update all delivered messages to seen
    func updateDeliveredMessagesToSeen(for docs: [QueryDocumentSnapshot], with roomId: String) {
        for doc in docs {
            db.collection("users").document(otherUser.email).collection("chatRooms").document(roomId).collection("roomMessages").document(doc.documentID).updateData(["messageState": "seen"])
        }
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        db.collection("users").document(currentUserEmail).collection("chatRooms").document(chatRoomDocumentID).updateData(["deliveredMessagesCount": 0])
        db.collection("users").document(otherUser.email).collection("chatRooms").document(roomId).updateData(["messageState": "seen"])
    }

    //Mark:- func tap gesture to dismiss keyboard
    var isTappedGesture: Bool = false
    func tapToDismiss() -> UITapGestureRecognizer {
        let tap = UITapGestureRecognizer(target: self, action: #selector(actionForTap))
        return tap
    }
    
    @objc func actionForTap() {
        isTappedGesture = true
//        messageInputView.textView.resignFirstResponder()
        DispatchQueue.main.async {
            self.messageInputView.textView.resignFirstResponder() //think why🤔 ??
        }
        
    }
    
    
    //Mark:- correct the content offset
//    func scrollToBottom()  {
//        let point = CGPoint(x: 0, y: self.chatTable.contentSize.height + self.chatTable.contentInset.bottom - self.chatTable.frame.height)
//        if chatTable.contentOffset.y != point.y {
//            self.chatTable.setContentOffset(point, animated: false)
//        }
//    }
    
    //Mark:- configure custom bar button item
    func configureCustomBarButtonItem(with imageName: String, and profilePicString: String) -> UIView {
        let img =  UIImage(systemName: "person.circle.fill")
        if let url = URL(string: profilePicString) {
            let req = URLRequest(url: url)
            customViewForLeftBarButton.imageViewBar.image =  UrlCachedImages().cachedImage(req: req)
        }
        else{
            customViewForLeftBarButton.imageViewBar.tintColor = .gray
            customViewForLeftBarButton.imageViewBar.image = img
        }
        customViewForLeftBarButton.label.text = imageName.capitalized
        return customViewForLeftBarButton
    }
    
    
    //to know the keyboard frame is changing
    var isChangingFrame: Bool = false
    var isMessageSent: Bool = false
    //to handle the height of keyboard with contentOffset when keyboard frame is changed
    var inputHeight: CGFloat = 0
    
}



//MARK: - struct for grouped messages
@available(iOS 15.0, *)
struct GroupedMessages {
    var date: Date.FormatStyle.FormatOutput
    var messages: [Message] = [Message]()
}



//MARK: - left bar button item custom view class
class LeftBarButtonItemCustomView: UIView {
    
    let view = UIView()
    let imageViewBar = UIImageView()
    let label = UILabel()
    let stateLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureCustomViewWithConstrains()
        addSubview(view)
        translatesAutoresizingMaskIntoConstraints = false
        heightAnchor.constraint(equalToConstant: 42).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCustomViewWithConstrains() {
        
        view.backgroundColor = .green
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 42).isActive = true
        
        view.addSubview(imageViewBar)
        imageViewBar.translatesAutoresizingMaskIntoConstraints = false
        imageViewBar.heightAnchor.constraint(equalToConstant: 38).isActive = true
        imageViewBar.widthAnchor.constraint(equalToConstant: 38).isActive = true
        imageViewBar.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true
        imageViewBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        imageViewBar.contentMode = .scaleAspectFit
        imageViewBar.layer.borderWidth = 1.00
        imageViewBar.layer.borderColor = UIColor.link.cgColor
        imageViewBar.layer.cornerRadius = 19
        imageViewBar.layer.masksToBounds = true
        
        view.addSubview(label)
        view.addSubview(stateLabel)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.heightAnchor.constraint(equalToConstant: 17).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5).isActive = true
        label.leadingAnchor.constraint(equalTo: imageViewBar.trailingAnchor, constant: 10).isActive = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .black
        
        stateLabel.translatesAutoresizingMaskIntoConstraints = false
        stateLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
        stateLabel.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 1).isActive = true
        stateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -4).isActive = true
        stateLabel.leadingAnchor.constraint(equalTo: imageViewBar.trailingAnchor, constant: 10).isActive = true
        stateLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        stateLabel.textColor = .gray
    }
}

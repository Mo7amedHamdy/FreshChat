//
//  SignInViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 27/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

protocol TransRooms {
    func transfereRooms(rooms: [ChatRoom])
}

class SignInViewController: UIViewController {
    
    let db = Firestore.firestore()
    var rooms = [ChatRoom]()
    
    var delegateRooms: TransRooms?

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.cornerRadius = 6
        
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 6
        
        signInButton.layer.cornerRadius = 20
        
        navigationItem.title = "SignIn"
        navigationItem.backButtonDisplayMode = .minimal  //back button for register view controller
        
        activityIndicator = loadActivityIndicator()
        activityIndicator.layer.cornerRadius = 20
        activityIndicator.isHidden = true
        
        //tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
    //add keyboard notifications
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //remove keyboard notifications
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //handle keyboard show and hide
    @objc func handleKeyboardShow(notification: Notification) {
        if notification.name == UIResponder.keyboardWillShowNotification {
            scrollView.setContentOffset(CGPoint(x: 0, y: 40), animated: true)
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    //action for tap gesture
    @objc func dismissKeyboard() {
//        view.endEditing(true)
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
  
    //create activity indecator
    func loadActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = .link
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo:  signInButton.topAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo:  signInButton.leadingAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo:  signInButton.bottomAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo:  signInButton.trailingAnchor).isActive = true
        return activityIndicator
    }
    
    @IBAction func didPressSignIn(_ sender: UIButton) {
        signInButton.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let err = error {
                    self.displayErrorAlert(with: err.localizedDescription)
                    self.activityIndicator.stopAnimating()
                    self.signInButton.isEnabled = true
                }else {
                    self.dismiss(animated: true)
                }
                
                //save fcm token
                if let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") {
                    if let currentUserId = Auth.auth().currentUser?.email {
                        let ref = self.db.collection("users").document(currentUserId)
                        ref.updateData(["fcm": fcmToken])
                        print("fcm token is saved successfully")
                    }else {
                        print("current user not initialized")
                    }
                }
            }
        }
    }
    
    //alert message for error sign up
    func displayErrorAlert(with messageError: String) {
        let alert = UIAlertController(title: "sign in error", message: messageError, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}


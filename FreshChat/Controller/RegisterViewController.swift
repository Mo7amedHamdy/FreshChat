//
//  RegisterViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 07/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class RegisterViewController: UIViewController {
    
    let db = Firestore.firestore()

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerButton: UIButton!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerButton.layer.cornerRadius = 9
        
        navigationItem.title = "Sign Up"
        
        activityIndicator = loadActivityIndicator()
        activityIndicator.isHidden = true
        activityIndicator.layer.cornerRadius = 11
        
        //tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        animateTextFields()
    }
    
    //animtion of text fields
    func animateTextFields() {
        //email text field
        emailTextField.layer.borderWidth = 0.5
        emailTextField.layer.borderColor = UIColor.gray.cgColor
        emailTextField.layer.cornerRadius = 6
        
        //first name text field
        firstNameTextField.layer.borderWidth = 0.5
        firstNameTextField.layer.borderColor = UIColor.gray.cgColor
        firstNameTextField.layer.cornerRadius = 6
        
        //last name text field
        lastNameTextField.layer.borderWidth = 0.5
        lastNameTextField.layer.borderColor = UIColor.gray.cgColor
        lastNameTextField.layer.cornerRadius = 6
        
        //password text field
        passwordTextField.layer.borderWidth = 0.5
        passwordTextField.layer.borderColor = UIColor.gray.cgColor
        passwordTextField.layer.cornerRadius = 6
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
            scrollView.setContentOffset(CGPoint(x: 0, y: 45), animated: true)
        }
        else if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
        }
    }
    
    //action for tap gesture
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //create activity indecator
    func loadActivityIndicator() -> UIActivityIndicatorView {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.backgroundColor = .link
        activityIndicator.color = .white
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)
        activityIndicator.topAnchor.constraint(equalTo:  registerButton.topAnchor).isActive = true
        activityIndicator.leadingAnchor.constraint(equalTo:  registerButton.leadingAnchor).isActive = true
        activityIndicator.bottomAnchor.constraint(equalTo:  registerButton.bottomAnchor).isActive = true
        activityIndicator.trailingAnchor.constraint(equalTo:  registerButton.trailingAnchor).isActive = true
        return activityIndicator
    }
    
    //press on register button
    @IBAction func didPressRegister(_ sender: Any) {
        if emailTextField.text != "" || firstNameTextField.text != "" || passwordTextField.text != "" {
            createNewAccount()
        }
        else {
            let errorText = "please, enter a valid data!"  // error message 1
            displayErrorAlert(with: errorText)
        }
    }
    
    
    //Mark:- create new account
    func createNewAccount() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        registerButton.isEnabled = false //temporary solution -- create activitiy indicator instead
        if let emailText = emailTextField.text,
           let firstName = firstNameTextField.text,
           let lastName = lastNameTextField.text,
           let passwordText = passwordTextField.text {
            Auth.auth().createUser(withEmail: emailText, password: passwordText) { authResult, error in
                if let error2 = error {
                    let errorText = error2.localizedDescription  //error message 2
                    self.displayErrorAlert(with: errorText)
                    self.activityIndicator.stopAnimating()
                    self.registerButton.isEnabled = true
                }else {
                    self.dismiss(animated: true) {
                        //save all users in collection users
                        let userData = ["email": emailText,
                                        "firstName": firstName,
                                        "lastName": lastName,
                                        "fcm": "",
                                        "profilePicture": ""]
                        self.db.collection("users").document(emailText).setData(userData)
                    }
                }
                
                //save fcm token
                if let fcmToken = UserDefaults.standard.value(forKey: "fcmToken") {
                    let ref = self.db.collection("users").document(emailText)
                    ref.updateData(["fcm": fcmToken])
                    print("fcm token is saved successfully")
                }else {
                    print("current user not registered")
                }
            }
        }
    }
    
    
    //alert message for error sign up
    func displayErrorAlert(with messageError: String) {
        let alert = UIAlertController(title: "sign up error", message: messageError, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default)
        
        alert.addAction(okAction)
        
        present(alert, animated: true)
    }
}


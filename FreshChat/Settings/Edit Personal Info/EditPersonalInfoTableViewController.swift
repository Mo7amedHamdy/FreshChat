//
//  EditPersonalInfoTableViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 30/06/2023.
//

import UIKit
import PhotosUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class EditPersonalInfoTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    
    let db = Firestore.firestore()
    var storage = Storage.storage()

    @IBOutlet weak var tableViewEdit: UITableView!
        
    var personalInfo: PersonalInformation!
    
    var onChangePersonalInfo: (PersonalInformation)->() = { _ in }
    
    var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "EPP") as! MoveAndScaleProfilePicViewController
    
    var doneIsPressed: Bool!
    
    var nameTextFromTextField: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Edit Profile"
        navigationController?.navigationBar.topItem?.backButtonDisplayMode = .minimal
        
        tableViewEdit.dataSource = self
        tableViewEdit.delegate = self
        tableViewEdit.sectionHeaderTopPadding = 0
        tableViewEdit.register(UINib(nibName: "ProfilePicEdit", bundle: nil), forCellReuseIdentifier: "pPE")
        tableViewEdit.register(UINib(nibName: "ProfileNameEdit", bundle: nil), forCellReuseIdentifier: "pNE")
        tableViewEdit.register(UINib(nibName: "Empty", bundle: nil), forCellReuseIdentifier: "cellTest")
        tableViewEdit.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "header")
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 10 : 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let header = UITableViewHeaderFooterView(reuseIdentifier: "header")
            var content = header.defaultContentConfiguration()
            content.text = "Email".uppercased()
            content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            header.contentConfiguration = content
            return header
        }
        else {
            let header = UITableViewHeaderFooterView(reuseIdentifier: "header")
            var backgroundConfig = UIBackgroundConfiguration.listGroupedHeaderFooter()
            backgroundConfig.backgroundColor = .white
            header.backgroundConfiguration = backgroundConfig
            return header
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "pPE", for: indexPath) as! ProfilePicEditTableViewCell
        let cell2 = tableView.dequeueReusableCell(withIdentifier: "pNE", for: indexPath) as! ProfileNameEditTableViewCell
        let cell3 = tableView.dequeueReusableCell(withIdentifier: "cellTest", for: indexPath) as! EmptyTableViewCell
        
        //section 0
        if indexPath.section == 0 {
            //cell for profile pic
            if indexPath.row == 0 {
                //TODO this cell may be in header let's try this ??
                cell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                cell.profilePic.image = personalInfo.profilePicture
                cell.onPressEdit = { isClicked in
                    if isClicked == true {
                        let pickerConfiguration = PHPickerConfiguration(photoLibrary: .shared())
                        let picker = PHPickerViewController(configuration: pickerConfiguration)
                        picker.delegate = self
                        self.present(picker, animated: true)
                    }
                }
                return cell
            }
            //cell for profile name
            else if indexPath.row == 1  {
                cell2.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0)
                cell2.nameTextField.text = personalInfo.name
                cell2.nameTextField.delegate = self
                return cell2
            }
            
            else  {
                cell3.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
                return cell3
            }
        }
        //section 1
        else {
            cell3.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            var content = cell3.defaultContentConfiguration()
            content.text = personalInfo.email
            content.textProperties.font = UIFont.systemFont(ofSize: 16, weight: .regular)
            cell3.contentConfiguration = content
            return cell3
        }
    }
    
    
    //Mark:- edit profile name
    @objc func doneButtonIsPressed() {
        doneIsPressed = true
        view.endEditing(true)
    }
    
    @objc func cancelButtonIsPressed() {
        doneIsPressed = false
        self.navigationItem.rightBarButtonItem = nil
        self.navigationItem.leftBarButtonItem = nil
        view.endEditing(true)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        nameTextFromTextField = textField.text
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneButtonIsPressed))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelButtonIsPressed))
    }
    
    //handle empty text field
    func textFieldDidChangeSelection(_ textField: UITextField) {
        navigationItem.rightBarButtonItem?.isEnabled = textField.text == "" ? false : true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        //done button is pressed
        if doneIsPressed == true {
            //update personal data in SettingsCollectionViewController
            guard let name = textField.text else { return }
            personalInfo.name = name
            onChangePersonalInfo(personalInfo)
            
            //save new personal data in firestore
            let nameSubStringArray = name.split(separator: " ")
            print(nameSubStringArray)
            let firstName = String(nameSubStringArray[0])
            let lastName = nameSubStringArray.count > 1 ?  String(nameSubStringArray[1]) : ""
            
            guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
            self.db.collection("users").document(currentUserEmail).updateData(["firstName": firstName,
                                                                               "lastName": lastName])

            //hide bar button items
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }
        
        //cancel button is pressed
        else if doneIsPressed == false {
            textField.text = nameTextFromTextField
            nameTextFromTextField = nil
        }
    }

}


//MARK: - picker delegate
extension EditPersonalInfoTableViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        
        //dismiss picker
        if results == [] {
            picker.dismiss(animated: true)
        }
        else {
            //configure edit view controller
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = picker  //TODO figure out custom transition ?
            vc.delegateImage = self
            picker.present(self.vc, animated: true)
            
            //selected items
            if let itemProvider = results.first?.itemProvider /*,itemProvider.canLoadObject(ofClass: UIImage.self)*/ {
                itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self, let image2 = image as? UIImage else {
                        print("image not found")
                        return }
                    DispatchQueue.main.async {
                        self.vc.originImage.image = image2
                    }
                }
            }
        }
    }
}



//MARK: - transition delegate
//@available(iOS 16, *)
extension PHPickerViewController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentTransition()
    }

    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissTransition()
    }
}


//MARK: - transfere new profile pic
extension EditPersonalInfoTableViewController:  TransfereImage, UIViewControllerTransitioningDelegate {

    func profileImage(image: UIImage) {
        self.personalInfo.profilePicture = image
        tableViewEdit.reloadData() //for EditPersonalInfoTableViewController
        onChangePersonalInfo(personalInfo) //for SettingsCollectionViewController
        
        //save image in storage and url in firestore
        self.uploadProfilePhotoInStorage(profileImage: image)
    }
    
    func chooseButtonClicked(isChoosen: Bool) {
        if isChoosen {
            vc.transitioningDelegate = self
            dismiss(animated: true)
        }
    }
    
    
    //upload profile photo to storage
    func uploadProfilePhotoInStorage(profileImage: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let image = profileImage
        let storageRef = storage.reference(withPath: "users/\(userId)/profilePictureFile/profilePicture.jpg")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"

        storageRef.putData(imageData, metadata: uploadMetadata) { downloadMetadata, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }else {
                if let downloadMetadata2 = downloadMetadata {
                    print("put is completed and got this \(downloadMetadata2)")
                    self.dowmloadprofilePicUrl(from: storageRef)
                }
            }
        }
    }
    
    //download profile pic url from storage and save it in firestore
    func dowmloadprofilePicUrl(from storageRef: StorageReference) {
        guard let currentUserEmail = Auth.auth().currentUser?.email else {return}
        storageRef.downloadURL { url, error in
            if let error2 = error {
                print(error2.localizedDescription)
                return
            }
            if let url2 = url {
                print("url is: \(url2.absoluteString)")
                self.db.collection("users").document("\(currentUserEmail)").updateData(["profilePicture": url2.absoluteString]) { error in
                    if let error2 = error {
                        print(error2.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}


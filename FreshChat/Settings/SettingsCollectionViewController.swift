//
//  SettingsCollectionViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 19/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

class SettingsCollectionViewController: UICollectionViewController {
    
    var personalInfo: PersonalInformation!
    
    var activityCellAccessory: UICellAccessory.CustomViewConfiguration!
    
    let db = Firestore.firestore()
    var storage = Storage.storage()
    var currentUser: [String: Any]!
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Row>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Row>
    var dataSource: DataSource!
        
    var profileInfoSection: [Row] = [.profileInfo]
    var privacySection: [Row] = [.account, .privacy, .notification]
    var logoutSection: [Row] = [.logout]
        
    override func viewDidLoad() {
        super.viewDidLoad()
                
        dataSource = configureDataSource()

        collectionView.collectionViewLayout = configureCompositionalLayout()
        
        
        activityCellAccessory = self.activityIndicatorAccessory()

        //current user data
//        currentUser = UserDefaults.standard.dictionary(forKey: "currentUser")
        if let data = UserDefaults.standard.data(forKey: "profilePicture"),
           let name = UserDefaults.standard.string(forKey: "profileName"),
           let email = UserDefaults.standard.string(forKey: "email"){
            let img = UIImage(data: data)
            personalInfo = PersonalInformation(name: name, profilePicture: img, email: email)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureSnapshot()
    }
    
    //hide activity indicator in cell
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        activityCellAccessory.customView.isHidden = true
    }
    
    //Mark:- configure collection layout list (done)
    func configureCompositionalLayout() -> UICollectionViewCompositionalLayout {
        let listConfiguration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        return UICollectionViewCompositionalLayout.list(using: listConfiguration)
    }
    
    //Mark:- configure registered cell
    func configureRegisteredCell() -> UICollectionView.CellRegistration<UICollectionViewListCell, Row> {
        let registerCell = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { cell, indexPath, item in
            let section = self.getSection(for: indexPath)
            switch (section).self {
            case(.privacyInfo):
                let content = self.defaultCellConfiguration(for: cell, with: item)
                cell.contentConfiguration = content
            case(.signOut):
                let content = self.signOutConfiguration(for: cell, with: item)
                cell.contentConfiguration = content
            case(.personalInfo):
                let content = self.personalInfoCellConfiguration(for: cell, with: item)
                cell.contentConfiguration = content
            }
        }
        return registerCell
    }
    
    //get section index
    func getSection(for indexPath: IndexPath) -> Section {
        let sectionNumber = indexPath.section
        guard let section = Section(rawValue: sectionNumber) else { fatalError("Unable to find matching section") }
        return section
    }
    
    //Mark:- configure data source
    func configureDataSource() -> DataSource {
        let cellReg = configureRegisteredCell()
        return DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            collectionView.dequeueConfiguredReusableCell(using: cellReg, for: indexPath, item: itemIdentifier)
        }
    }
    
    //Mark:- configure snapshot
    func configureSnapshot() {
        var snapshot = Snapshot()
        snapshot.appendSections([.personalInfo,.privacyInfo, .signOut])
        snapshot.appendItems([.profileInfo], toSection: .personalInfo)
        snapshot.appendItems([.account, .privacy, .notification], toSection: .privacyInfo)
        snapshot.appendItems([.logout], toSection: .signOut)
        dataSource.apply(snapshot)
    }
    
    
    //Mark:- sign out
    //sign out from firebase
    func signout() {
        activityCellAccessory.customView.isHidden = false
        view.isUserInteractionEnabled = false
        tabBarController?.tabBar.isUserInteractionEnabled = false
//        UserDefaults.standard.removeObject(forKey: "currentUser")
        //remove fcm token from user
        guard let currentUserEmail = Auth.auth().currentUser?.email else { return }
        let ref = db.collection("users").document(currentUserEmail)
        ref.updateData(["fcm": ""])
        
        //offline state
        db.collection("users").document(currentUserEmail).updateData(["state": "offline",
                                                                      "stateTime": Date().timeIntervalSince1970])

        print("fcm token is removed")
        
        let dispatchWork = DispatchWorkItem {
            do {
                try Auth.auth().signOut()
                self.dismiss(animated: false){
                    let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "chatBar")
                    let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
                    sceneDelegate?.changeRootVC(vc)
                }
            }catch let signOutError as NSError {
                print("Error sign out: %@", signOutError)
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: dispatchWork)
    }
    
    //sign out action sheet
    func signoutActionSheet() {
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure, you wanna leave !", preferredStyle: .actionSheet)
        let signoutAction = UIAlertAction(title: "Sign Out", style: .destructive) { action in
            self.signout()
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel)
        
        actionSheet.addAction(signoutAction)
        actionSheet.addAction(cancelAction)
        
        self.present(actionSheet, animated: true)
        
    }
    
    //configure ref for storage
    //upload profile photo
    func uploadProfilePictureInStorage(_ picture: UIImage) {
        guard let currentUser = Auth.auth().currentUser else { return }
        let storageRef = storage.reference(withPath: "users/\(currentUser.uid)/profilePictureFile/profilePicture.jpg")
        guard let imageData = picture.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetadata = StorageMetadata.init()
        uploadMetadata.contentType = "image/jpeg"
        
        storageRef.putData(imageData, metadata: uploadMetadata) { downloadMetadata, error in
            if let error2 = error {
                print(error2.localizedDescription)
            }else {
                if let downloadMetadata2 = downloadMetadata {
                    print("put is completed and got this \(downloadMetadata2)")
                    if let userEmail = currentUser.email {
                        self.dowmloadprofilePicUrl(from: storageRef, to: userEmail)
                    }
                }
            }
        }
    }
    
    func dowmloadprofilePicUrl(from storage: StorageReference, to userEmail: String) {
        storage.downloadURL { url, error in
            if let error2 = error {
                print(error2.localizedDescription)
                return
            }
            if let url2 = url {
                print("url is: \(url2.absoluteString)")
                self.db.collection("users").document(userEmail).updateData(["profilePicture": url2.absoluteString]) { error in
                    if let error2 = error {
                        print(error2.localizedDescription)
                        return
                    }
                }
            }
        }
    }
}

//MARK: - collection view delegate
extension SettingsCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let section = indexPath.section
        if section == 0 {
//            let item = profileInfoSection[indexPath.item]
//            print(item.name)
            
            //perform segue
            self.performSegue(withIdentifier: "toProfileInfoEdit", sender: self)
        }
        else if section == 1 {
            let item = privacySection[indexPath.item]
            print(item.name)
        }
        else if section == 2 {
            let item = logoutSection[indexPath.item]
            if item.name == "Sign Out" {
                self.signoutActionSheet()
            }
        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
            self.collectionView.deselectItem(at: indexPath, animated: true)
//        }
    }
   
    //prepare for segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let des = segue.destination as? EditPersonalInfoTableViewController {
            des.onChangePersonalInfo = { newPersonalInfo in  //also you can do this with delegate
                self.personalInfo = newPersonalInfo
                self.dataSource = self.configureDataSource()
            }
            des.personalInfo = self.personalInfo
        }
    }
}

//
//  UsersViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 15/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class UsersViewController: UIViewController {
    
    var dataSource: UITableViewDiffableDataSource<Section, Item>! = nil
    
    private var imageObjects = [Item]()
    private var sortedItems = [Item]()
    var usersData: [User]
    var db = Firestore.firestore()
    var onChange: (User)->Void
    var usersTableView = UITableView()
    
    init( usersData: [User], onChange2: @escaping (User)->Void) {
        self.usersData = usersData
        self.onChange = onChange2
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "users"
        navigationController?.navigationBar.backgroundColor = .systemBackground
        let rightBarButton = UIBarButtonItem(title: "cancel", style: .plain, target: self, action: #selector(didPressCancel))
        navigationItem.rightBarButtonItem = rightBarButton
        
        view.addSubview(usersTableView)
        view.addSubview((navigationController?.navigationBar)!)
        usersTableView.translatesAutoresizingMaskIntoConstraints = false
        usersTableView.topAnchor.constraint(equalTo: (navigationController?.navigationBar.bottomAnchor)!).isActive = true
        usersTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        usersTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        usersTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        //register cell from nib
        usersTableView.register(UINib(nibName: "UsersMailCell", bundle: nil), forCellReuseIdentifier: "userMailCell")

        //diffable data source
//        dataSource = UITableViewDiffableDataSource<Section, Item>(tableView: usersTableView) {
//            (tableView: UITableView, indexPath: IndexPath, item: Item) -> UITableViewCell? in
//            let cell = tableView.dequeueReusableCell(withIdentifier: "userMailCell", for: indexPath) as! UsersMailcell
//            /// - Tag: update
//            cell.userName.text = item.name.capitalized
//            cell.userProfilePicture.image = item.image
//
//            //TODO save images in local database:- core data
//
//            if item.url != nil {
//                ImageCache.publicCache.load(url: item.url as NSURL, item: item) { (fetchedItem, image) in
//                    if let img = image, img != fetchedItem.image {
//                        var updatedSnapshot = self.dataSource.snapshot()
//                        if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
//                            let item = self.sortedItems[datasourceIndex]
//                            item.image = img
//                            updatedSnapshot.reloadItems([item])
//                            self.dataSource.apply(updatedSnapshot, animatingDifferences: false)
//                        }
//                    }
//                }
//            }
//
//            return cell
//        }
//
//        self.dataSource.defaultRowAnimation = .fade
//
//        // Get our image URLs for processing.
//        if imageObjects.isEmpty {
//                for user in usersData {
//                    let email = user.email
//                    let firstName = user.firstName
//                    let lastName = user.lastName
//                    let name = firstName + " " + lastName
//                    if let url = URL(string: user.profilePictureString) {
//                        self.imageObjects.append(Item(email: email, firstName: firstName, lastName: lastName, name: name,imageUrlString: user.profilePictureString, image: ImageCache.publicCache.placeholderImage, url: url))
//                    }
//                    else{
//                        self.imageObjects.append(Item(email: email, firstName: firstName, lastName: lastName, name: name, imageUrlString: user.profilePictureString, image: ImageCache.publicCache.placeholderImage, url: nil))
//                    }
//                }
//
//            sortedItems = imageObjects.sorted {
//                $0.name < $1.name
//            }
//            var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
//            initialSnapshot.appendSections([.main])
//            initialSnapshot.appendItems(sortedItems)
//            self.dataSource.apply(initialSnapshot, animatingDifferences: true)
//        }
    }

    @objc func didPressCancel() {
        dismiss(animated: true)
    }
}


//MARK: - table view delegate
//extension UsersViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let item = sortedItems[indexPath.row]
//        let user = User(email: item.email,
//                        firstName: item.firstName,
//                        lastName: item.lastName,
//                        profilePicture: item.image,
//                        profilePictureString: item.imageUrlString)
//        onChange(user)
//        dismiss(animated: true)
//    }
//}

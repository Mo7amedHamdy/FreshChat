//
//  UsersViewController+TableViewEx.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 01/11/2022.
//

import UIKit

extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usersData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userMailCell", for: indexPath) as! UsersMailcell
        let user = usersData[indexPath.row]
        let userName = "\(user.firstName) \(user.lastName)".capitalized
        let profilePictureSt = user.profilePictureString
        cell.userName.text = userName
        cell.userProfilePicture.image = UIImage(systemName: "person.circle.fill")
                
        if let url = URL(string: profilePictureSt) {
            let item = Item(email: "",
                            firstName: "",
                            lastName: "",
                            name: "",
                            imageUrlString: profilePictureSt,
                            image: UIImage(systemName: "person.circle.fill")!,
                            url: url)

            UrlCachedImages().getCachedImage(url: url, item: item) { fetchedItem, image in
                if let img = image, img != fetchedItem.image {
                    cell.userProfilePicture.image = img
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = usersData[indexPath.row]
        onChange(selectedUser)
        dismiss(animated: true)
    }
    
}

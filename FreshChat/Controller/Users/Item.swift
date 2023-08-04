//
//  Item.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 17/12/2022.
//

import UIKit

enum Section {
    case main
}

class Item: Hashable {
    
    var email: String!
    var firstName: String!
    var lastName: String!
    var name: String!
    var imageUrlString: String!
    var image: UIImage!
    var url: URL!
    let identifier = UUID()
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
    static func == (lhs: Item, rhs: Item) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    init(email: String,firstName: String, lastName: String, name: String, imageUrlString: String, image: UIImage, url: URL?) {
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.name = name
        self.imageUrlString = imageUrlString
        self.image = image
        self.url = url
    }

}


//
//  EditPersonalInfoCollectionViewControllerEX+Sections+Items.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 27/06/2023.
//

import UIKit

extension EditPersonalInfoCollectionViewController {
    
    enum Section: Int {
        case profileImage
        case name
    }
    
    enum Row {
        case profileImage
        case name
        
        var rowName: String {
            switch self {
            case .profileImage :
                return "profile picture"
            case .name :
                return "name"
            }
        }
    }
}

//
//  SettingsCollectionViewController+Sections+Items.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 20/11/2022.
//

import UIKit
import FirebaseAuth

extension SettingsCollectionViewController {
    
    enum Section: Int {
        case personalInfo
        case privacyInfo
        case signOut
    }
    
    enum Row {
        case profileInfo
        case account
        case notification
        case privacy
        case logout
        
        var name: String {
            switch self {
            case .profileInfo: return "mohamed"
            case .account: return "Account"
            case .privacy: return "Privacy"
            case .notification: return "Notification"
            case .logout: return "Sign Out"
            }
        }
        
        var imageName: String? {
            switch self {
            case .profileInfo: return "person.fill"
            case .account: return "key.fill"
            case .privacy: return "hand.raised.fill"
            case .notification: return "bell.badge.fill"
            case .logout: return "rectangle.portrait.and.arrow.right"
            }
        }
        
        var imageColor: UIColor? {
            switch self {
            case .profileInfo: return .systemGray
            case .account: return .link
            case .privacy: return #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            case .notification: return .red
            case .logout: return .gray
            }
        }

    }
}

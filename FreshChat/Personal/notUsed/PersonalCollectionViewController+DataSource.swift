//
//  PersonalCollectionViewController+DataSource.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 26/11/2022.
//

import UIKit
import FirebaseAuth

extension PersonalCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            let item = itemsInSection0[indexPath.row]
            if item == "Sign Out" {
                configureSignoutActionSheet()
            }
        }
    }
    
    //configure sign out action sheet
    func configureSignoutActionSheet() {
        let alert = UIAlertController(title: "sure to sign out !".capitalized, message: nil, preferredStyle: .alert)
        let logoutAction = UIAlertAction(title: "sign out".capitalized, style: .destructive) { action in
            self.dismiss(animated: true) {
                self.completeDismiss(true)
            }
        }
        
        let cancelAction = UIAlertAction(title: "cancel".capitalized, style: .cancel)
        
        alert.addAction(logoutAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
        
    }
    
}

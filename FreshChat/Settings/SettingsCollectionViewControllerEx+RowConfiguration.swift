//
//  SettingsCollectionViewControllerEx+RowConfiguration.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 05/01/2023.
//

import UIKit

extension SettingsCollectionViewController {
    
    //for section: personal info
    func defaultCellConfiguration(for cell: UICollectionViewListCell, with row: Row) ->UIListContentConfiguration {
        var content = cell.defaultContentConfiguration()
        content.text = row.name
        content.textProperties.color = .black
        if let imageName = row.imageName, let imageColor = row.imageColor {
            let symbolImageConfuguration = self.symbolImageConfiguration(with: imageName, and: imageColor)
            cell.accessories = [.customView(configuration: symbolImageConfuguration), .disclosureIndicator(displayed: .always)]
        }
        return content
    }
    
    
    //for section: personal info
    func personalInfoCellConfiguration(for cell: UICollectionViewListCell, with row: Row) ->PersonalInfoContentView.PersonalInfoContentConfiguration {
        var content = cell.contentViewCellConfigurationForPersonalInfo()
        content.personalInfo = personalInfo
        cell.accessories = [.disclosureIndicator(displayed: .always)]
        return content
    }
    
    
    //for section: sign out
    func signOutConfiguration(for cell: UICollectionViewListCell, with row: Row) ->UIListContentConfiguration {
        var content = cell.defaultContentConfiguration()
        content.text = row.name
        if let imageName = row.imageName, let imageColor = row.imageColor {
            let symbolImageConfuguration = self.symbolImageConfiguration(with: imageName, and: imageColor)
            cell.accessories =  [.customView(configuration: symbolImageConfuguration), .customView(configuration: self.activityCellAccessory)]
        }
        return content
    }
    
    
    //Mark:- cell accessory configuration
    //symbol image configuration
    func symbolImageConfiguration(with imageName: String, and imageColor: UIColor) -> UICellAccessory.CustomViewConfiguration {
        let symbolView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: 32))
        symbolView.backgroundColor = imageColor
        symbolView.layer.cornerRadius = 4
        let symbolConfiguration = UIImage.SymbolConfiguration(pointSize: 18)
        let image = UIImage(systemName: imageName, withConfiguration: symbolConfiguration)
        let imageView = UIImageView(image: image)
        symbolView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.centerXAnchor.constraint(equalTo: symbolView.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: symbolView.centerYAnchor).isActive = true
        return UICellAccessory.CustomViewConfiguration(customView: symbolView, placement: .leading(displayed: .always), tintColor: .white, maintainsFixedSize: true)
    }
    
    //activity indicator configuration
    func activityIndicatorAccessory() -> UICellAccessory.CustomViewConfiguration {
        let activity = UIActivityIndicatorView(style: .medium)
        activity.startAnimating()
        return UICellAccessory.CustomViewConfiguration(customView: activity, placement: .trailing())
    }
}

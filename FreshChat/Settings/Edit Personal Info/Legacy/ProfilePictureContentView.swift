//
//  ProfilePictureContentView.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 29/06/2023.
//

import UIKit

//TODO profile picture content view
class ProfilePictureContentView: UIView, UIContentView {
    
    var vC = UIView()
    var profileImageView = UIImageView()
    var imageLabel = UILabel()
    var editButton = UIButton()
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration: configuration)
        }
    }
    
    struct ProfilePictureContentConfiguration: UIContentConfiguration {
        
        var profileInfo: PersonalInformation!
        
        func makeContentView() -> UIView & UIContentView {
            return ProfilePictureContentView(self)
        }
        
        func updated(for state: UIConfigurationState) -> ProfilePictureContentView.ProfilePictureContentConfiguration {
            return self
        }

    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        vC.addSubview(profileImageView)
        vC.addSubview(imageLabel)
        vC.addSubview(editButton)
                
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        imageLabel.translatesAutoresizingMaskIntoConstraints = false
        editButton.translatesAutoresizingMaskIntoConstraints = false
        //set up constrains
        NSLayoutConstraint.activate([
            
            //TODO constrians for subviews
            profileImageView.topAnchor.constraint(equalTo: vC.topAnchor, constant: 20),
//            profileImageView.bottomAnchor.constraint(equalTo: vC.bottomAnchor, constant: -20),
            profileImageView.leadingAnchor.constraint(equalTo: vC.leadingAnchor, constant: 5),
            profileImageView.heightAnchor.constraint(equalToConstant: 80),
            profileImageView.widthAnchor.constraint(equalToConstant: 80),
            
            editButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 10),
            editButton.leadingAnchor.constraint(equalTo: vC.leadingAnchor, constant:  20),
            editButton.bottomAnchor.constraint(equalTo: vC.bottomAnchor, constant:  -10),
            editButton.heightAnchor.constraint(equalToConstant: 30),
            editButton.centerXAnchor.constraint(equalTo: profileImageView.centerXAnchor),
            
            imageLabel.topAnchor.constraint(equalTo: vC.topAnchor, constant: 30 ),
            imageLabel.leadingAnchor.constraint(equalTo: profileImageView.trailingAnchor, constant: 15),
            imageLabel.trailingAnchor.constraint(equalTo: vC.trailingAnchor, constant: -10)
            
        ])
        
        profileImageView.layer.cornerRadius = 40
        profileImageView.layer.masksToBounds = true
        
        editButton.setTitle("Edit", for: .normal)
        editButton.setTitleColor(.link, for: .normal)  //TODO add target to button ??
        
        imageLabel.textAlignment = .justified
        imageLabel.numberOfLines = 0
        imageLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        imageLabel.textColor = .systemGray
        
        addPinnedSubView(vC, height: 150)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func configure(configuration: UIContentConfiguration) {
        guard let config = configuration as? ProfilePictureContentConfiguration else { return }
        let personalInfo = config.profileInfo
        profileImageView.image = personalInfo?.profilePicture
        imageLabel.text = "Enter your name and add an optional profile picture"
    }
}


extension UICollectionViewListCell {
    func contentViewCellConfigurationForProfilePic() -> ProfilePictureContentView.ProfilePictureContentConfiguration {
       return ProfilePictureContentView.ProfilePictureContentConfiguration()
    }
}

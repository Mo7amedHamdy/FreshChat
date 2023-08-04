//
//  PersonalInfoContentView.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 05/01/2023.
//

import UIKit
import FirebaseAuth

class PersonalInfoContentView: UIView, UIContentView {
    
    var configuration: UIContentConfiguration {
        didSet{
            self.configure(configuration)
        }
    }
    
    var viewC = UIView()
    var nameLabel = UILabel()
    var profilePicture = UIImageView()
    
    //content configuration
    struct PersonalInfoContentConfiguration: UIContentConfiguration {
        
//        var currentUser: [String: Any]! //copy of data model
        var personalInfo: PersonalInformation!
        
        func makeContentView() -> UIView & UIContentView {
            return PersonalInfoContentView(self)
        }
        
        func updated(for state: UIConfigurationState) -> PersonalInfoContentView.PersonalInfoContentConfiguration {
            return self
        }
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        //Mark:- layout properties
        viewC.addSubview(profilePicture)
        viewC.addSubview(nameLabel)
        
        profilePicture.translatesAutoresizingMaskIntoConstraints = false
        profilePicture.leadingAnchor.constraint(equalTo: viewC.leadingAnchor, constant: 2).isActive = true
        profilePicture.topAnchor.constraint(equalTo: viewC.topAnchor, constant: 10).isActive = true
        profilePicture.bottomAnchor.constraint(equalTo: viewC.bottomAnchor, constant: -10).isActive = true
        profilePicture.heightAnchor.constraint(equalToConstant: 60).isActive = true
        profilePicture.widthAnchor.constraint(equalToConstant: 60).isActive = true
        profilePicture.layer.cornerRadius = 30
        profilePicture.layer.masksToBounds = true
        profilePicture.tintColor = .gray
        
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leadingAnchor.constraint(equalTo: profilePicture.trailingAnchor, constant: 15).isActive = true
        nameLabel.topAnchor.constraint(equalTo: viewC.bottomAnchor, constant: 15).isActive = true
        nameLabel.bottomAnchor.constraint(equalTo: viewC.bottomAnchor, constant: -35).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        nameLabel.font = UIFont(descriptor: .preferredFontDescriptor(withTextStyle: .title1), size: 22)
        addPinnedSubView(viewC, height: 80)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ configuration: UIContentConfiguration) {
        guard let config = configuration as? PersonalInfoContentConfiguration else { return }
        nameLabel.text = config.personalInfo.name
        profilePicture.image = config.personalInfo.profilePicture
        
        //legacy code
//        if let firstName = config.currentUser["firstName"] as? String, let lastName = config.currentUser["lastName"] as? String {
//            self.nameLabel.text = firstName.capitalized + " " + lastName.capitalized
//        }
//        let urlString = config.currentUser["profilePicStr"] as! String
//        if let url = URL(string: urlString) {
//            let item = Item(email: "",
//                            firstName: "",
//                            lastName: "",
//                            name: "",
//                            imageUrlString: "",
//                            image: UIImage(systemName: "person.circle.fill")!,
//                            url: url)
//            UrlCachedImages().getCachedImage(url: url , item: item) { fetchedItem, image in
//                if let img = image, img != fetchedItem.image {
//                    self.profilePicture.image = img
//                }
//            }
//        }else {
//            self.profilePicture.image = UIImage(systemName: "person.circle.fill")
//        }
        
        //under test
//        guard let data = self.profilePicture.image?.pngData() else { return }
//        UserDefaults.standard.set(data, forKey: "profilePicture")
//        UserDefaults.standard.set(self.nameLabel.text, forKey: "profileName")
    }
}


//MARK: - table view cell ex
extension UICollectionViewListCell {
    func contentViewCellConfigurationForPersonalInfo() -> PersonalInfoContentView.PersonalInfoContentConfiguration {
        return PersonalInfoContentView.PersonalInfoContentConfiguration()
    }
}

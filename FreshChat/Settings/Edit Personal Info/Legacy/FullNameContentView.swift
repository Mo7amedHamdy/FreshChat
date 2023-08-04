//
//  FullNameContentView.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 29/06/2023.
//

import UIKit

class ProfileNameContentView: UIView, UIContentView, UITextFieldDelegate {
        
    var nameTextField = UITextField()
    
    var configuration: UIContentConfiguration {
        didSet {
            self.configure(configuration)
        }
    }
    
    
    struct ProfileNameContentConfiguration: UIContentConfiguration {
        
        var profileInfo: PersonalInformation! //copy of model data
        
        var onActive: (Bool)->Void = { _ in }
        
        var onChange: (String)->Void = { _ in }
                
        func makeContentView() -> UIView & UIContentView {
            return ProfileNameContentView(self)
        }
        
        func updated(for state: UIConfigurationState) -> ProfileNameContentView.ProfileNameContentConfiguration {
            return self
        }
    }
    
    init(_ configuration: UIContentConfiguration) {
        self.configuration = configuration
        super.init(frame: .zero)
        
        addPinnedSubView(nameTextField, height: 45)
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(textFieldIsSelected), for: .editingDidBegin)
        nameTextField.addTarget(self, action: #selector(textFieldEditingChanged), for: .editingChanged)

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func textFieldIsSelected(_ sender: UITextField) {
        guard let config = configuration as? ProfileNameContentConfiguration else { return }
        config.onActive(true)
    }
    
    @objc func textFieldEditingChanged(_ sender: UITextField) {
        guard let config = configuration as? ProfileNameContentConfiguration else { return }
        guard let text = nameTextField.text else { return }
        config.onChange(text)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ok == true {
            print("ok ok ok")
        }else {
            print("cancel cancel")
        }
    }
    
    func configure(_ configuration: UIContentConfiguration) {
        guard let config = configuration as? ProfileNameContentConfiguration else { return }
        let name = config.profileInfo.name
        nameTextField.text = name
    }
}


//MARK: - content view cell configuration
extension UICollectionViewListCell {
    func contentViewCellConfigurationForProfileName() -> ProfileNameContentView.ProfileNameContentConfiguration {
        return ProfileNameContentView.ProfileNameContentConfiguration()
    }
}

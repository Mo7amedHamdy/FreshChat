//
//  ActivityIndicatorViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 29/11/2022.
//

import UIKit

class ActivityIndicatorViewController: UIViewController {

    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var Activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backView.backgroundColor = .black.withAlphaComponent(0.3)
        Activity.startAnimating()

    }

    init() {
        super.init(nibName: "ActivityIndicatorViewController", bundle: nil)
        self.modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

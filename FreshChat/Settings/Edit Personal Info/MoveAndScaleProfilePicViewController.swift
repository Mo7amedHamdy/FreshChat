//
//  MoveAndScaleProfilePicViewController.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 01/07/2023.
//

import UIKit

protocol TransfereImage {
    func profileImage(image: UIImage)
    func chooseButtonClicked(isChoosen : Bool)
}

class MoveAndScaleProfilePicViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var originImage: UIImageView!
    @IBOutlet weak var croppedImage: UIImageView!
    @IBOutlet weak var moveAndScaleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var chooseButton: UIButton!
    
    var delegateImage: TransfereImage?
    var didOffset: Bool = true
    
    var y: CGFloat = 0
                
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.contentSize = CGSize(width: UIWindow().frame.width, height: UIWindow().frame.height)
        //zoom
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 5
        
        //get y for window
        if UIWindow().frame.height < 750 {
            y = (self.presentingViewController?.view.safeAreaInsets.top)! + 20
        }else {
            y = (self.presentingViewController?.view.safeAreaInsets.top)! + 10
        }
        
        croppedImage.backgroundColor = .black
        croppedImage.layer.opacity = 0.65
        let mask = MaskView(frame: UIWindow().bounds)
        croppedImage.mask = mask.createMask(with: y)  //TODO figure out invert mask ?
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didOffset = true
    }
  
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let originImageHeight = 0.7 * UIWindow().frame.height
        let yOffset = (UIWindow().frame.height - originImageHeight)/2 - view.safeAreaInsets.top

        //content offset to scroll view
        //TODO modify top constrains of original image
        if didOffset  {
            scrollView.setContentOffset(CGPoint(x: 0, y: -yOffset + y + 10), animated: false)
        }

        //move and scale label, choose and cancel buttons constrains
        moveAndScaleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: yOffset - y - 7).isActive = true
        chooseButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(40 + y)).isActive = true
        cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(40 + y)).isActive = true

        //content inset
        let h = UIWindow().frame.height
        let w = UIWindow().frame.width
        let topInset = (h - w)/2 - view.safeAreaInsets.top + ((0.1 * w)/2)
        let bottomInset = (h - w)/2 + ((0.1 * w)/2)
        scrollView.contentInset = UIEdgeInsets(top: topInset - y - 10 /* 10 is top constrain of origin image */ , left: 0, bottom: bottomInset + y - 10 /* 10 is bottom constrain of origin image */, right: 0)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        didOffset = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        scrollView.zoomScale = 1
        originImage.image = nil
    }

    
    //cancel button
    @IBAction func dismissTransition(_ sender: Any) {
        dismiss(animated: true)
    }
    
    //choose image
    @IBAction func chooseImage(_ sender: Any) {
        if let _ = originImage.image {  //TODO figure out crop image ?
            let mask = MaskView(frame: UIWindow().frame)
            mask.centralView.center = CGPoint(x: UIWindow().frame.width/2, y: UIWindow().frame.height/2)
            let gridToImage = mask.centralView.convert(mask.centralView.bounds, to: self.originImage)
            let croppedImage2 = self.originImage.snapshot(of: gridToImage)
            delegateImage?.profileImage(image: croppedImage2)
            delegateImage?.chooseButtonClicked(isChoosen: true)
        }
    }
}


//MARK: - scroll view delegate
//@available(iOS 16.0, *)
extension MoveAndScaleProfilePicViewController: UIScrollViewDelegate {
    
    //determine the view that apply zoom to
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return originImage
    }
}


//MARK: - snapshot of view
extension UIView {
    // Create image snapshot of view.
    func snapshot(of rect: CGRect? = nil) -> UIImage {  //TODO figure out crop image ?
        return UIGraphicsImageRenderer(bounds: rect ?? bounds).image { _ in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
    }
}


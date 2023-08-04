//
//  CroppingView.swift
//  ImageColorization
//
//  Created by Mohamed Hamdy on 19/05/2023.
//

import UIKit

final class CroppingView: UIView {
    // MARK: IBOutlets
    @IBOutlet private var overlayView: UIView!
    @IBOutlet private var cropReferenceView: UIView!
    
    // MARK: Properties
    private let shapeLayer = CAShapeLayer()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        cropReferenceView.layer.cornerRadius = 60
        cropReferenceView.layer.masksToBounds = true

        shapeLayer.frame = overlayView.bounds
        shapeLayer.fillRule = .evenOdd
        
        let path = UIBezierPath(rect: overlayView.bounds)
        path.append(UIBezierPath(rect: cropReferenceView.bounds))
        shapeLayer.path = path.cgPath
        
        overlayView.layer.mask = shapeLayer
    }
}


//MARK: - configure invert mask
class MaskView: UIView {
    
    let centralView = UIView()

     override init(frame: CGRect) {
         super.init(frame: frame)
         self.addSubview(self.centralView)
//         self.backgroundColor = .clear
         self.centralView.backgroundColor = .black
         self.centralView.clipsToBounds = true
//         self.centralView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2)
         let radius = 0.9 * UIWindow().frame.width
         self.centralView.bounds.size = CGSize(width: radius, height: radius)
         self.centralView.layer.cornerRadius = radius / 2
     }

     required init?(coder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
     }
 
    //create mask
    func createMask(with y: CGFloat) -> UIImageView? {
        
        self.centralView.center = CGPoint(x: self.frame.width/2, y: self.frame.height/2 - y)

        //no need to this I think !
//        let prevBGColor = self.backgroundColor  //clear
//       defer {
//         self.backgroundColor = prevBGColor
//       }
        

        self.backgroundColor = .white
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds) //initialize with size
        let image = renderer.image { rendererContext in
            self.layer.render(in: rendererContext.cgContext) //creat image from layer
        }

       guard
         let ciImage = CIImage(image: image)?
         .applyingFilter("CIMaskToAlpha")  //CIMaskToAlpha key:
                                         //Converts a grayscale image to a white image that is masked by alpha.
                                        //the black values become completely transparent.
       else {
         return nil
       }
        
       // Create a UIImage
       let maskImage = UIImage(ciImage: ciImage)
       // Create a UIImageView from the UIImage
       let imageView = UIImageView(image: maskImage)
       // Set the bounds
       imageView.frame = self.bounds
       // Return the imageView
       return imageView
     }
}

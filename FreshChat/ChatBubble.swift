//
//  ChatBubble.swift
//  FreshChat
//
//  Created by Mohamed Hamdy on 01/08/2022.
//

import UIKit
import FirebaseAuth

class ChatBubble: UIView {
    
    var message: Message!
    var drawWithTail: Bool!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        super.backgroundColor = .clear
    }
    
    private var bubbleColor: UIColor? {
      didSet { setNeedsDisplay() }
    }

    override var backgroundColor: UIColor? {
        get { return bubbleColor }
        set { bubbleColor = newValue }
    }
    
    //check current user for drawing chat bubble type
    func checkMessageSender(message: Message, drawWithTail: Bool) {
        self.message = message
        self.drawWithTail = drawWithTail
    }
    
    //Mark:- draw chat bubble
    override func draw(_ rect: CGRect) {
        let bezierPath = UIBezierPath()
        bezierPath.lineWidth = 2
        let bottom = rect.height
        let right = rect.width
        let top = 0.0
//        let left = 0.0

        //chat bubble for current user
        if message.sender == Auth.auth().currentUser?.email {
//            bezierPath.move(to: CGPoint(x: right - 22, y: bottom))
//            bezierPath.addLine(to: CGPoint(x: 17 , y: bottom))
//            bezierPath.addCurve(to: CGPoint(x: left, y: bottom - 18.00), controlPoint1: CGPoint(x: 7.00 , y: bottom), controlPoint2: CGPoint(x: left, y: bottom - 7.00))
//            bezierPath.addLine(to: CGPoint(x: left, y: 18.00 ))
//            bezierPath.addCurve(to: CGPoint(x: 17 , y: top), controlPoint1: CGPoint(x: left, y: 7.00 ), controlPoint2: CGPoint(x: 7.00 , y: top))
//            bezierPath.addLine(to: CGPoint(x: right - 22.00, y: top))
//            bezierPath.addCurve(to: CGPoint(x: right - 4 , y: 17 ), controlPoint1: CGPoint(x: right - 11.00, y: top), controlPoint2: CGPoint(x: right - 4, y: 7.00))
//            bezierPath.addLine(to: CGPoint(x: right - 4 , y: bottom - 11))
//            bezierPath.addCurve(to: CGPoint(x: right, y: bottom), controlPoint1: CGPoint(x: right - 4, y: bottom - 1), controlPoint2: CGPoint(x: right, y: bottom))
//            bezierPath.addLine(to: CGPoint(x: right , y: bottom ))
//            bezierPath.addCurve(to: CGPoint(x: right - 11.00, y: bottom - 4.00), controlPoint1: CGPoint(x: right - 4.00, y: bottom + 0.5), controlPoint2: CGPoint(x: right - 8.00, y: bottom - 1.00))
//            bezierPath.addCurve(to: CGPoint(x: right - 22, y: bottom), controlPoint1: CGPoint(x: right - 16, y: bottom), controlPoint2: CGPoint(x: right - 19, y: bottom))
//            bezierPath.close()

//            bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
//            bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
//            bezierPath.addCurve(to: CGPoint(x: 15, y: bottom - 17), controlPoint1: CGPoint(x: 18 , y: bottom), controlPoint2: CGPoint(x: 15, y: bottom - 6.00))
//            bezierPath.addLine(to: CGPoint(x: 15 , y: 17))
//            bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 15 , y: 6), controlPoint2: CGPoint(x: 18, y: top))
//            bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
//            bezierPath.addCurve(to: CGPoint(x: right - 15, y: 17), controlPoint1: CGPoint(x: right - 18 , y: top), controlPoint2: CGPoint(x: right - 15, y: 6))
//            bezierPath.addLine(to: CGPoint(x: right - 15 , y: bottom - 15))
//            bezierPath.addCurve(to: CGPoint(x: right, y: bottom), controlPoint1: CGPoint(x: right - 14.00, y: bottom - 9.00), controlPoint2: CGPoint(x: right - 6, y: bottom - 2))
//            bezierPath.addCurve(to: CGPoint(x: right - 20.00, y: bottom - 5.00), controlPoint1: CGPoint(x: right - 3.00, y: bottom ), controlPoint2: CGPoint(x: right - 18.00, y: bottom ))
//            bezierPath.addCurve(to: CGPoint(x: right - 30.00, y: bottom), controlPoint1: CGPoint(x: right - 21.00, y: bottom - 4.00), controlPoint2: CGPoint(x: right - 21.00, y: bottom ))
//            bezierPath.close()

            if drawWithTail {
                //new
                bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
                bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
                bezierPath.addCurve(to: CGPoint(x: 10, y: bottom - 17), controlPoint1: CGPoint(x: 13 , y: bottom), controlPoint2: CGPoint(x: 10, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: 10 , y: 17))
                bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 10 , y: 6), controlPoint2: CGPoint(x: 13, y: top))
                bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
                bezierPath.addCurve(to: CGPoint(x: right - 10, y: 17), controlPoint1: CGPoint(x: right - 13 , y: top), controlPoint2: CGPoint(x: right - 10, y: 6))
                bezierPath.addLine(to: CGPoint(x: right - 10 , y: bottom - 10))
                bezierPath.addCurve(to: CGPoint(x: right - 4, y: bottom), controlPoint1: CGPoint(x: right - 10.00, y: bottom - 4.00), controlPoint2: CGPoint(x: right - 6, y: bottom ))
        //        bezierPath.addCurve(to: CGPoint(x: right - 20.00, y: bottom - 5.00), controlPoint1: CGPoint(x: right - 3.00, y: bottom ), controlPoint2: CGPoint(x: right - 18.00, y: bottom ))
        //        bezierPath.addCurve(to: CGPoint(x: right - 30.00, y: bottom), controlPoint1: CGPoint(x: right - 21.00, y: bottom - 4.00), controlPoint2: CGPoint(x: right - 21.00, y: bottom ))
                bezierPath.close()
            }
            else {
                bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
                bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
                bezierPath.addCurve(to: CGPoint(x: 10, y: bottom - 17), controlPoint1: CGPoint(x: 13 , y: bottom), controlPoint2: CGPoint(x: 10, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: 10 , y: 17))
                bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 10 , y: 6), controlPoint2: CGPoint(x: 13, y: top))
                bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
                bezierPath.addCurve(to: CGPoint(x: right - 10, y: 17), controlPoint1: CGPoint(x: right - 13 , y: top), controlPoint2: CGPoint(x: right - 10, y: 6))
                bezierPath.addLine(to: CGPoint(x: right - 10 , y: bottom - 17))
                bezierPath.addCurve(to: CGPoint(x: right - 30, y: bottom), controlPoint1: CGPoint(x: right - 10, y: bottom - 6.00), controlPoint2: CGPoint(x: right - 13, y: bottom))
                bezierPath.close()

            }


        }else {
            //chat bubble for other user
//            bezierPath.move(to: CGPoint(x: 15.00, y: 17.00))
//            bezierPath.addLine(to: CGPoint(x: 15.00, y: bottom - 15.00))
//            bezierPath.addCurve(to: CGPoint(x: left, y: bottom), controlPoint1: CGPoint(x: 14.00, y: bottom - 9.00), controlPoint2: CGPoint(x: 6, y: bottom - 2))
//            bezierPath.addCurve(to: CGPoint(x: 20.00, y: bottom - 5.00), controlPoint1: CGPoint(x: 3.00, y: bottom ), controlPoint2: CGPoint(x: 18.00, y: bottom ))
//            bezierPath.addCurve(to: CGPoint(x: 30.00, y: bottom), controlPoint1: CGPoint(x: 21.00, y: bottom - 4.00), controlPoint2: CGPoint(x: 21.00, y: bottom ))
//            bezierPath.addLine(to: CGPoint(x: right - 30.00, y: bottom))
//            bezierPath.addCurve(to: CGPoint(x: right - 15.00, y: bottom - 17.00), controlPoint1: CGPoint(x: right - 18.00, y: bottom), controlPoint2: CGPoint(x: right - 15.00, y: bottom - 6.00))
//            bezierPath.addLine(to: CGPoint(x: right - 15.00, y: 17.00))
//            bezierPath.addCurve(to: CGPoint(x: right - 30.00, y: top), controlPoint1: CGPoint(x: right - 15 , y: 6), controlPoint2: CGPoint(x: right - 18.00, y: top))
//            bezierPath.addLine(to: CGPoint(x: 30, y: top))
//            bezierPath.addCurve(to: CGPoint(x: 15.00, y: 17), controlPoint1: CGPoint(x: 18 , y: top), controlPoint2: CGPoint(x: 15.00, y:6))
//            bezierPath.close()

            if drawWithTail {
                //new
                bezierPath.move(to: CGPoint(x: 10.00, y: 17.00))
                bezierPath.addLine(to: CGPoint(x: 10.00, y: bottom - 10.00))
                bezierPath.addCurve(to: CGPoint(x: 4, y: bottom), controlPoint1: CGPoint(x: 10.00, y: bottom - 4.00), controlPoint2: CGPoint(x: 6, y: bottom))
//                bezierPath.addCurve(to: CGPoint(x: 20.00, y: bottom - 5.00), controlPoint1: CGPoint(x: 3.00, y: bottom ), controlPoint2: CGPoint(x: 18.00, y: bottom ))
//                bezierPath.addCurve(to: CGPoint(x: 30.00, y: bottom), controlPoint1: CGPoint(x: 21.00, y: bottom - 4.00), controlPoint2: CGPoint(x: 21.00, y: bottom ))
                bezierPath.addLine(to: CGPoint(x: right - 30.00, y: bottom))
                bezierPath.addCurve(to: CGPoint(x: right - 10.00, y: bottom - 17.00), controlPoint1: CGPoint(x: right - 13.00, y: bottom), controlPoint2: CGPoint(x: right - 10.00, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: right - 10.00, y: 17.00))
                bezierPath.addCurve(to: CGPoint(x: right - 30.00, y: top), controlPoint1: CGPoint(x: right - 10 , y: 6), controlPoint2: CGPoint(x: right - 13.00, y: top))
                bezierPath.addLine(to: CGPoint(x: 30, y: top))
                bezierPath.addCurve(to: CGPoint(x: 10.00, y: 17), controlPoint1: CGPoint(x: 13 , y: top), controlPoint2: CGPoint(x: 10.00, y:6))
                bezierPath.close()
            }
            else {
                bezierPath.move(to: CGPoint(x: right - 30, y: bottom))
                bezierPath.addLine(to: CGPoint(x: 30 , y: bottom))
                bezierPath.addCurve(to: CGPoint(x: 10, y: bottom - 17), controlPoint1: CGPoint(x: 13 , y: bottom), controlPoint2: CGPoint(x: 10, y: bottom - 6.00))
                bezierPath.addLine(to: CGPoint(x: 10 , y: 17))
                bezierPath.addCurve(to: CGPoint(x: 30, y: top), controlPoint1: CGPoint(x: 10 , y: 6), controlPoint2: CGPoint(x: 13, y: top))
                bezierPath.addLine(to: CGPoint(x: right - 30 , y: top))
                bezierPath.addCurve(to: CGPoint(x: right - 10, y: 17), controlPoint1: CGPoint(x: right - 13 , y: top), controlPoint2: CGPoint(x: right - 10, y: 6))
                bezierPath.addLine(to: CGPoint(x: right - 10 , y: bottom - 17))
                bezierPath.addCurve(to: CGPoint(x: right - 30, y: bottom), controlPoint1: CGPoint(x: right - 10, y: bottom - 6.00), controlPoint2: CGPoint(x: right - 13, y: bottom))
                bezierPath.close()
            }
        }
        backgroundColor?.setFill()
        bezierPath.fill()
    }
}

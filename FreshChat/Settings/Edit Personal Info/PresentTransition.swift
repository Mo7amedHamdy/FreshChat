//
//  PresentTransition.swift
//  ImageColorization
//
//  Created by Mohamed Hamdy on 22/04/2023.
//

import UIKit

class PresentTransition: NSObject {
    var animator: UIViewImplicitlyAnimating?
}

//MARK: - transition extention
extension PresentTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        animator = interruptibleAnimator(using: transitionContext)
        self.animator?.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if animator != nil {
            return animator!
        }
        
        let container = transitionContext.containerView
        let fromVC = transitionContext.viewController(forKey: .from)! //PHPickerViewController
        
        let fromViewInitialFrame = transitionContext.initialFrame(for: fromVC)
        
        var fromViewFinalFrame = fromViewInitialFrame
        fromViewFinalFrame.origin.x = -fromViewFinalFrame.width/3
        
        let fromView = fromVC.view!
        let toView = transitionContext.view(forKey: .to)!
        
        var toViewInitialFrame = fromViewInitialFrame
        toViewInitialFrame.origin.x = toView.frame.size.width
        
        toView.frame = toViewInitialFrame
        container.addSubview(toView)
        
        //handle height of toView
        if container.frame.height < 750 {
            container.frame.origin.y = container.safeAreaInsets.top + 20
        }
        else {
            container.frame.origin.y = container.safeAreaInsets.top + 10
        }
        
        //animate transition
        let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: .easeInOut) {
            toView.frame = fromViewInitialFrame
            fromView.frame = fromViewFinalFrame
        }
        
        animator.addCompletion { _ in
            transitionContext.completeTransition(true)
        }
        self.animator = animator
        
        return animator
    }
    
    
    func animationEnded(_ transitionCompleted: Bool) {
        self.animator = nil
    }
}

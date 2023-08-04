//
//  DismissTransition.swift
//  ImageColorization
//
//  Created by Mohamed Hamdy on 22/04/2023.
//

import UIKit

class DismissTransition: NSObject {
    var animator: UIViewImplicitlyAnimating?
}

//MARK: - dismiss transition extension
extension DismissTransition: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        animator = interruptibleAnimator(using: transitionContext)
        animator?.startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        if self.animator != nil {
            return self.animator!
        }
        let fromVC = transitionContext.viewController(forKey: .from)!
        let fromView = fromVC.view!
        
        var fromViewInitialFrame = transitionContext.initialFrame(for: fromVC)
        fromViewInitialFrame.origin.x = 0
        var fromViewFinalFrame = fromViewInitialFrame
        fromViewFinalFrame.origin.x = fromViewFinalFrame.width
        
        let toVC = transitionContext.viewController(forKey: .to)! //PHPickerViewController
        let toView = toVC.view!
        var toViewInitialFrame = fromViewInitialFrame
        toViewInitialFrame.origin.x = -toView.frame.size.width/3
        
        toView.frame = toViewInitialFrame
        
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
}

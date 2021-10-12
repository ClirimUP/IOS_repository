//
//  Extensions.swift
//  kwikFM
//
//  Created by MacOS on 08/11/21.
//  Copyright © 2021 MacOS. All rights reserved.
//

import UIKit

extension UIButton {
    
    /**
     
     Sets the background color of a Button in a specific state.
     
     - parameter color: The UIColor that is going to be set for the background.
     - parameter state: The state of the Button.
     
     */
    func setBackgroundColor(to color: UIColor, forState state: UIControlState) {
        
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        UIGraphicsGetCurrentContext()!.setFillColor(color.cgColor)
        UIGraphicsGetCurrentContext()!.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let colorImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        self.setBackgroundImage(colorImage, for: state)
    }
}

extension UIView {
    
    /**
     
     Starts changing the alpha of the UIView from 0 to 1, to make it look like it's blinking.
     
     */
    func startBlink() {
        UIView.animate(withDuration: 0.3,
                       delay:0.0,
                       options:[.allowUserInteraction, .curveEaseInOut, .autoreverse, .repeat],
                       animations: { self.alpha = 0 },
                       completion: nil)
    }
    
    /**
     
     Stops the blinking, removes all the animations and sets the alpha back to 1.
     
     */
    func stopBlink() {
        layer.removeAllAnimations()
        alpha = 1
    }
    
    /**
     
     Starts shaking the UIView by changing its x axis.
     
     */
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-20.0, 20.0, -20.0, 20.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
        layer.borderWidth = 1
        //animation.repeatCount = 1000 if you want it to continue to shake!
    }
    
    func rotate(toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension String {
    
    /**
     
     Removes all white spaces from a String.
     
     */
    func removeWhiteSpaces() -> String {
        return components(separatedBy: .whitespaces).joined()
    }
    
    /**
     
     Verify that the provided String is a URL.
     
     - parameter urlString: The URL String that's going to be checked.
     
     */
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url)
            }
        }
        return false
    }
}

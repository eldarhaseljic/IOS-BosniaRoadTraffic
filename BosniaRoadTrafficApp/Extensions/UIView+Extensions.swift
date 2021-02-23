//
//  UIView+Extensions.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/21/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

// Used from
// https://stackoverflow.com/questions/24034544/dispatch-after-gcd-in-swift
public func delay(_ delay:Double, closure: @escaping () -> ()) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delay,
                                  execute: closure)
}

extension UIView {
    
    public func setRoundedBorder(borderWidth: CGFloat, cornerRadius: CGFloat? = nil,  borderColor: CGColor? = nil){
        layer.borderWidth = borderWidth
        
        if let cornerRadius = cornerRadius {
            layer.cornerRadius = cornerRadius
        } else {
            layer.cornerRadius = frame.size.height / 2
        }
        
        if let color = borderColor {
            layer.borderColor = color
        }
    }
    
    public func setShadow(shadowColor: CGColor, shadowRadius: CGFloat, shadowOpacity: Float = 1.0, shadowOffset: CGSize = CGSize(width: 5.0, height: 5.0)) {
        layer.shadowColor = shadowColor
        layer.shadowRadius = shadowRadius
        layer.shadowOpacity = shadowOpacity
        layer.shadowOffset = shadowOffset
        
    }
}

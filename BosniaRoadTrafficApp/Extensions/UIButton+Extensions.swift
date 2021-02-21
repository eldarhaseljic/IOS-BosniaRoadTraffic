//
//  UIButton+Extensions.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

extension UIButton {
    
    public func setRoundedBorder(borderWidth: CGFloat, borderColor: CGColor? = nil){
        layer.cornerRadius = frame.size.height / 2
        layer.borderWidth = borderWidth
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

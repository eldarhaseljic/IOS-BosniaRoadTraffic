//
//  UIActivityIndicatorView+Extension.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

extension UIActivityIndicatorView {
    
    public func appendBlurredBackground() {
        let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        blurEffectView.frame = frame
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(blurEffectView, at: .zero)
    }
}

//
//  UIActivityIndicatorView+Extensions.swift
//  BosniaRoadConditionsApp
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
        insertSubview(blurEffectView, at: .zero)
    }
}

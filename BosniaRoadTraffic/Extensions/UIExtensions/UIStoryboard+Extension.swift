//
//  UIStoryboard+Extension.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/30/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//  User from
//  https://stackoverflow.com/questions/26056062/uiviewcontroller-extension-to-instantiate-from-storyboard

import Foundation
import UIKit

extension UIStoryboard {
    
    public func instantiateViewControllerWithIdentifier<T>(_ identifier: T.Type) -> T? where T: UIViewController {
        return instantiateViewController(withIdentifier: String(describing: identifier)) as? T
    }
}

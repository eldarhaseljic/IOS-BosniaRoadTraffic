//
//  UIViewController+Extensions.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/23/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func  pushView(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public func  presentView(viewController: UIViewController) {
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    public var backButton: UIBarButtonItem {
        UIBarButtonItem(image: #imageLiteral(resourceName: "chevron.backward"), style: .done, target: self,
                        action: #selector(tapBackButton))
    }
    
    public func getFilterButton(image: UIImage = #imageLiteral(resourceName: "slider.horizontal"), style: UIBarButtonItem.Style = .done, target: Any = self, action: Selector?) -> UIBarButtonItem {
        return UIBarButtonItem(image: image, style: style, target: target, action: action)
    }
    
    public var closeButton: UIBarButtonItem {
        UIBarButtonItem(title: CLOSE, style: .done, target: self, action: #selector(tapCloseButton))
    }
    
    @objc
    public func  tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    public func  tapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

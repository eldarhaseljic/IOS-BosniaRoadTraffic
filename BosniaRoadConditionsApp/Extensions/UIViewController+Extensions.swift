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
    
    func pushView(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func presentView(viewController: UIViewController) {
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    var backButton: UIBarButtonItem {
        UIBarButtonItem(image: #imageLiteral(resourceName: "chevron.backward"), style: .done, target: self,
                        action: #selector(tapBackButton))
    }
    
    var closeButton: UIBarButtonItem {
        UIBarButtonItem(title: CLOSE, style: .done, target: self, action: #selector(tapCloseButton))
    }
    
    @objc
    func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    func tapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

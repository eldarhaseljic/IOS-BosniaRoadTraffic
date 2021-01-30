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
    
    var backButton: UIBarButtonItem {
        UIBarButtonItem(image: #imageLiteral(resourceName: "chevron.backward"),
                        style: .done,
                        target: self,
                        action: #selector(tapBackButton))
    }
    
    @objc
    func tapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

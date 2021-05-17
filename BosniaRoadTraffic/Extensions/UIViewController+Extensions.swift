//
//  UIViewController+Extensions.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/23/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    public func pushView(viewController: UIViewController) {
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    public func presentView(viewController: UIViewController) {
        navigationController?.present(viewController, animated: true, completion: nil)
    }
    
    public var backButton: UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "chevron.backward"), style: .done, target: self, action: #selector(tapBackButton))
    }
    
    public var closeButton: UIBarButtonItem {
        return UIBarButtonItem(title: CLOSE, style: .done, target: self, action: #selector(tapCloseButton))
    }
    
    public func cancelButton(action: Selector = #selector(tapCloseButton)) -> UIBarButtonItem {
        return UIBarButtonItem(title: CANCEL, style: .done, target: self, action: action)
    }
    
    public func backButton(action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(image: #imageLiteral(resourceName: "chevron.backward"), style: .done, target: self, action: action)
    }
    
    public func applyButton(action: Selector) -> UIBarButtonItem {
        return UIBarButtonItem(title: APPLY, style: .done, target: self, action: action)
    }
    
    @objc
    public func tapCloseButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    public func tapBackButton(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    public func presentAlert(title: String?,
                             message: String?,
                             buttonTitle: String,
                             type: UIAlertController.Style = .alert,
                             handler: ((UIAlertAction) -> Void)? = nil) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: type)
        let action = UIAlertAction(title: buttonTitle,
                                   style: .default,
                                   handler: handler)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func openExternalUrl(urlString: String) {
        guard let webURL = URL(string: urlString) else {
            self.presentAlert(title: ERROR_DESCRIPTION,
                              message: ERROR_URL_MESSAGE,
                              buttonTitle: OK,
                              handler: nil)
            return
        }
        
        UIApplication.shared.open(webURL)
    }
    
    @objc
    public func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc
    public func dismissKeyboard() {
        view.endEditing(true)
    }
}

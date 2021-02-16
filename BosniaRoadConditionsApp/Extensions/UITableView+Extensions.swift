//
//  UITableView+Extensions.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/7/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

extension UITableView {
    
    public func registerCell<T>(cellType: T.Type) where T: UITableViewCell {
        register(UINib(nibName: String(describing: cellType.self), bundle: nil),
                 forCellReuseIdentifier: String(describing: cellType.self))
    }
    
    public func dequeueReusableCell<T>(with type: T.Type, for indexPath: IndexPath) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: String(describing: T.self),
                                   for: indexPath) as! T
    }
}

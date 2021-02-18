//
//  Adviser.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/18/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

class Adviser {
    var title: String
    var message: String
    var alertType: UIAlertController.Style
    
    init(title: String, message: String, alertType: UIAlertController.Style = .alert) {
        self.title = title.localizedUppercase
        self.message = message
        self.alertType = alertType
    }
}

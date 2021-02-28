//
//  Adviser.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/18/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

class Adviser {
    var title: String
    var message: String
    var isError: Bool
    
    init(title: String, message: String, isError: Bool = false) {
        self.title = title.localizedCapitalized
        self.message = message
        self.isError = isError
    }
}

//
//  DispatchQueue+Extension.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1/2/22.
//  Copyright © 2022 Eldar Haseljic. All rights reserved.
//

import Foundation

extension DispatchQueue {
    static func background(delay: Double = 0.0, background: (()->Void)? = nil) {
        DispatchQueue.global(qos: .background).async {
            background?()
        }
    }
}

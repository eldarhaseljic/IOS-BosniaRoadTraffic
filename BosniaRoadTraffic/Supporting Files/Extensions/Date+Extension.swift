//
//  Date+Extension.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 5/9/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

extension Date {
    
    public func dateByAddingDays(_ days: Int) -> Date {
        let interval = 60 * 60 * 24 * days
        return self.addingTimeInterval(Double(interval))
    }
}

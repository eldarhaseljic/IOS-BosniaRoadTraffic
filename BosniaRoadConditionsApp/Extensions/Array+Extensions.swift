//
//  Array+Extensions.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/10/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation

extension Array {
    public subscript(safeIndex index: Int) -> Element? {
        guard
            index >= .zero,
            index < endIndex
        else { return nil }
        return self[index]
    }
}

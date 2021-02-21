//
//  Array+Extensions.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 1/10/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//  Used from:
// https://www.hackingwithswift.com/example-code/language/how-to-make-array-access-safer-using-a-custom-subscript

import Foundation

extension Array: Emptiable {
    
    public subscript(safeIndex index: Int) -> Element? {
        guard
            index >= .zero,
            index < endIndex
        else { return nil }
        return self[index]
    }
}

//
//  Optional+Extensions.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

public protocol Emptiable {
    var isEmpty: Bool { get }
    var isNotEmpty: Bool { get }
}

extension Emptiable {
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Dictionary: Emptiable { }
extension Set: Emptiable { }
extension Optional where Wrapped: Emptiable {
    public var isNilOrEmtpy: Bool {
        switch self {
        case .none:
            return true
        case .some(let value):
            return value.isEmpty
        }
    }
    
    public var isNotNilNotEmpty: Bool {
        return !isNilOrEmtpy
    }
}

//
//  String+Extensions.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

extension String: Emptiable {
    
    public var withoutHtmlTags: String {
        return self
            .replacingOccurrences(of: "<br />", with: "\r\n")
            .replacingOccurrences(of: "<[^>]+>", with: "",
                                  options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: "",
                                  options:.regularExpression, range: nil)
    }
}

//
//  TrafficEndpoints.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/10/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation

let apiToken = String()
//
// "b0aomDjZPKuHs3NCNS8YTzvQMEeLsChAFGQYjiX8CtqjGRSOnkhap8OjIGrQ"

enum TrafficEndponins: String {
    case radars = "http://bihamk.ba/api/v1/spi/radars?api_token=%@"
    
    var endpoint: URL {
        switch self {
        case .radars:
            guard let url = URL(string: String(format: rawValue, apiToken)) else { fatalError() }
            return url
        }
    }
}

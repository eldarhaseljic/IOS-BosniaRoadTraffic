//
//  DetailsData.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1. 6. 2021..
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum DetailsDataType: String {
    case roadSign
    case roadDetails
    case radar
}

class DetailsData {
    var title: String?
    var subtitle: String?
    var road: String?
    var validFrom: String?
    var validTo: String?
    var text: String?
    var type: String?
    
    init(roadSign: RoadSign) {
        self.title = roadSign.title
        self.subtitle = roadSign.roadType
        self.road = roadSign.road
        self.validFrom = roadSign.validFrom
        self.validTo = roadSign.validTo
        self.text = roadSign.text
    }
    
    init(roadDetails: RoadConditionDetails) {
        self.title = roadDetails.title
        self.subtitle = roadDetails.roadConditionType
        self.validFrom = roadDetails.validFrom
        self.validTo = roadDetails.validTo
        self.text = roadDetails.text
    }
    
    init(radar: Radar) {
        self.title = radar.title
        self.subtitle = radar.policeDepartmentName
        self.validFrom = radar.validFrom
        self.validTo = radar.validTo
        self.road = radar.road
        self.text = radar.text
        self.type = radar.radarType.rawValue
    }
}

//
//  DetailsViewModel.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum DetailsType: String {
    case roadSign
    case roadDetails
    case radar
}

class DetailsViewModel {
    
    var detailsType: DetailsType
    var dataId: String?
    var title: String?
    var subtitle: String?
    var road: String?
    var validFrom: String?
    var validTo: String?
    var text: String?
    var type: String?
    var numberOfDeletions: Int
    let manager: MainManager
    
    init(roadSign: RoadSign,
         manager: MainManager = MainManager.shared) {
        self.detailsType = .roadSign
        self.title = roadSign.title
        self.subtitle = roadSign.roadType
        self.road = roadSign.road
        self.validFrom = roadSign.validFrom
        self.validTo = roadSign.validTo
        self.text = roadSign.text
        self.numberOfDeletions = roadSign.numberOfDeletions.intValue
        self.dataId = roadSign.id
        self.manager = manager
    }
    
    init(roadDetails: RoadConditionDetails,
         manager: MainManager = MainManager.shared) {
        self.detailsType = .roadDetails
        self.title = roadDetails.title
        self.subtitle = roadDetails.roadConditionType
        self.validFrom = roadDetails.validFrom
        self.validTo = roadDetails.validTo
        self.text = roadDetails.text
        self.numberOfDeletions = .zero
        self.dataId = roadDetails.id
        self.manager = manager
    }
    
    init(radar: Radar,
         manager: MainManager = MainManager.shared) {
        self.detailsType = .radar
        self.title = radar.title
        self.subtitle = radar.policeDepartmentName
        self.validFrom = radar.validFrom
        self.validTo = radar.validTo
        self.road = radar.road
        self.text = radar.text
        self.type = radar.radarType.rawValue
        self.dataId = radar.id
        self.numberOfDeletions = radar.numberOfDeletions.intValue
        self.manager = manager
    }
    
    func updateOrDeleteElement(_ completion: ((_ success: FirestoreStatus, _ error: String) -> Void)?) {
        manager.updateOrDelete(detailsViewModel: self, completion)
    }
}

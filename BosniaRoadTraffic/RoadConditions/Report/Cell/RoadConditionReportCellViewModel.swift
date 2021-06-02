//
//  RoadConditionReportCellViewModel.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1. 6. 2021..
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import MapKit

class RoadConditionReportCellViewModel {
    
    private var location: CLLocation!
    private let manager: MainManager!
    private var conditionSings: [SignIcon] = [.border_crossings,
                                              .road_rehabilitation,
                                              .complete_suspension,
                                              .prohibition_for_trucks,
                                              .congestion,
                                              .landslide,
                                              .traffic_accident,
                                              .glaze,
                                              .danger]
    private var roadTypes: [RoadType] = [.border_crossings,
                                         .city_roads,
                                         .highways,
                                         .mainways,
                                         .regional_roads]
    
    init(for location: CLLocation, manager: MainManager = MainManager.shared) {
        self.location = location
        self.currentConditionSing = SELECT_CONDITION_SIGN
        self.currentRoadType = SELECT_ROAD_TYPE
        self.manager = manager
    }
    
    var currentConditionSing: String?
    var currentRoadType: String?
    
    var locationString: String {
        return String(location.coordinate.latitude.description)
            .appending(",")
            .appending(location.coordinate.longitude.description)
    }
    
    var numberOfConditionSings: Int {
        return conditionSings.count
    }
    
    var numberOfRoadTypes: Int {
        return roadTypes.count
    }
    
    func getConditionSingName(for row: Int) -> String? {
        return conditionSings[safeIndex: row]?.name
    }
    
    func getRoadTypeName(for row: Int) -> String? {
        return roadTypes[safeIndex: row]?.name
    }
    
    func getConditionSing(for conditionSingString: String?) -> SignIcon? {
        return conditionSings.first(where: { $0.name == conditionSingString })
    }
    
    func getRoadType(for roadString: String?) -> RoadType? {
        return roadTypes.first(where: { $0.name == roadString })
    }
    
    func addNewRoadCondition(roadType: RoadType,
                             road: String?,
                             text: String?,
                             title: String,
                             signIcon: SignIcon,
                             _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        let startDate = dateFormatter.string(from: currentDate)
        let endDate = dateFormatter.string(from: currentDate.dateByAddingDays(1))
        let roadConditionParameters: RoadConditionParameters = RoadConditionParameters(icon: signIcon.icon,
                                                                                       coordinates: locationString,
                                                                                       road: road,
                                                                                       text: text,
                                                                                       title: title,
                                                                                       validFrom: startDate,
                                                                                       validTo: endDate,
                                                                                       roadTypeID: roadType.id,
                                                                                       roadTypeName: roadType.name,
                                                                                       updatedAt: startDate)
        manager.addNewRoadCondition(roadConditions: roadConditionParameters, completion)
    }
}

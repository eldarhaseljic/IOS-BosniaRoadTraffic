//
//  RoadConditionReportCellViewModel.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on  1/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import MapKit

class RoadConditionReportCellViewModel {
    
    private var location: CLLocation!
    private let manager: MainManager!
    private var conditionTypes: [ConditionType] = [.border_crossing,
                                              .road_rehabilitation,
                                              .complete_suspension,
                                              .prohibition_for_trucks,
                                              .congestion,
                                              .landslide,
                                              .traffic_accident,
                                              .glaze,
                                              .danger]
    private var roadTypes: [RoadType] = [.border_crossing,
                                         .city_road,
                                         .highway,
                                         .mainway,
                                         .regional_road]
    
    init(for location: CLLocation, manager: MainManager = MainManager.shared) {
        self.location = location
        self.currentConditionType = SELECT_CONDITION_SIGN
        self.currentRoadType = SELECT_ROAD_TYPE
        self.manager = manager
    }
    
    var currentConditionType: String?
    var currentRoadType: String?
    
    var locationString: String {
        return String(location.coordinate.latitude.description)
            .appending(",")
            .appending(location.coordinate.longitude.description)
    }
    
    var numberOfConditionTypes: Int {
        return conditionTypes.count
    }
    
    var numberOfRoadTypes: Int {
        return roadTypes.count
    }
    
    func getConditionTypeName(for row: Int) -> String? {
        return conditionTypes[safeIndex: row]?.presentValue
    }
    
    func getRoadTypeName(for row: Int) -> String? {
        return roadTypes[safeIndex: row]?.presentValue
    }
    
    func getConditionType(for conditionTypeString: String?) -> ConditionType? {
        return conditionTypes.first(where: { $0.presentValue == conditionTypeString })
    }
    
    func getRoadType(for roadString: String?) -> RoadType? {
        return roadTypes.first(where: { $0.presentValue == roadString })
    }
    
    func addNewRoadCondition(roadType: RoadType,
                             road: String?,
                             text: String?,
                             title: String,
                             conditionType: ConditionType,
                             _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        let startDate = dateFormatter.string(from: currentDate)
        let endDate = dateFormatter.string(from: currentDate.dateByAddingDays(1))
        let roadConditionParameters: RoadConditionParameters = RoadConditionParameters(icon: conditionType.icon,
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

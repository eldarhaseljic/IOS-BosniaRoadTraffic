//
//  RadarReportCellViewModel.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 5/8/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import MapKit

class RadarReportCellViewModel {
    
    private var location: CLLocation!
    private let manager: MainManager!
    private var radarTypes: [RadarType] = [.announced, .stationary]
    private var MUPs: [PoliceDepartment] = [
        .bosansko_podrinjski_kanton,
        .brcko_distrikt,
        .hercegovacko_neretvanski_kanton,
        .kanton10,
        .posavski,
        .republikaSrpska,
        .sarajevski_kanton,
        .srednjobosanski_kanton,
        .tuzlanski_kanton,
        .unsko_sanski_kanton,
        .zapadnohercegovacki_kanton,
        .zenicko_dobojski_kanton
    ]
    
    init(for location: CLLocation, manager: MainManager = MainManager.shared) {
        self.location = location
        self.currentRadarType = SELECT_RADAR_TYPE
        self.currentMUP = SELECT_POLICE_DEPARTMENT
        self.manager = manager
    }
    
    var currentRadarType: String?
    var currentMUP: String?
    
    var locationString: String {
        return String(location.coordinate.latitude.description).appending(",").appending(location.coordinate.longitude.description)
    }
    
    var numberOfRadarTypes: Int {
        return radarTypes.count
    }
    
    var numberOfMUPs: Int {
        return MUPs.count
    }
    
    func getRadarType(for row: Int) -> String? {
        return radarTypes[safeIndex: row]?.rawValue
    }
    
    func getMUPType(for row: Int) -> String? {
        return MUPs[safeIndex: row]?.name
    }
    
    func getRadarType(for radarTypeString: String?) -> RadarType? {
        return radarTypes.first(where: { $0.rawValue == radarTypeString })
    }
    
    private func getPoliceDepartmentID(for MUPTypeString: String?) -> Int? {
        return MUPs.first(where: { $0.name == MUPTypeString })?.id
    }
    
    func addNewRadar(policeDepartmentName: String?, road: String?, text: String?, title: String, type: RadarType, _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        let dateFormatter : DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let currentDate = Date()
        let startDate = dateFormatter.string(from: currentDate)
        var endDate: String? = nil
        
        if type == .announced {
            endDate = dateFormatter.string(from: currentDate.dateByAddingDays(1))
        }
        
        var radarParameters: RadarParameters = RadarParameters(coordinates: locationString,
                                                               title: title,
                                                               type: type.pickerValue)
        
        if policeDepartmentName != SELECT_POLICE_DEPARTMENT {
            radarParameters.policeDepartmentID = getPoliceDepartmentID(for: policeDepartmentName)
            radarParameters.policeDepartmentName = policeDepartmentName
        }
        
        radarParameters.road = road
        radarParameters.text = text
        radarParameters.validFrom = startDate
        radarParameters.validTo = endDate
        radarParameters.updatedAt = startDate
        manager.addNewRadar(radarParameters: radarParameters, completion)
    }
}

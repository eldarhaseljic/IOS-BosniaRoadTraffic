//
//  FilterViewModel.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/12/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

protocol TypeOption {
    var numberOfElements: Int { get }
    var typeValue: String { get }
    var isOn: Bool { get }
}

enum FilterType {
    case radars
    case roadConditions
}

class RadarTypeOption: TypeOption {
    func copy(with zone: NSZone? = nil) -> RadarTypeOption {
        return RadarTypeOption(type: type, numberOfElements: numberOfElements, isOn: isOn)
    }
    
    var numberOfElements: Int
    var type: RadarType
    var isOn: Bool
    
    var typeValue: String {
        return type.rawValue
    }
    
    init(type: RadarType,
         numberOfElements: Int,
         isOn: Bool = true) {
        self.type = type
        self.isOn = isOn
        self.numberOfElements = numberOfElements
    }
}

class ConditionTypeOption: TypeOption {
    func copy(with zone: NSZone? = nil) -> ConditionTypeOption {
        return ConditionTypeOption(type: type, numberOfElements: numberOfElements, isOn: isOn)
    }
    
    var numberOfElements: Int
    var type: ConditionType
    var isOn: Bool
    
    var typeValue: String {
        return type.name
    }
    
    init(type: ConditionType,
         numberOfElements: Int,
         isOn: Bool = true) {
        self.type = type
        self.isOn = isOn
        self.numberOfElements = numberOfElements
    }
}

class FilterViewModel {
    
    private var backupRadarFilters: [RadarTypeOption] = []
    private var radarTypes: [RadarTypeOption] = []
    private var radarsInDatabase: [Radar] = []
    
    private var backupConditionFilters: [ConditionTypeOption] = []
    private var conditionTypes: [ConditionTypeOption] = []
    private var roadConditionsInDatabase: [RoadCondition] = []
    
    private var filterType: FilterType
    
    init(radars: [Radar]) {
        radarsInDatabase = radars
        filterType = .radars
        checkTypes()
        updateFilters()
    }
    
    init(roadConditions: [RoadCondition]) {
        roadConditionsInDatabase = roadConditions
        filterType = .roadConditions
        checkTypes()
        updateFilters()
    }
    
    func filterRadars() -> [Radar] {
        var radars: [Radar] = []
        radarTypes.forEach { option in
            if option.isOn {
                radarsInDatabase.forEach { radar in
                    if radar.radarType == option.type {
                        radars.append(radar)
                    }
                }
            }
        }
        
        updateFilters()
        return radars
    }
    
    func filterRoadConditions() -> [RoadCondition] {
        var roadConditions: [RoadCondition] = []
        conditionTypes.forEach { option in
            if option.isOn {
                roadConditionsInDatabase.forEach { roadCondition in
                    if roadCondition.roadConditionType == option.type {
                        roadConditions.append(roadCondition)
                    }
                }
            }
        }
        
        updateFilters()
        return roadConditions
    }
    
    func resetFilters() {
        switch filterType {
        case .radars:
            radarTypes = backupRadarFilters.compactMap { $0.copy() }
        case .roadConditions:
            conditionTypes = backupConditionFilters.compactMap { $0.copy() }
        }
    }
    
    func updateFilters() {
        switch filterType {
        case .radars:
            backupRadarFilters = radarTypes.compactMap { $0.copy() }
        case .roadConditions:
            backupConditionFilters = conditionTypes.compactMap { $0.copy() }
        }
    }
    
    private func checkTypes() {
        switch filterType {
        case .radars:
            let defaultRadarTypes: [RadarType] = [.announced, .stationary]
            defaultRadarTypes.forEach { type in
                if radarsInDatabase.contains(where: { $0.radarType == type }) {
                    radarTypes.append(RadarTypeOption(type: type,
                                                      numberOfElements: getNumberOfElementsByType(type: type.rawValue),
                                                      isOn: true))
                }
            }
        case .roadConditions:
            let defaultConditionTypes: [ConditionType] = [.danger,
                                                .border_crossings,
                                                .road_rehabilitation,
                                                .complete_suspension,
                                                .prohibition_for_trucks,
                                                .congestion,
                                                .landslide,
                                                .traffic_accident,
                                                .glaze]
            defaultConditionTypes.forEach { type in
                if roadConditionsInDatabase.contains(where: { $0.roadConditionType == type }) {
                    conditionTypes.append(ConditionTypeOption(type: type,
                                                    numberOfElements: getNumberOfElementsByType(type: type.rawValue),
                                                    isOn: true))
                }
            }
        }
    }
    
    private func getNumberOfElementsByType(type: String) -> Int {
        var numberOfType: Int = .zero
        switch filterType {
        case .radars:
            radarsInDatabase.forEach { radar in
                if radar.radarType.rawValue == type {
                    numberOfType += 1
                }
            }
        case .roadConditions:
            roadConditionsInDatabase.forEach { roadCondition in
                if roadCondition.roadConditionType.rawValue == type {
                    numberOfType += 1
                }
            }
        }
        return numberOfType
    }
    
    func selectType(index: Int, selected: Bool) {
        switch filterType {
        case .radars:
            radarTypes[safeIndex: index]?.isOn = selected
            if !radarTypes.contains(where: { $0.isOn == true }) {
                radarTypes.first?.isOn = true
            }
        case .roadConditions:
            conditionTypes[safeIndex: index]?.isOn = selected
            if !conditionTypes.contains(where: { $0.isOn == true }) {
                conditionTypes.first?.isOn = true
            }
        }
    }
    
    func getOption(index: Int) -> TypeOption {
        return filterType == .radars ? radarTypes[index] : conditionTypes[index]
    }
    
    var numberOfFilters: Int {
        return filterType == .radars ? radarTypes.count : conditionTypes.count
    }
}

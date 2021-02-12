//
//  RadarFilterViewModel.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/12/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

class RadarTypeOption {
    func copy(with zone: NSZone? = nil) -> RadarTypeOption {
        return RadarTypeOption(type: type, isOn: isOn)
    }
    
    var type: RadarType
    var isOn: Bool
    
    init(type: RadarType, isOn: Bool = true) {
        self.type = type
        self.isOn = isOn
    }
}

class RadarFilterViewModel {
    
    private var radarsInDatabase: [Radar] = []
    private var backupFilters: [RadarTypeOption] = []
    private var radarTypes: [RadarTypeOption] = []
    
    init(radars: [Radar]) {
        radarsInDatabase = radars
        if checkRadarType(type: .stationary) {
            radarTypes.append(RadarTypeOption(type: .stationary, isOn: true))
        }
        
        if checkRadarType(type: .temporary) {
            radarTypes.append(RadarTypeOption(type: .temporary, isOn: true))
        }
        
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
    
    func resetFilters() {
        radarTypes = backupFilters.compactMap { $0.copy() }
    }
    
    func updateFilters() {
        backupFilters = radarTypes.compactMap { $0.copy() }
    }
    
    func checkRadarType(type: RadarType) -> Bool {
        return radarsInDatabase.contains { $0.radarType == type }
    }
    
    func selectRadarType(index: Int, selected: Bool) {
        guard let radarType = radarTypes[safeIndex: index]?.type else { return }
        if selected == false {
            radarTypes.forEach { option in
                if option.type != radarType {
                    option.isOn = true
                }
            }
        }
        radarTypes[safeIndex: index]?.isOn = selected
    }
    
    func getRadarOption(index: Int) -> RadarTypeOption {
        return radarTypes[index]
    }
    
    var numberOfFilters: Int {
        return radarTypes.count
    }
}

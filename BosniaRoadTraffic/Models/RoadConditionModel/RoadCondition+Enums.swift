//
//  RoadCondition+Enums.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 31/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum ConditionType: String {
    
    case border_crossing
    case road_rehabilitation
    case complete_suspension
    case prohibition_for_trucks
    case congestion
    case landslide
    case traffic_accident
    case glaze
    case danger
    
    var icon: String {
        switch self {
        case .border_crossing:
            return Constants.ImageTitles.border_crossing
        case .road_rehabilitation:
            return Constants.ImageTitles.road_rehabilitation
        case .complete_suspension:
            return Constants.ImageTitles.complete_suspension
        case .prohibition_for_trucks:
            return Constants.ImageTitles.prohibition_for_trucks
        case .congestion:
            return Constants.ImageTitles.congestion
        case .landslide:
            return Constants.ImageTitles.landslide
        case .traffic_accident:
            return Constants.ImageTitles.traffic_accident
        case .glaze:
            return Constants.ImageTitles.glaze
        case .danger:
            return Constants.ImageTitles.danger
        }
    }
    
    var presentValue: String {
        switch self {
        case .border_crossing:
            return BORDER_CROSSING
        case .road_rehabilitation:
            return ROAD_REHABILITATION
        case .complete_suspension:
            return COMPLETE_SUSPENSION
        case .prohibition_for_trucks:
            return PROHIBITION_FOR_TRUCKS
        case .congestion:
            return CONGESTION
        case .landslide:
            return LANDSIDE
        case .traffic_accident:
            return TRAFFIC_ACCIDENT
        case .glaze:
            return GLAZE
        case .danger:
            return DANGER
        }
    }
}

enum RoadType: String {
    
    case border_crossing
    case highway
    case mainway
    case regional_road
    case city_road
        
    var id: Int {
        switch self {
        case .border_crossing:
            return 39
        case .highway:
            return 40
        case .mainway:
            return 41
        case .regional_road:
            return 42
        case .city_road:
            return 43
        }
    }
    
    var presentValue: String {
        switch self {
        case .border_crossing:
            return BORDER_CROSSING
        case .highway:
            return HIGHWAY
        case .mainway:
            return MAINWAY
        case .regional_road:
            return REGIONAL_ROAD
        case .city_road:
            return CITY_ROAD
        }
    }
    
    var name: String {
        switch self {
        case .border_crossing:
            return "Border crossing"
        case .highway:
            return "Highway"
        case .mainway:
            return "Mainway"
        case .regional_road:
            return "Regional road"
        case .city_road:
            return "City road"
        }
    }
}

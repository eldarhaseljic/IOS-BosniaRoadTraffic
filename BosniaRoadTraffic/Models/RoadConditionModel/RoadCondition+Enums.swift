//
//  RoadSing+Enums.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 31/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum SignIcon: String {
    
    case border_crossings
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
        case .border_crossings:
            return Constants.ImageTitles.border_crossings
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
    
    var name: String {
        switch self {
        case .border_crossings:
            return "Granični prijelaz"
        case .road_rehabilitation:
            return "Sanacija kolovoza"
        case .complete_suspension:
            return "Potpuna obustava prometa"
        case .prohibition_for_trucks:
            return "Zabrana za teretna vozila"
        case .congestion:
            return "Zagušenje"
        case .landslide:
            return "Odron"
        case .traffic_accident:
            return "Saobraćajna nezgoda"
        case .glaze:
            return "Poledica"
        case .danger:
            return "Opasnost"
        }
    }
}

enum RoadType: String {
    
    case border_crossings
    case highways
    case mainways
    case regional_roads
    case city_roads
        
    var id: Int {
        switch self {
        case .border_crossings:
            return 39
        case .highways:
            return 40
        case .mainways:
            return 41
        case .regional_roads:
            return 42
        case .city_roads:
            return 43
        }
    }
    
    var name: String {
        switch self {
        case .border_crossings:
            return "Granični prijelaz"
        case .highways:
            return "Autocesta"
        case .mainways:
            return "Magistralna cesta"
        case .regional_roads:
            return "Regionalna cesta"
        case .city_roads:
            return "Gradska cesta"
        }
    }
}

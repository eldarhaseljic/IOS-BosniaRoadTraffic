//
//  Radar+Enums.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 5/8/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum RadarType: String {
    case stationary
    case announced
    
    var rawValue: String {
        switch self {
        case .stationary:
            return STATIONARY
        case .announced:
            return ANNOUNCED
        }
    }
    
    var pickerValue: Int {
        switch self {
        case .stationary:
            return 1
        case .announced:
            return 2
        }
    }
}

enum PoliceDepartmentType: String {
    case zenicko_dobojski_kanton
    case sarajevski_kanton
    case unsko_sanski_kanton
    case tuzlanski_kanton
    case srednjobosanski_kanton
    case zapadnohercegovacki_kanton
    case brcko_distrikt
    case posavski
    case hercegovacko_neretvanski_kanton
    case bosansko_podrinjski_kanton
    case kanton10
    case republikaSrpska
    
    var policeDepartmentName: String {
        switch self {
        case .zenicko_dobojski_kanton:
            return "MUP Zeničko-dobojskog kantona"
        case .sarajevski_kanton:
            return "MUP Kantona Sarajevo"
        case .unsko_sanski_kanton:
            return "MUP Unsko-sanskog kantona"
        case .tuzlanski_kanton:
            return "MUP Tuzlanskog kantona"
        case .srednjobosanski_kanton:
            return "MUP Srednjobosanskog kantona"
        case .zapadnohercegovacki_kanton:
            return "MUP Zapadno-hercegovačkog kantona"
        case .brcko_distrikt:
            return "Policija Brčko distrikta"
        case .posavski:
            return "MUP Posavski"
        case .hercegovacko_neretvanski_kanton:
            return "MUP Hercegovačko-neretvanskog kantona"
        case .bosansko_podrinjski_kanton:
            return "MUP Bosansko-podrinjskog kantona"
        case .kanton10:
            return "MUP Kantona 10 (Livno)"
        case .republikaSrpska:
            return "MUP Republike Srpske"
        }
    }
    
    var policeDepartmentID: Int {
        switch self {
        case .zenicko_dobojski_kanton:
            return 46
        case .sarajevski_kanton:
            return 47
        case .unsko_sanski_kanton:
            return 83
        case .tuzlanski_kanton:
            return 84
        case .srednjobosanski_kanton:
            return 93
        case .zapadnohercegovacki_kanton:
            return 105
        case .brcko_distrikt:
            return 118
        case .posavski:
            return 117
        case .hercegovacko_neretvanski_kanton:
            return 113
        case .bosansko_podrinjski_kanton:
            return 112
        case .kanton10:
            return 110
        case .republikaSrpska:
            return 120
        }
    }
}

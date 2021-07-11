//
//  Constants.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

final class Constants {
    struct StoryboardIdentifiers {
        static let RadarsMapStoryboard = "RadarsMapStoryboard"
        static let DetailsStoryboard = "DetailsStoryboard"
        static let FilterStoryboard = "FilterStoryboard"
        static let RadarReportStoryboard = "RadarReportStoryboard"
        static let RoadConditionsStoryboard = "RoadConditionsStoryboard"
        static let RoadConditionReportStoryboard = "RoadConditionReportStoryboard"
    }
    
    struct Identifiers {
        static let Radar = "Radar"
    }
    
    struct URLPaths {
        static let facebookURL = "https://www.facebook.com"
        static let instagramURL = "https://www.instagram.com"
        static let twitterURL = "https://www.twitter.com"
        static let linkedInURL = "https://www.linkedin.com"
        static let errorURL = "error url"
    }
    
    struct ImageTitles {
        static let border_crossings = "carina.png"
        static let road_rehabilitation = "sanacija_kolovoza.png"
        static let complete_suspension = "potpuna_obustava.png"
        static let prohibition_for_trucks = "zabrana_za_teretna_vozila.png"
        static let congestion = "zagusenje.png"
        static let landslide = "odron.png"
        static let traffic_accident = "saobracajna_nezgoda.png"
        static let glaze = "poledica.png"
        static let danger = "opasnost.png"
    }
    
    struct BorderWidth {
        static let OnePoint: CGFloat = 1.0
        static let TwoPoints: CGFloat = 2.0
    }
    
    struct CornerRadius {
        static let FourPoints: CGFloat = 4.0
        static let EightPoints: CGFloat = 8.0
    }
    
    struct ShadowRadius {
        static let HalfPoint: CGFloat = 0.5
        static let ThreePoints: CGFloat = 3.0
    }
    
    struct Time {
        static let TenSeconds: Double = 10.0
    }
    
    static let ReportPinSize: CGSize = CGSize(width: 45.0, height: 45.0)
}

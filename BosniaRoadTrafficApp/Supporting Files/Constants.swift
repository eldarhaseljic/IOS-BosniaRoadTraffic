//
//  Constants.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 1/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

final class Constants {
    class StoryboardIdentifiers {
        static let RadarsMapStoryboard = "RadarsMapStoryboard"
        static let RadarDetailsStoryboard = "RadarDetailsStoryboard"
        static let RadarFilterStoryboard = "RadarFilterStoryboard"
        static let RoadConditionsStoryboard = "RoadConditionsStoryboard"
        static let RoadConditionsDetailsStoryboard = "RoadConditionsDetailsStoryboard"
    }
    
    class Identifiers {
        static let Radar = "Radar"
    }
    
    class URLPaths {
        static let roadSignIcon = "https://bihamk.ba/assets/img/road-icons/%@"
    }
    
    class ImageTitles {
        static let carina = "carina.png"
        static let sanacijaKolovoza = "sanacija-kolovoza.png"
        static let potpunaObustava = "potpuna-obustava.png"
        static let zabranaZaTeretnaVozila = "zabrana-za-teretna-vozila.png"
        static let zagusenje = "zagusenje.png"
        static let odron = "odron.png"
    }
    
    class BorderWidth {
        static let OnePoint: CGFloat = 1.0
    }
    
    class CornerRadius {
        static let EightPoints: CGFloat = 8.0
    }
    
    class Time {
        static let TenSeconds: Double = 10.0
    }
}

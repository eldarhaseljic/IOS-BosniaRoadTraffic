//
//  AppColor.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 31/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

enum AppColor: String {
    
    case black
    case cadetBlueCrayola
    case darkGrey
    case davysGrey
    case davysGreyLight
    case gunmetal
    case manatee
    case slateGray
    case white
    
    public var color: UIColor {
        switch self {
        case .black:
            return #colorLiteral(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        case .cadetBlueCrayola:
            return #colorLiteral(red: 0.678, green: 0.710, blue: 0.741, alpha: 1.0)
        case .darkGrey:
            return #colorLiteral(red: 0.129, green: 0.154, blue: 0.161, alpha: 1.0)
        case .davysGreyLight:
            return #colorLiteral(red: 0.765, green: 0.765, blue: 0.765, alpha: 1.0)
        case .davysGrey:
            return #colorLiteral(red: 0.286, green: 0.314, blue: 0.341, alpha: 1.0)
        case .gunmetal:
            return #colorLiteral(red: 0.154, green: 0.227, blue: 0.251, alpha: 1.0)
        case .manatee:
            return #colorLiteral(red: 0.165, green: 0.169, blue: 0.169, alpha: 1.0)
        case .slateGray:
            return #colorLiteral(red: 0.424, green: 0.459, blue: 0.490, alpha: 1.0)
        case .white:
            return #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
    var cgColor: CGColor {
        return color.cgColor
    }
}

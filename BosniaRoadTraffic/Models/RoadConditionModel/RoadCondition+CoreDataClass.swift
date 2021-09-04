//
//  RoadCondition+CoreDataClass.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

enum RoadConditionJSON: String {
    case id
    case icon
    case title
    case coordinates
    case road
    case validFrom = "valid_from"
    case validTo = "valid_to"
    case text
    case categoryID = "category_id"
    case categoryName = "category_name"
    case numberOfDeletions
    case updatedAt = "updated_at"
}

public class RoadCondition: NSManagedObject, MKAnnotation {
    
    @NSManaged public var roadID: NSNumber?
    @NSManaged public var roadType: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var iconTitle: String?
    @NSManaged public var id: String?
    @NSManaged public var road: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    @NSManaged public var numberOfDeletions: NSNumber
    
    public var locationName: String? {
        if text.isNotNilNotEmpty {
            return text
        } else if road.isNotNilNotEmpty {
            return road
        } else {
            return roadType
        }
    }
    
    public var subtitle: String? {
        return locationName?.withoutHtmlTags
    }
    
    var isCoordinateZero: Bool {
        return coordinate.latitude.isZero && coordinate.latitude.isZero
    }
    
    var hasNoIcon: Bool {
        return iconTitle.isNilOrEmtpy
    }
    
    var shouldDeleteRoadCondition: Bool {
        return isCoordinateZero || hasNoIcon || numberOfDeletions.intValue > 5
    }
    
    public var coordinate: CLLocationCoordinate2D {
        guard
            let latitudeAndLongitude = coordinates?.split(separator: ","),
            let latitudeString = latitudeAndLongitude[safeIndex: 0],
            let longitudeString = latitudeAndLongitude[safeIndex: 1],
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString)
        else {
            return CLLocationCoordinate2D(latitude: .zero, longitude: .zero)
        }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var image: UIImage {
        switch iconTitle {
        case ConditionType.border_crossings.icon:
            return #imageLiteral(resourceName: "carina")
        case ConditionType.road_rehabilitation.icon:
            return #imageLiteral(resourceName: "sanacija_kolovoza")
        case ConditionType.complete_suspension.icon:
            return #imageLiteral(resourceName: "potpuna_obustava")
        case ConditionType.prohibition_for_trucks.icon:
            return #imageLiteral(resourceName: "zabrana_za_teretna_vozila")
        case ConditionType.congestion.icon:
            return #imageLiteral(resourceName: "zagusenje")
        case ConditionType.landslide.icon:
            return #imageLiteral(resourceName: "odron")
        case ConditionType.traffic_accident.icon:
            return #imageLiteral(resourceName: "saobracajna_nezgoda")
        case ConditionType.glaze.icon:
            return #imageLiteral(resourceName: "poledica")
        default:
            return #imageLiteral(resourceName: "opasnost")
        }
    }
    
    var roadConditionType: ConditionType {
        switch iconTitle {
        case Constants.ImageTitles.border_crossings:
            return .border_crossings
        case Constants.ImageTitles.road_rehabilitation:
            return .road_rehabilitation
        case Constants.ImageTitles.complete_suspension:
            return .complete_suspension
        case Constants.ImageTitles.prohibition_for_trucks:
            return .prohibition_for_trucks
        case Constants.ImageTitles.congestion:
            return .congestion
        case Constants.ImageTitles.landslide:
            return .landslide
        case Constants.ImageTitles.traffic_accident:
            return .traffic_accident
        case Constants.ImageTitles.glaze:
            return .glaze
        default:
            return .danger
        }
    }
    
    public override var description: String {
        return "{ \n\t'id':\(String(describing: id)),\n"
            + "\t'title':'\(String(describing: title))',\n"
            + "\t'coordinates':'\(String(describing: coordinates))',\n"
            + "\t'icon':'\(String(describing: iconTitle))',\n"
            + "\t'latitude':\(coordinate.latitude.description),\n"
            + "\t'longitude':\(coordinate.longitude.description),\n"
            + "\t'road':'\(String(describing: road))',\n"
            + "\t'valid_from':\(String(describing: validFrom)),\n"
            + "\t'numberOfDeletions':'\(String(describing: numberOfDeletions))',\n"
            + "\t'valid_to':\(String(describing: validTo)),\n"
            + "\t'text':\(String(describing: text)),\n"
            + "\t'category_id':\(String(describing: roadID)),\n"
            + "\t'category_name':'\(String(describing: roadType))'\n }"
    }
}

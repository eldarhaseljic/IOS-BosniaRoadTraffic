//
//  RoadSign+CoreDataClass.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

enum RoadSignJSON: String {
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
    case updatedAt = "updated_at"
}

public class RoadSign: NSManagedObject, MKAnnotation {
    
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
        guard let title = iconTitle else { return #imageLiteral(resourceName: "opasnost") }
        
        switch title {
        case SignIcon.border_crossings.icon:
            return #imageLiteral(resourceName: "carina")
        case SignIcon.road_rehabilitation.icon:
            return #imageLiteral(resourceName: "sanacija_kolovoza")
        case SignIcon.complete_suspension.icon:
            return #imageLiteral(resourceName: "potpuna_obustava")
        case SignIcon.prohibition_for_trucks.icon:
            return #imageLiteral(resourceName: "zabrana_za_teretna_vozila")
        case SignIcon.congestion.icon:
            return #imageLiteral(resourceName: "zagusenje")
        case SignIcon.landslide.icon:
            return #imageLiteral(resourceName: "zagusenje")
        case SignIcon.traffic_accident.icon:
            return #imageLiteral(resourceName: "saobracajna_nezgoda")
        case SignIcon.glaze.icon:
            return #imageLiteral(resourceName: "poledica")
        case SignIcon.danger.icon:
            return #imageLiteral(resourceName: "opasnost")
        default:
            return #imageLiteral(resourceName: "opasnost")
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
            + "\t'valid_to':\(String(describing: validTo)),\n"
            + "\t'text':\(String(describing: text)),\n"
            + "\t'category_id':\(String(describing: roadID)),\n"
            + "\t'category_name':'\(String(describing: roadType))'\n }"
    }
}

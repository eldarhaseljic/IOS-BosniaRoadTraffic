//
//  Radar+CoreDataClass.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import CoreData
import Contacts
import MapKit

enum RadarJSON: String {
    case id
    case title
    case coordinates
    case type
    case road
    case validFrom = "valid_from"
    case validTo = "valid_to"
    case text
    case categoryID = "category_id"
    case categoryName = "category_name"
    case updatedAt = "updated_at"
}

public class Radar: NSManagedObject, MKAnnotation {
    
    @NSManaged public var policeDepartmentID: NSNumber?
    @NSManaged public var policeDepartmentName: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var id: String?
    @NSManaged public var road: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    
    public var locationName: String? {
        if text.isNotNilNotEmpty {
            return text
        } else if road.isNotNilNotEmpty {
            return road
        } else {
            return policeDepartmentName
        }
    }
    
    public var subtitle: String? {
        return locationName?.withoutHtmlTags
    }
    
    var markerTintColor: UIColor {
        switch type {
        case 1:
            return .red
        default:
            return .yellow
        }
    }
    
    var image: UIImage {
        return #imageLiteral(resourceName: "speed_camera")
    }
    
    var radarType: RadarType {
        switch type {
        case 1:
            return .stationary
        default:
            return .announced
        }
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
    
    public var isCoordinateZero: Bool {
        return coordinate.latitude.isZero && coordinate.latitude.isZero
    }
    
    public override var description: String {
        return "{ \n\t'id':\(String(describing: id)),\n"
            + "\t'title':'\(String(describing: title))',\n"
            + "\t'coordinates':'\(String(describing: coordinates))',\n"
            + "\t'latitude':\(coordinate.latitude.description),\n"
            + "\t'longitude':\(coordinate.longitude.description),\n"
            + "\t'type':\(String(describing: type)),\n"
            + "\t'convertedType':\(String(describing: radarType.rawValue)),\n"
            + "\t'road':'\(String(describing: road))',\n"
            + "\t'valid_from':\(String(describing: validFrom)),\n"
            + "\t'valid_to':\(String(describing: validTo)),\n"
            + "\t'text':\(String(describing: text)),\n"
            + "\t'policeDepartmentID':\(String(describing: policeDepartmentID)),\n"
            + "\t'policeDepartmentName':'\(String(describing: policeDepartmentName))'\n }"
    }
}

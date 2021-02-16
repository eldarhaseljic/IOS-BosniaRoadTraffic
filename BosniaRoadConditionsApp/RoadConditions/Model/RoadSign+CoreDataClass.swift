//
//  RoadSign+CoreDataClass.swift
//  BosniaRoadConditionsApp
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
    
    @NSManaged public var categoryID: NSNumber?
    @NSManaged public var categoryName: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var iconTitle: String?
    @NSManaged public var iconData: Data?
    @NSManaged public var id: NSNumber?
    @NSManaged public var road: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var updatedAt: String?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    
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
    
    var isCoordinateZero: Bool {
        return coordinate.latitude.isZero && coordinate.latitude.isZero
    }
    
    var hasNoIcon: Bool {
        return iconData == nil
    }
    
    var image: UIImage {
        guard
            let data = iconData,
            let image = UIImage(data: data)
        else { return #imageLiteral(resourceName: "danger_sign") }
        return image
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
            + "\t'category_id':\(String(describing: categoryID)),\n"
            + "\t'category_name':'\(String(describing: categoryName))',\n"
            + "\t'updated_at':'\(String(describing: updatedAt))' \n }"
    }
}

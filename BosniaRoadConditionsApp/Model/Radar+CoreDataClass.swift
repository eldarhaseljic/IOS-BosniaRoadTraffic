//
//  Radar+CoreDataClass.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation
import CoreData
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
    
    @NSManaged public var categoryID: NSNumber?
    @NSManaged public var categoryName: String?
    @NSManaged public var coordinateString: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var road: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var type: NSNumber?
    @NSManaged public var updatedAt: String?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    
    public var coordinate: CLLocationCoordinate2D {
        guard
            let latitudeAndLongitude = coordinateString?.split(separator: ","),
            let latitudeString = latitudeAndLongitude[safeIndex: 0],
            let longitudeString = latitudeAndLongitude[safeIndex: 1],
            let latitude = Double(latitudeString),
            let longitude = Double(longitudeString)
        else { return CLLocationCoordinate2D(latitude: .zero, longitude: .zero) }
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var isRegular: Bool {
        return text?.isEmpty == true
    }
    
    func fillRadarInfo(_ radarJSON: [String: Any]) {
        if let categoryID = radarJSON[RadarJSON.categoryID.rawValue] as? NSNumber {
            self.categoryID = categoryID
        }
        
        if let categoryName = radarJSON[RadarJSON.categoryName.rawValue] as? String {
            self.categoryName = categoryName
        }
        
        if let coordinateString = radarJSON[RadarJSON.coordinates.rawValue] as? String {
            self.coordinateString = coordinateString
        }
        
        if let road = radarJSON[RadarJSON.road.rawValue] as? String {
            self.road = road
        }
        
        if let text = radarJSON[RadarJSON.text.rawValue] as? String {
            self.text = text
        }
        
        if let title = radarJSON[RadarJSON.title.rawValue] as? String {
            self.title = title
        }
        
        if let type = radarJSON[RadarJSON.type.rawValue] as? NSNumber {
            self.type = type
        }
        
        if let updatedAt = radarJSON[RadarJSON.updatedAt.rawValue] as? String {
            self.updatedAt = updatedAt
        }
        
        if let validFrom = radarJSON[RadarJSON.validFrom.rawValue] as? String {
            self.validFrom = validFrom
        }
        
        if let validTo = radarJSON[RadarJSON.validTo.rawValue] as? String {
            self.validTo = validTo
        }
    }
    
    public override var description: String {
        return "{ \n\t'id':\(String(describing: id)),\n"
            + "\t'title':'\(String(describing: title))',\n"
            + "\t'coordinates':'\(String(describing: coordinateString))',\n"
            + "\t'latitude':\(coordinate.latitude.description),\n"
            + "\t'longitude':\(coordinate.longitude.description),\n"
            + "\t'type':\(String(describing: type)),\n"
            + "\t'road':'\(String(describing: road))',\n"
            + "\t'valid_from':\(String(describing: validFrom)),\n"
            + "\t'valid_to':\(String(describing: validTo)),\n"
            + "\t'text':\(String(describing: text)),\n"
            + "\t'category_id':\(String(describing: categoryID)),\n"
            + "\t'category_name':'\(String(describing: categoryName))',\n"
            + "\t'updated_at':'\(String(describing: updatedAt))' \n }"
    }
}

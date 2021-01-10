//
//  Radar.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/10/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation
import MapKit

enum RaradError: Error{
    case noDataAvailable
    case canNotProcessData
}

class Radar: NSObject, Decodable, MKAnnotation {
    let id: Int?
    let title: String?
    let coordinateString: String?
    let type: Int?
    let road: String?
    let validFrom: String?
    let validTo: String?
    let text: String?
    let categoryID: Int?
    let categoryName: String?
    let updatedAt: String?
    
    var coordinate: CLLocationCoordinate2D {
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
    
    enum CodingKeys: String, CodingKey {
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
    
    init(id: Int?, title: String?, coordinateString: String?, type: Int?,
         road: String?, validFrom: String?, validTo: String?, text: String?,
         categoryID: Int?, categoryName: String?, updatedAt: String?) {
            self.id = id
            self.title = title
            self.coordinateString = coordinateString
            self.type = type
            self.road = road
            self.validFrom = validFrom
            self.validTo = validTo
            self.text = text
            self.categoryID = categoryID
            self.categoryName = categoryName
            self.updatedAt = updatedAt
        }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        coordinateString = try values.decodeIfPresent(String.self, forKey: .coordinates)
        type = try values.decodeIfPresent(Int.self, forKey: .type)
        road = try values.decodeIfPresent(String.self, forKey: .road)
        validFrom = try values.decodeIfPresent(String.self, forKey: .validFrom)
        validTo = try values.decodeIfPresent(String.self, forKey: .validTo)
        text = try values.decodeIfPresent(String.self, forKey: .text)
        categoryID = try values.decodeIfPresent(Int.self, forKey: .categoryID)
        categoryName = try values.decodeIfPresent(String.self, forKey: .categoryName)
        updatedAt = try values.decodeIfPresent(String.self, forKey: .updatedAt)
    }
    
    override var description: String {
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

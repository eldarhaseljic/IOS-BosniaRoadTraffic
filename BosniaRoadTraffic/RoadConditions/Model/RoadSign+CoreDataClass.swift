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
    
    @NSManaged public var categoryID: NSNumber?
    @NSManaged public var categoryName: String?
    @NSManaged public var coordinates: String?
    @NSManaged public var iconTitle: String?
    @NSManaged public var id: NSNumber?
    @NSManaged public var road: String?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    
    public var locationName: String? {
        if text.isNotNilNotEmpty {
            return text
        } else if categoryName.isNotNilNotEmpty {
            return categoryName
        } else {
            return road
        }
    }
    
    public var subtitle: String? {
        return locationName?.withoutHtmlTags
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
    
    var isCoordinateZero: Bool {
        return coordinate.latitude.isZero && coordinate.latitude.isZero
    }
    
    var hasNoIcon: Bool {
        return iconTitle.isNilOrEmtpy
    }
    
    var image: UIImage {
        return getRoadSignIcon()
    }
    
    private func getRoadSignIcon() -> UIImage {
        guard let title = iconTitle else { return #imageLiteral(resourceName: "danger_sign") }
        
        switch true {
        case title == RoadSignType.carina.rawValue:
            return #imageLiteral(resourceName: "carina")
        case title == RoadSignType.sanacijaKolovoza.rawValue:
            return #imageLiteral(resourceName: "sanacija-kolovoza")
        case title == RoadSignType.potpunaObustava.rawValue:
            return #imageLiteral(resourceName: "potpuna-obustava")
        case title == RoadSignType.zabranaZaTeretnaVozila.rawValue:
            return #imageLiteral(resourceName: "zabrana-za-teretna-vozila")
        case title == RoadSignType.zagusenje.rawValue:
            return #imageLiteral(resourceName: "zagusenje")
        case title == RoadSignType.odron.rawValue:
            return #imageLiteral(resourceName: "zagusenje")
        default:
            guard
                let url = URL(string: title),
                let iconData = try? Data(contentsOf: url),
                let image = UIImage(data: iconData)
            else { return #imageLiteral(resourceName: "danger_sign") }
            return image
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
            + "\t'category_id':\(String(describing: categoryID)),\n"
            + "\t'category_name':'\(String(describing: categoryName))',\n"
    }
}

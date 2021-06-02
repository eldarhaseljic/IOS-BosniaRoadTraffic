//
//  RoadConditionDetails+CoreDataClass.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1. 6. 2021..
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData

enum RoadConditionDetailsJSON: String {
    case id
    case title
    case validFrom = "startDate"
    case validTo = "endDate"
    case text
    case categoryID = "category_id"
    case categoryName = "category_name"
}

@objc(RoadConditionDetails)
public class RoadConditionDetails: NSManagedObject {
    
    @NSManaged public var id: String?
    @NSManaged public var title: String?
    @NSManaged public var validFrom: String?
    @NSManaged public var validTo: String?
    @NSManaged public var text: String?
    @NSManaged public var roadConditionID: NSNumber?
    @NSManaged public var roadConditionType: String?
    
    public override var description: String {
        return "{ \n\t'id':\(String(describing: id)),\n"
            + "\t'title':'\(String(describing: title))',\n"
            + "\t'valid_from':\(String(describing: validFrom)),\n"
            + "\t'valid_to':\(String(describing: validTo)),\n"
            + "\t'text':\(String(describing: text)),\n"
            + "\t'category_id':\(String(describing: roadConditionID)),\n"
            + "\t'category_name':'\(String(describing: roadConditionType))'\n }"
    }
}

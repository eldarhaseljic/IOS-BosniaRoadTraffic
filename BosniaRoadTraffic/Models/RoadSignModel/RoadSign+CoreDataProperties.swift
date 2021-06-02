//
//  RoadSign+CoreDataProperties.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData

extension RoadSign {
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RoadSign> {
        return NSFetchRequest<RoadSign>(entityName: entityName)
    }
    
    class func findOrCreate(_ roadSignId: String, context: NSManagedObjectContext) -> RoadSign {
        let predicate = roadSignByIdPredicate(for: roadSignId)
        let sign = findOrCreate(in: context, matching: predicate) { $0.id = roadSignId }
        return sign
    }
    
    func fillSignInfo(_ roadSignJSON: [String: Any]) {
        if let roadConditionID = roadSignJSON[RoadSignJSON.categoryID.rawValue] as? NSNumber {
            self.roadID = roadConditionID
        }
        
        if let roadConditionType = roadSignJSON[RoadSignJSON.categoryName.rawValue] as? String {
            self.roadType = roadConditionType
        }
        
        if let coordinates = roadSignJSON[RoadSignJSON.coordinates.rawValue] as? String {
            self.coordinates = coordinates
        }
        
        if let road = roadSignJSON[RoadSignJSON.road.rawValue] as? String {
            self.road = road
        }
        
        if let validFrom = roadSignJSON[RoadSignJSON.validFrom.rawValue] as? String {
            self.validFrom = validFrom
        }
        
        if let validTo = roadSignJSON[RoadSignJSON.validTo.rawValue] as? String {
            self.validTo = validTo
        }
        
        if let text = roadSignJSON[RoadSignJSON.text.rawValue] as? String {
            self.text = text
        }
        
        if let title = roadSignJSON[RoadSignJSON.title.rawValue] as? String {
            self.title = title.capitalized
        }
        
        if let iconTitle = roadSignJSON[RoadSignJSON.icon.rawValue] as? String {
            self.iconTitle = iconTitle
        }
    }
    
    public static func ==(lhs: RoadSign, rhs: RoadSign) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.id == rhs.id &&
            lhs.roadID == rhs.roadID &&
            lhs.roadType == rhs.roadType &&
            lhs.coordinates == rhs.coordinates &&
            lhs.road == rhs.road &&
            lhs.validFrom == rhs.validFrom &&
            lhs.validTo == rhs.validTo &&
            lhs.text == rhs.text &&
            lhs.iconTitle == rhs.iconTitle
    }
}

extension RoadSign: Managed {
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(id), ascending: true)]
    }
    
    static func roadSignByIdPredicate(for roadSignId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(id), roadSignId)
    }
    
    public static var entityName: String {
        return "RoadSign"
    }
}

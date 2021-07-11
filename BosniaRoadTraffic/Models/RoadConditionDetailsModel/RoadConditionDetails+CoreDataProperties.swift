//
//  RoadConditionDetails+CoreDataProperties.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on  1/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData

extension RoadConditionDetails {

    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RoadConditionDetails> {
        return NSFetchRequest<RoadConditionDetails>(entityName: entityName)
    }
    
    class func findOrCreate(_ roadConditionDetailsId: String, context: NSManagedObjectContext) -> RoadConditionDetails {
        let predicate = roadConditionDetailsByIdPredicate(for: roadConditionDetailsId)
        let details = findOrCreate(in: context, matching: predicate) { $0.id = roadConditionDetailsId }
        return details
    }

    func fillInfo(_ roadConditionDetailsJSON: [String: Any]) {
        if let roadConditionID = roadConditionDetailsJSON[RoadConditionDetailsJSON.categoryID.rawValue] as? NSNumber {
            self.roadConditionID = roadConditionID
        }
        
        if let roadConditionType = roadConditionDetailsJSON[RoadConditionDetailsJSON.categoryName.rawValue] as? String {
            self.roadConditionType = roadConditionType
        }
        
        if let validFrom = roadConditionDetailsJSON[RoadConditionDetailsJSON.validFrom.rawValue] as? String {
            self.validFrom = validFrom
        }
        
        if let validTo = roadConditionDetailsJSON[RoadConditionDetailsJSON.validTo.rawValue] as? String {
            self.validTo = validTo
        }
        
        if let text = roadConditionDetailsJSON[RoadConditionDetailsJSON.text.rawValue] as? String {
            self.text = text
        }
        
        self.numberOfDeletions = roadConditionDetailsJSON[RoadConditionDetailsJSON.numberOfDeletions.rawValue] as? NSNumber ?? 0
        
        if let title = roadConditionDetailsJSON[RoadConditionDetailsJSON.title.rawValue] as? String {
            self.title = title.capitalized
        }
    }
  
    public static func ==(lhs: RoadConditionDetails, rhs: RoadConditionDetails) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.id == rhs.id &&
            lhs.roadConditionID == rhs.roadConditionID &&
            lhs.roadConditionType == rhs.roadConditionType &&
            lhs.validFrom == rhs.validFrom &&
            lhs.validTo == rhs.validTo &&
            lhs.text == rhs.text &&
            lhs.numberOfDeletions == rhs.numberOfDeletions
    }
}

extension RoadConditionDetails: Managed {
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(validFrom), ascending: true)]
    }
    
    static func roadConditionDetailsByIdPredicate(for roadConditionDetailId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(id), roadConditionDetailId)
    }
    
    public static var entityName: String {
        return "RoadConditionDetails"
    }
}

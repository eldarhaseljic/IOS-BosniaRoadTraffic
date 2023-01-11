//
//  RoadCondition+CoreDataProperties.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//

import Foundation
import CoreData

extension RoadCondition {
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<RoadCondition> {
        return NSFetchRequest<RoadCondition>(entityName: entityName)
    }
    
    class func findOrCreate(_ roadConditionId: String, context: NSManagedObjectContext) -> RoadCondition {
        let predicate = roadConditionByIdPredicate(for: roadConditionId)
        let condition = findOrCreate(in: context, matching: predicate) { $0.id = roadConditionId }
        return condition
    }
    
    private static var roadTypes: [RoadType] = [.border_crossing,
                                                .city_road,
                                                .highway,
                                                .mainway,
                                                .regional_road]
    
    func fillConditionInfo(_ roadConditionJSON: [String: Any]) {
        if let roadConditionID = roadConditionJSON[RoadConditionJSON.categoryID.rawValue] as? NSNumber {
            self.roadID = roadConditionID
            let tempType = RoadCondition.roadTypes.first(where: { $0.id == roadConditionID.intValue })?.presentValue
            if let roadConditionType = roadConditionJSON[RoadConditionJSON.categoryName.rawValue] as? String {
                self.roadType = tempType.isNotNilNotEmpty ? tempType : roadConditionType
            }
        }
        
        if let coordinates = roadConditionJSON[RoadConditionJSON.coordinates.rawValue] as? String {
            self.coordinates = coordinates
        }
        
        if let road = roadConditionJSON[RoadConditionJSON.road.rawValue] as? String {
            self.road = road
        }
        
        if let validFrom = roadConditionJSON[RoadConditionJSON.validFrom.rawValue] as? String {
            self.validFrom = validFrom
        }
        
        self.numberOfDeletions = roadConditionJSON[RoadConditionJSON.numberOfDeletions.rawValue] as? NSNumber ?? 0
        
        if let validTo = roadConditionJSON[RoadConditionJSON.validTo.rawValue] as? String {
            self.validTo = validTo
        }
        
        if let text = roadConditionJSON[RoadConditionJSON.text.rawValue] as? String {
            self.text = text
        }
        
        if let title = roadConditionJSON[RoadConditionJSON.title.rawValue] as? String {
            self.title = title.capitalized
        }
        
        if let iconTitle = roadConditionJSON[RoadConditionJSON.icon.rawValue] as? String {
            self.iconTitle = iconTitle
        }
    }
    
    public static func ==(lhs: RoadCondition, rhs: RoadCondition) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.id == rhs.id &&
            lhs.roadID == rhs.roadID &&
            lhs.roadType == rhs.roadType &&
            lhs.coordinates == rhs.coordinates &&
            lhs.road == rhs.road &&
            lhs.validFrom == rhs.validFrom &&
            lhs.validTo == rhs.validTo &&
            lhs.numberOfDeletions == rhs.numberOfDeletions &&
            lhs.text == rhs.text &&
            lhs.iconTitle == rhs.iconTitle
    }
}

extension RoadCondition: Managed {
    
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(id), ascending: true)]
    }
    
    static func roadConditionByIdPredicate(for roadConditionId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(id), roadConditionId)
    }
    
    public static var entityName: String {
        return "RoadCondition"
    }
}

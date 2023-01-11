//
//  Radar+CoreDataProperties.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import CoreData

extension Radar {
    
    @nonobjc
    public class func fetchRequest() -> NSFetchRequest<Radar> {
        return NSFetchRequest<Radar>(entityName: entityName)
    }
    
    class func findOrCreate(_ radarId: String, context: NSManagedObjectContext) -> Radar {
        let predicate = radarByIdPredicate(for: radarId)
        let program = findOrCreate(in: context, matching: predicate) { $0.id = radarId }
        return program
    }
    
    func fillRadarInfo(_ radarJSON: [String: Any]) {
        if let policeDepartmentID = radarJSON[RadarJSON.categoryID.rawValue] as? NSNumber {
            self.policeDepartmentID = policeDepartmentID
        }
        
        if let policeDepartmentName = radarJSON[RadarJSON.categoryName.rawValue] as? String {
            self.policeDepartmentName = policeDepartmentName
        }
        
        if let coordinates = radarJSON[RadarJSON.coordinates.rawValue] as? String {
            self.coordinates = coordinates
        }
        
        if let road = radarJSON[RadarJSON.road.rawValue] as? String {
            self.road = road
        }
        
        if let validFrom = radarJSON[RadarJSON.validFrom.rawValue] as? String {
            self.validFrom = validFrom
        }
        
        if let validTo = radarJSON[RadarJSON.validTo.rawValue] as? String {
            self.validTo = validTo
        }
        
        if let text = radarJSON[RadarJSON.text.rawValue] as? String {
            self.text = text
        }
        
        if let type = radarJSON[RadarJSON.type.rawValue] as? NSNumber {
            self.type = type
        }
        
        self.numberOfDeletions = radarJSON[RadarJSON.numberOfDeletions.rawValue] as? NSNumber ?? 0
        
        if let title = radarJSON[RadarJSON.title.rawValue] as? String {
            self.title = title
        }
    }
    
    public static func ==(lhs: Radar, rhs: Radar) -> Bool {
        return
            lhs.title == rhs.title &&
            lhs.id == rhs.id &&
            lhs.policeDepartmentID == rhs.policeDepartmentID &&
            lhs.policeDepartmentName == rhs.policeDepartmentName &&
            lhs.coordinates == rhs.coordinates &&
            lhs.road == rhs.road &&
            lhs.validFrom == rhs.validFrom &&
            lhs.validTo == rhs.validTo &&
            lhs.text == rhs.text &&
            lhs.numberOfDeletions == rhs.numberOfDeletions &&
            lhs.type == rhs.type
    }
}

extension Radar: Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] {
        return [NSSortDescriptor(key: #keyPath(id), ascending: true)]
    }
    
    static func radarByIdPredicate(for radarId: String) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(id), radarId)
    }
    
    public static var entityName: String {
        return "Radar"
    }
}

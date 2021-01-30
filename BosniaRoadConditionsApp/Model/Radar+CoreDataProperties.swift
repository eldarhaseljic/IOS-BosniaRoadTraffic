//
//  Radar+CoreDataProperties.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import CoreData

extension Radar {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Radar> {
        return NSFetchRequest<Radar>(entityName: entityName)
    }
    
    class func findOrCreate(_ radarId: NSNumber, context: NSManagedObjectContext) -> Radar {
        let predicate = radarByIdPredicate(for: radarId)
        let program = findOrCreate(in: context, matching: predicate) { $0.id = radarId }
        return program
    }
}

extension Radar: Managed {
    static func radarByIdPredicate(for radarId: NSNumber) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(id), radarId)
    }
    
    public static var entityName: String {
        return "Radar"
    }
}

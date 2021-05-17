//
//  NSManagedObjectContext+Extensions.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//  User from:
//  https://github.com/objcio/core-data/blob/master/SharedCode/NSManagedObjectContext%2BExtensions.swift

import Foundation
import CoreData

extension NSManagedObjectContext {
    public func insertObject<A: NSManagedObject>() -> A where A: Managed {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: A.entityName, into: self) as? A else { fatalError("Wrong object type") }
        return obj
    }
    
    public func saveOrRollback() -> Bool {
        do {
            try save()
            return true
        } catch {
            rollback()
            return false
        }
    }
}

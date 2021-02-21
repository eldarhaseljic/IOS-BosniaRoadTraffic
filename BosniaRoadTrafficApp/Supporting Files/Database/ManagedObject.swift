//
//  ManagedObject.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//
//  Used from: https://github.com/objcio/core-data/blob/master/SharedCode/Managed.swift

import Foundation
import CoreData

public protocol Managed: class, NSFetchRequestResult {
    static var entity: NSEntityDescription { get }
    static var entityName: String { get }
}

extension Managed where Self: NSManagedObject {
    
    public static var entity: NSEntityDescription { return entity()  }
    public static var entityName: String { return entity.name! }
    public static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    
    public static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
    
    
    public static func findOrCreate(in context: NSManagedObjectContext,
                                    matching predicate: NSPredicate,
                                    configure: (Self) -> ()) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject: Self = context.insertObject()
            configure(newObject)
            return newObject
        }
        
        return object
    }
    
    
    public static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
            }.first
        }
        
        return object
    }
    
    public static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        
        let request = NSFetchRequest<Self>(entityName: Self.entityName)
        configurationBlock(request)
        
        do {
            let results = try context.fetch(request)
            return results
        } catch {
            print(error.localizedDescription)
        }
        
        return []
    }
    
    public static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        
        for object in context.registeredObjects where !object.isFault {
            guard
                let result = object as? Self,
                predicate.evaluate(with: result)
            else { continue }
            return result
        }
        return nil
    }
}

//
//  MainManager.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class MainManager {
    
    static let shared = MainManager()
    private let networkService = NetworkService.shared
    private let persistanceService = PersistanceService.shared
    
    func fetchRadars(objectContext: NSManagedObjectContext = PersistanceService.shared.context) -> [Radar] {
        let fetchRequest = NSFetchRequest<Radar>(entityName: Radar.entityName)
        
        var radars = [Radar]()
        do {
            radars = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return radars
    }
    
    func getRadars(_ completion:((_ success: Bool, _ error: NSError?) -> Void)?) {
        networkService.request(TrafficEndponins.radars.endpoint) { [weak self] (result) in
            guard let self = self else { return }
            let oldRadars = self.fetchRadars(objectContext: self.persistanceService.context)
            print("Number of old radars: \(oldRadars.count) \n \(oldRadars)")
            switch result {
            case .success(let data):
                do {
                    guard let radars = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                        // Error message
                        return
                    }
                    
                    var newRadarsIDs: [NSNumber] = []
                    for currentRadar in radars {
                        guard let radarID = currentRadar[RadarJSON.id.rawValue] as? NSNumber else { continue }
                        newRadarsIDs.append(radarID)
                        let newRadar = Radar.findOrCreate(radarID, context: self.persistanceService.context)
                        newRadar.fillRadarInfo(currentRadar)
                    }
                    
                    for oldRadar in oldRadars {
                        if let oldRadarID = oldRadar.id,
                           !newRadarsIDs.contains(oldRadarID) {
                            self.persistanceService.context.delete(oldRadar)
                        }
                    }
                    
                    let status = self.persistanceService.context.saveOrRollback()
                    completion?(status, nil)
                } catch {
                    // Error message
                    completion?(false, error as NSError)
                }
            case .failure(let error):
                // Error message
                completion?(false, error)
            }
        }
    }
}

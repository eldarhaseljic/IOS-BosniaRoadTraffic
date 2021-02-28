//
//  MainManager.swift
//  Bosnia Road Traffic 
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
    
    private func fetchRadars(objectContext: NSManagedObjectContext) -> [Radar] {
        let fetchRequest = NSFetchRequest<Radar>(entityName: Radar.entityName)
        
        var radars = [Radar]()
        do {
            radars = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return radars
    }
    
    private func fetchRoadSigns(objectContext: NSManagedObjectContext) -> [RoadSign] {
        let fetchRequest = NSFetchRequest<RoadSign>(entityName: RoadSign.entityName)
        
        var roadSigns = [RoadSign]()
        do {
            roadSigns = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return roadSigns
    }
    
    func getRadars(_ completion: ((_ success: [Radar]?, _ error: String?) -> Void)?) {
        networkService.request(TrafficEndponins.radars.endpoint) { [weak self] (result) in
            guard let self = self else {
                completion?([], CustomError.internalError.errorDescription)
                return
            }
            
            let writeManagedObjectContext = self.persistanceService.backgroundContext
            
            writeManagedObjectContext.perform {
                let oldRadars = self.fetchRadars(objectContext: writeManagedObjectContext)
                print("Number of old radars: \(oldRadars.count) \n \(oldRadars)")
                switch result {
                case .success(let data):
                    do {
                        guard let radars = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                            completion?(oldRadars, CustomError.canNotProcessData.errorDescription)
                            return
                        }
                        
                        var newRadarsIDs: [NSNumber] = []
                        for currentRadar in radars {
                            guard let radarID = currentRadar[RadarJSON.id.rawValue] as? NSNumber else { continue }
                            newRadarsIDs.append(radarID)
                            let newRadar = Radar.findOrCreate(radarID, context: writeManagedObjectContext)
                            newRadar.fillRadarInfo(currentRadar)
                            if newRadar.isCoordinateZero {  writeManagedObjectContext.delete(newRadar)
                            }
                        }
                        
                        for oldRadar in oldRadars {
                            if let oldRadarID = oldRadar.id,
                               !newRadarsIDs.contains(oldRadarID) {
                                writeManagedObjectContext.delete(oldRadar)
                            }
                        }
                        
                        let status = writeManagedObjectContext.saveOrRollback()
                        if status {
                            completion?(nil, nil)
                        } else {
                            completion?(oldRadars, CustomError.dataBaseError.errorDescription)
                        }
                    } catch {
                        completion?(oldRadars, String(format: THANK_YOU_FOR_UNDERSTANDING, error.localizedDescription))
                    }
                case .failure(let error):
                    completion?(oldRadars, String(format: THANK_YOU_FOR_UNDERSTANDING, error.localizedDescription))
                }
            }
        }
    }
    
    func getRoadConditions(_ completion: ((_ success: [RoadSign]?, _ error: String?) -> Void)?) {
        networkService.request(TrafficEndponins.rodarInfo.endpoint) { [weak self] (result) in
            guard let self = self else {
                completion?([], CustomError.internalError.errorDescription)
                return
            }
            
            let writeManagedObjectContext = self.persistanceService.backgroundContext
            
            writeManagedObjectContext.perform {
                let oldRoadSigns = self.fetchRoadSigns(objectContext: writeManagedObjectContext)
                print("Number of old radars: \(oldRoadSigns.count) \n \(oldRoadSigns)")
                switch result {
                case .success(let data):
                    do {
                        guard let roadSigns = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] else {
                            completion?(oldRoadSigns, CustomError.canNotProcessData.errorDescription)
                            return
                        }
                        
                        var newRoadSignsIDs: [NSNumber] = []
                        for currentSign in roadSigns {
                            guard let signID = currentSign[RoadSignJSON.id.rawValue] as? NSNumber else { continue }
                            newRoadSignsIDs.append(signID)
                            let newSign = RoadSign.findOrCreate(signID, context: writeManagedObjectContext)
                            newSign.fillSignInfo(currentSign)
                        }
                        
                        for oldSign in oldRoadSigns {
                            if let oldSignID = oldSign.id,
                               !newRoadSignsIDs.contains(oldSignID) {
                                writeManagedObjectContext.delete(oldSign)
                            }
                        }
                        
                        let status = writeManagedObjectContext.saveOrRollback()
                        if status {
                            completion?(nil, nil)
                        } else {
                            completion?(oldRoadSigns, CustomError.dataBaseError.errorDescription)
                        }
                    } catch {
                        completion?(oldRoadSigns, String(format: THANK_YOU_FOR_UNDERSTANDING, error.localizedDescription))
                    }
                case .failure(let error):
                    completion?(oldRoadSigns, String(format: THANK_YOU_FOR_UNDERSTANDING, error.localizedDescription))
                }
            }
        }
    }
}

//
//  MainManager.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import CoreData
import FirebaseFirestore
import UIKit

struct RadarParameters {
    var policeDepartmentID: Int?
    var policeDepartmentName: String?
    var coordinates: String
    var road: String?
    var text: String?
    var title: String
    var type: Int
    var validFrom: String?
    var validTo: String?
    var updatedAt: String?
}

class MainManager {
    
    static let shared = MainManager()
    private let networkService = NetworkService.shared
    private let persistanceService = PersistanceService.shared
    private let firestoreDataBase = Firestore.firestore()
    
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
    
    func getRadars(_ completion: ((_ success: [Radar]?, _ errorAdviser: Adviser?) -> Void)?) {
        let errorAdviser: Adviser = Adviser(title: ERROR_DESCRIPTION, message: String())
        let connectionStatus = Reachability.isConnectedToNetwork()
        firestoreDataBase.collection("Radars").getDocuments() { (querySnapshot, err) in
            if let err = err {
                errorAdviser.message = err.localizedDescription
                completion?([], errorAdviser)
                return
            } else {
                let writeManagedObjectContext = self.persistanceService.backgroundContext
                writeManagedObjectContext.perform {
                    let oldRadars = self.fetchRadars(objectContext: writeManagedObjectContext)
                    print("Number of old radars: \(oldRadars.count) \n \(oldRadars)")
                    
                    switch connectionStatus {
                    case true:
                        guard let radars = querySnapshot?.documents else {
                            errorAdviser.message = CustomError.canNotProcessData.errorDescription
                            completion?(oldRadars, errorAdviser)
                            return
                        }
                        
                        var newRadarsIDs: [String] = []
                        for currentRadar in radars {
                            guard let radarID = currentRadar[RadarJSON.id.rawValue] as? String else { continue }
                            newRadarsIDs.append(radarID)
                            let newRadar = Radar.findOrCreate(radarID, context: writeManagedObjectContext)
                            newRadar.fillRadarInfo(currentRadar.data())
                            if newRadar.isCoordinateZero { writeManagedObjectContext.delete(newRadar) }
                        }
                        
                        for oldRadar in oldRadars {
                            if let oldRadarID = oldRadar.id,
                               !newRadarsIDs.contains(oldRadarID) {
                                writeManagedObjectContext.delete(oldRadar)
                            }
                        }
                        
                        let status = writeManagedObjectContext.saveOrRollback()
                        if status {
                            if radars.isEmpty {
                                errorAdviser.title = RADARS_INFO
                                errorAdviser.message = NO_RADARS_FOUND
                                completion?(oldRadars, errorAdviser)
                            }
                            completion?(nil, nil)
                        } else {
                            errorAdviser.message = CustomError.dataBaseError.errorDescription
                            completion?(oldRadars, errorAdviser)
                        }
                    case false:
                        errorAdviser.title = RADARS_INFO
                        errorAdviser.message = YOU_ARE_CURRENTLY_OFFLINE
                        completion?(oldRadars, errorAdviser)
                    }
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
    
    func addNewRadar(radarParameters: RadarParameters, _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        let ref = firestoreDataBase.collection("Radars")
        let docId = "RadarID-\(ref.document().documentID)"
        
        firestoreDataBase.collection("Radars").document(docId).setData([
            "id": docId,
            "title": radarParameters.title ,
            "coordinates": radarParameters.coordinates,
            "type": radarParameters.type,
            "road": radarParameters.road ?? NSNull(),
            "valid_from": radarParameters.validFrom ?? NSNull(),
            "valid_to": radarParameters.validTo ?? NSNull(),
            "text": radarParameters.text ?? NSNull(),
            "category_id": radarParameters.policeDepartmentID ?? NSNull(),
            "category_name": radarParameters.policeDepartmentName ?? NSNull(),
            "updated_at": radarParameters.updatedAt ?? NSNull()
        ], merge: true) { err in
            if let err = err {
                completion?(false, err.localizedDescription)
            } else {
                completion?(true, RADAR_SUCCESSFULLY_REPORTED)
            }
        }
    }
}

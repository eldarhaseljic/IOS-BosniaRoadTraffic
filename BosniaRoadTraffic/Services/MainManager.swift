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

enum CustomError: LocalizedError {
    case canNotProcessData
    case dataBaseError
    case internalError
    case requestError
    
    var errorDescription: String {
        switch self {
        case .dataBaseError:
            return DATABASE_ERROR
        case .canNotProcessData:
            return CAN_NOT_PROCESS_DATA
        case .internalError:
            return INTERNAL_ERROR
        case .requestError:
            return REQUEST_ERROR
        }
    }
}

enum FirestoreStatus {
    case updated
    case deleted
    case error
}

enum AuthorizationStatus: String {
    case authorizedWhenInUse
    case denied
    case notDetermined
    case restricted
    case authorizedAlways
    case error
    
    var translation: String {
        switch self {
        case .authorizedWhenInUse:
            return AUTHORIZED_WHEN_IN_USE
        case .denied:
            return DENIED
        case .notDetermined:
            return NOT_DETERMINED
        case .restricted:
            return RESTRICTED
        case .authorizedAlways:
            return AUTHORIZED_ALWAYS
        case .error:
            return UNKNOWN
        }
    }
}

protocol ViewProtocol: AnyObject {
    func backButtonTaped()
    func reloadView()
}

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


struct RoadConditionParameters {
    var icon: String
    var coordinates: String
    var road: String?
    var text: String?
    var title: String
    var validFrom: String?
    var validTo: String?
    var roadTypeID: Int
    var roadTypeName: String
    var updatedAt: String?
}

class MainManager {
    
    static let shared = MainManager()
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
    
    private func fetchRoadConditions(objectContext: NSManagedObjectContext) -> [RoadCondition] {
        let fetchRequest = NSFetchRequest<RoadCondition>(entityName: RoadCondition.entityName)
        
        var roadConditions = [RoadCondition]()
        do {
            roadConditions = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return roadConditions
    }
    
    private func fetchRoadFullReport(objectContext: NSManagedObjectContext) -> [RoadConditionDetails] {
        let fetchRequest = NSFetchRequest<RoadConditionDetails>(entityName: RoadConditionDetails.entityName)
        
        var roadConditionDetailss = [RoadConditionDetails]()
        do {
            roadConditionDetailss = try objectContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Error: \(error.localizedDescription)")
        }
        return roadConditionDetailss
    }
    
    func getRadars(_ completion: ((_ success: [Radar]?, _ errorAdviser: Adviser?) -> Void)?) {
        DispatchQueue.background { [weak self] in
            let errorAdviser: Adviser = Adviser(title: ERROR_DESCRIPTION, message: String())
            guard let self = self else {
                DispatchQueue.main.async {
                    errorAdviser.message = CustomError.canNotProcessData.errorDescription
                    completion?([], errorAdviser)
                }
                return
            }
            let connectionStatus = Reachability.isConnectedToNetwork()
            let writeManagedObjectContext = self.persistanceService.backgroundContext
            let oldRadars = self.fetchRadars(objectContext: writeManagedObjectContext)
            print("Number of old radars: \(oldRadars.count) \n")
            switch connectionStatus {
            case true:
                self.firestoreDataBase.collection("Radars").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        DispatchQueue.main.async {
                            errorAdviser.message = err.localizedDescription
                            completion?([], errorAdviser)
                        }
                    } else {
                        
                        writeManagedObjectContext.perform {
                            
                            guard let radars = querySnapshot?.documents else {
                                DispatchQueue.main.async {
                                    errorAdviser.message = CustomError.canNotProcessData.errorDescription
                                    completion?(oldRadars, errorAdviser)
                                }
                                return
                            }
                            
                            var newRadarsIDs: [String] = []
                            for currentRadar in radars {
                                guard let radarID = currentRadar[RadarJSON.id.rawValue] as? String else { continue }
                                newRadarsIDs.append(radarID)
                                let newRadar = Radar.findOrCreate(radarID, context: writeManagedObjectContext)
                                newRadar.fillRadarInfo(currentRadar.data())
                                if newRadar.shouldDeleteRadar {
                                    writeManagedObjectContext.delete(newRadar)
                                }
                            }
                            
                            for oldRadar in oldRadars {
                                if let oldRadarID = oldRadar.id,
                                   !newRadarsIDs.contains(oldRadarID) {
                                    writeManagedObjectContext.delete(oldRadar)
                                    self.deleteElement(elementId: oldRadarID, type: .radar)
                                }
                            }
                            
                            let status = writeManagedObjectContext.saveOrRollback()
                            if status {
                                DispatchQueue.main.async {
                                    if radars.isEmpty {
                                        errorAdviser.title = RADARS_INFO
                                        errorAdviser.message = NO_RADARS_FOUND
                                        completion?(oldRadars, errorAdviser)
                                    }
                                    completion?(nil, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    errorAdviser.message = CustomError.dataBaseError.errorDescription
                                    completion?(oldRadars, errorAdviser)
                                }
                            }
                        }
                    }
                }
            case false:
                DispatchQueue.main.async {
                    errorAdviser.title = RADARS_INFO
                    errorAdviser.message = YOU_ARE_CURRENTLY_OFFLINE
                    completion?(oldRadars, errorAdviser)
                }
            }
        }
    }
    
    func getRoadConditions(_ completion: ((_ success: [RoadCondition]?, _ errorAdviser: Adviser?) -> Void)?) {
        DispatchQueue.background { [weak self] in
            let errorAdviser: Adviser = Adviser(title: ERROR_DESCRIPTION, message: String())
            guard let self = self else {
                DispatchQueue.main.async {
                    errorAdviser.message = CustomError.canNotProcessData.errorDescription
                    completion?([], errorAdviser)
                }
                return
            }
            
            let connectionStatus = Reachability.isConnectedToNetwork()
            let writeManagedObjectContext = self.persistanceService.backgroundContext
            let oldRoadConditions = self.fetchRoadConditions(objectContext: writeManagedObjectContext)
            print("Number of old road conditions: \(oldRoadConditions.count) \n")
            switch connectionStatus {
            case true:
                self.firestoreDataBase.collection("RoadConditions").getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        DispatchQueue.main.async {
                            errorAdviser.message = err.localizedDescription
                            completion?([], errorAdviser)
                        }
                    } else {
                        
                        writeManagedObjectContext.perform {
                            
                            guard let roadConditions = querySnapshot?.documents else {
                                DispatchQueue.main.async {
                                    errorAdviser.message = CustomError.canNotProcessData.errorDescription
                                    completion?(oldRoadConditions, errorAdviser)
                                }
                                return
                            }
                            
                            var newRoadConditionsIDs: [String] = []
                            for currentCondition in roadConditions {
                                guard let conditionID = currentCondition[RoadConditionJSON.id.rawValue] as? String else { continue }
                                newRoadConditionsIDs.append(conditionID)
                                let newCondition = RoadCondition.findOrCreate(conditionID, context: writeManagedObjectContext)
                                newCondition.fillConditionInfo(currentCondition.data())
                                if newCondition.shouldDeleteRoadCondition {
                                    writeManagedObjectContext.delete(newCondition)
                                }
                            }
                            
                            for oldCondition in oldRoadConditions {
                                if let oldConditionID = oldCondition.id,
                                   !newRoadConditionsIDs.contains(oldConditionID) {
                                    writeManagedObjectContext.delete(oldCondition)
                                    self.deleteElement(elementId: oldConditionID, type: .roadCondition)
                                }
                            }
                            
                            let status = writeManagedObjectContext.saveOrRollback()
                            if status {
                                DispatchQueue.main.async {
                                    if roadConditions.isEmpty {
                                        errorAdviser.title = ROAD_CONDITIONS_INFO
                                        errorAdviser.message = NO_ROAD_CONDITIONS_FOUND
                                        completion?(oldRoadConditions, errorAdviser)
                                    }
                                    completion?(nil, nil)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    errorAdviser.message = CustomError.dataBaseError.errorDescription
                                    completion?(oldRoadConditions, errorAdviser)
                                }
                            }
                        }
                    }
                }
            case false:
                DispatchQueue.main.async {
                    errorAdviser.title = ROAD_CONDITIONS_INFO
                    errorAdviser.message = YOU_ARE_CURRENTLY_OFFLINE
                    completion?(oldRoadConditions, errorAdviser)
                }
            }
        }
    }
    
    func getRoadConditionFullReport(_ completion: (() -> Void)?) {
        DispatchQueue.background { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion?()
                }
                return
            }
            let writeManagedObjectContext = self.persistanceService.backgroundContext
            let connectionStatus = Reachability.isConnectedToNetwork()
            let oldRoadConditions = self.fetchRoadFullReport(objectContext: writeManagedObjectContext)
            switch connectionStatus {
            case true:
                self.firestoreDataBase.collection("RoadConditionReport").getDocuments() { (querySnapshot, _) in
                    guard let roadConditionFullReports = querySnapshot?.documents else {
                        DispatchQueue.main.async { completion?() }
                        return
                    }
                    
                    writeManagedObjectContext.perform {
                        if roadConditionFullReports.isEmpty {
                            oldRoadConditions.forEach { writeManagedObjectContext.delete($0) }
                        } else {
                            for roadConditionFullReport in roadConditionFullReports {
                                guard let roadConditionFullReportID = roadConditionFullReport[RoadConditionDetailsJSON.id.rawValue] as? String else { continue }
                                let newReport = RoadConditionDetails.findOrCreate(roadConditionFullReportID,
                                                                                  context: writeManagedObjectContext)
                                newReport.fillInfo(roadConditionFullReport.data())
                            }
                        }
                        
                        let _ = writeManagedObjectContext.saveOrRollback()
                        DispatchQueue.main.async { completion?() }
                    }
                }
            case false:
                DispatchQueue.main.async { completion?() }
                return
            }
        }
    }
    
    func addNewRadar(radarParameters: RadarParameters,
                     _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        DispatchQueue.background { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion?(false, CustomError.canNotProcessData.errorDescription)
                }
                return
            }
            
            let ref = self.firestoreDataBase.collection("Radars")
            let docId = "RadarID-\(ref.document().documentID)"
            
            self.firestoreDataBase.collection("Radars").document(docId).setData([
                "id": docId,
                "title": radarParameters.title ,
                "coordinates": radarParameters.coordinates,
                "type": radarParameters.type,
                "road": radarParameters.road ?? NSNull(),
                "valid_from": radarParameters.validFrom ?? NSNull(),
                "valid_to": radarParameters.validTo ?? NSNull(),
                "text": radarParameters.text ?? NSNull(),
                "numberOfDeletions": 0,
                "category_id": radarParameters.policeDepartmentID ?? NSNull(),
                "category_name": radarParameters.policeDepartmentName ?? NSNull(),
                "updated_at": radarParameters.updatedAt ?? NSNull()
            ], merge: true) { err in
                if let err = err {
                    DispatchQueue.main.async { completion?(false, err.localizedDescription) }
                } else {
                    DispatchQueue.main.async { completion?(true, RADAR_SUCCESSFULLY_REPORTED) }
                }
            }
        }
    }
    
    func addNewRoadCondition(roadConditions: RoadConditionParameters,
                             _ completion: ((_ success: Bool, _ error: String) -> Void)?) {
        DispatchQueue.background { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion?(false, CustomError.canNotProcessData.errorDescription)
                }
                return
            }
            let ref = self.firestoreDataBase.collection("RoadConditions")
            let docId = "RoadConditionID-\(ref.document().documentID)"
            
            self.firestoreDataBase.collection("RoadConditions").document(docId).setData([
                "id": docId,
                "title": roadConditions.title ,
                "coordinates": roadConditions.coordinates,
                "icon": roadConditions.icon,
                "road": roadConditions.road ?? NSNull(),
                "valid_from": roadConditions.validFrom ?? NSNull(),
                "valid_to": roadConditions.validTo ?? NSNull(),
                "text": roadConditions.text ?? NSNull(),
                "category_id": roadConditions.roadTypeID,
                "numberOfDeletions": 0,
                "category_name": roadConditions.roadTypeName,
                "updated_at": roadConditions.updatedAt ?? NSNull()
            ], merge: true) { err in
                if let err = err {
                    DispatchQueue.main.async { completion?(false, err.localizedDescription) }
                } else {
                    DispatchQueue.main.async {  completion?(true, ROAD_CONDITION_SUCCESSFULLY_REPORTED) }
                }
            }
        }
    }
    
    func deleteElement(elementId: String?,
                       type: DetailsType,
                       _ completion: ((_ success: FirestoreStatus, _ error: String) -> Void)? = nil) {
        DispatchQueue.background { [weak self] in
            guard
                let self = self,
                let elementId = elementId
            else {
                DispatchQueue.main.async {
                    completion?(.error, WRONG_ID)
                }
                return
            }
            switch type {
            case .roadCondition:
                self.firestoreDataBase.collection("RoadConditions").document(elementId).delete() { err in
                    if let err = err {
                        DispatchQueue.main.async { completion?(.error, err.localizedDescription) }
                    } else {
                        DispatchQueue.main.async { completion?(.deleted, THANKS)}
                    }
                }
            case .radar:
                self.firestoreDataBase.collection("Radars").document(elementId).delete() { err in
                    if let err = err {
                        DispatchQueue.main.async { completion?(.error, err.localizedDescription) }
                    } else {
                        DispatchQueue.main.async { completion?(.deleted, THANKS) }
                    }
                }
            case .roadDetails:
                break
            }
        }
    }
    
    func updateOrDelete(detailsViewModel: DetailsViewModel,
                        _ completion: ((_ success: FirestoreStatus, _ error: String) -> Void)?) {
        DispatchQueue.background { [weak self] in
            guard
                let self = self,
                let id = detailsViewModel.dataId
            else {
                DispatchQueue.main.async {
                    completion?(.error, WRONG_ID)
                }
                return
            }
            detailsViewModel.numberOfDeletions += 1
            
            if detailsViewModel.numberOfDeletions >= 5 {
                self.deleteElement(elementId: id, type: detailsViewModel.detailsType, completion)
            } else {
                self.updateVisibility(id: id, detailsViewModel: detailsViewModel, completion)
            }
        }
    }
    
    func updateVisibility(id: String,
                          detailsViewModel: DetailsViewModel,
                          _ completion: ((_ success: FirestoreStatus, _ error: String) -> Void)?) {
        DispatchQueue.background { [weak self] in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion?(.error, CustomError.canNotProcessData.errorDescription)
                }
                return
            }
            switch detailsViewModel.detailsType {
            case .roadCondition:
                self.firestoreDataBase.collection("RoadConditions").document(id).setData([
                    "numberOfDeletions": detailsViewModel.numberOfDeletions,
                ], merge: true) { err in
                    if let err = err {
                        DispatchQueue.main.async { completion?(.error, err.localizedDescription) }
                    } else {
                        DispatchQueue.main.async { completion?(.deleted, THANKS) }
                    }
                }
            case .radar:
                self.firestoreDataBase.collection("Radars").document(id).setData([
                    "numberOfDeletions": detailsViewModel.numberOfDeletions,
                ], merge: true) { err in
                    if let err = err {
                        DispatchQueue.main.async { completion?(.error, err.localizedDescription) }
                    } else {
                        DispatchQueue.main.async { completion?(.deleted, THANKS) }
                    }
                }
            case .roadDetails:
                break
            }
        }
    }
}

//
//  RoadConditionsViewModel.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa
import CoreData
import Foundation
import CoreLocation

final class RoadConditionsViewModel: NSObject {
    
    private var roadSignFRC: NSFetchedResultsController<RoadSign>!
    private let locationDistance: CLLocationDistance = 50000
    private let persistanceService: PersistanceService!
    private let locationManager: CLLocationManager!
    private var mainRoadConditionsDetails: RoadSign? = nil
    private let manager: MainManager!
    
    let roadSignsArray = PublishSubject<[RoadSign]>()
    let messageTransmitter = PublishSubject<Adviser>()
    let userLocationStatus = PublishSubject<AuthorizationStatus>()
    var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var roadSignsInDatabase: [RoadSign] = []
    
    init(manager: MainManager = MainManager.shared,
         persistanceService: PersistanceService = PersistanceService.shared,
         locationManager: CLLocationManager = CLLocationManager()) {
        
        self.manager = manager
        self.persistanceService = persistanceService
        self.locationManager = locationManager
        
        super.init()
        setupFetchController()
    }
    
    private func setupFetchController() {
        roadSignFRC = NSFetchedResultsController(fetchRequest: RoadSign.sortedFetchRequest,
                                                 managedObjectContext: persistanceService.mainContext,
                                                 sectionNameKeyPath: nil, cacheName: nil)
        roadSignFRC.delegate = self
        do {
            try roadSignFRC.performFetch()
        } catch {
            fatalError("Radars fetch request failed")
        }
    }
    
    func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            setupLocationManager()
            checkLocationAuthorization()
        } else {
            messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: LOCATION_SERVICE_DISABLED ))
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
            userLocationStatus.onNext(.authorizedWhenInUse)
            currentAuthorizationStatus = .authorizedWhenInUse
        case .denied:
            userLocationStatus.onNext(.denied)
            currentAuthorizationStatus = .denied
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            currentAuthorizationStatus = .notDetermined
        case .restricted:
            userLocationStatus.onNext(.restricted)
            currentAuthorizationStatus = .restricted
        case .authorizedAlways:
            userLocationStatus.onNext(.authorizedAlways)
            currentAuthorizationStatus = .authorizedAlways
        @unknown
        default:
            userLocationStatus.onNext(.error)
        }
    }
    
    var userCurrentLocation: MKCoordinateRegion? {
        // Zoom to user location
        guard let userLocation = locationManager.location?.coordinate else { return nil }
        return MKCoordinateRegion(center: userLocation,
                                  latitudinalMeters: locationDistance,
                                  longitudinalMeters: locationDistance)
    }
    
    private func handleRoadSignData() {
        var roadData = roadSignFRC.fetchedObjects ?? []
        
        mainRoadConditionsDetails = roadData.first(where: { sign in
            sign.isCoordinateZero || sign.hasNoIcon
        })
        
        roadData.removeAll(where: { sign in
            sign.isCoordinateZero || sign.hasNoIcon
        })
        
        showRoadConditons(roadConditions: roadData)
    }
    
    func getRoadConditionsInfo() -> RoadSign? {
        return mainRoadConditionsDetails
    }
    
    private func showRoadConditons(roadConditions: [RoadSign], errorAdviser: Adviser? = nil) {
        if roadConditions.isEmpty {
            messageTransmitter.onNext(Adviser(title: RADARS_INFO, message: NO_RADARS_FOUND))
        } else {
            roadSignsInDatabase = roadConditions
            roadSignsArray.onNext(roadSignsInDatabase)
            if let errorAdviser = errorAdviser {
                messageTransmitter.onNext(errorAdviser)
            }
        }
    }
    
    func fetchData() {
        fetchRoadConditions() { [weak self] (response,errorMessage) in
            guard
                let self = self,
                let response = response,
                let errorMessage = errorMessage
            else {
                print("Road Conditons updated successfully")
                return
            }
            
            DispatchQueue.main.async {
                self.showRoadConditons(roadConditions: response,
                                       errorAdviser: Adviser(title: ERROR_DESCRIPTION,
                                                             message: errorMessage,
                                                             isError: true))
            }
        }
    }
    
    func fetchRoadConditions(_ completion: ((_ success: [RoadSign]?, _ errorMessage: String?) -> Void)? = nil) {
        manager.getRoadConditions { (response, errorMessage) in
            guard
                let response = response,
                let errorMessage = errorMessage
            else {
                completion?(nil, nil)
                return
            }
            completion?(response,errorMessage)
        }
    }
}

extension RoadConditionsViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleRoadSignData()
    }
}

extension RoadConditionsViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != currentAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
}

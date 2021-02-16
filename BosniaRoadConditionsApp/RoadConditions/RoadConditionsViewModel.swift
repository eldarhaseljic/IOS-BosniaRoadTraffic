//
//  RoadConditionsViewModel.swift
//  BosniaRoadConditionsApp
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
    private let manager: MainManager!
    
    let roadSignsArray = PublishSubject<[RoadSign]>()
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
        roadSignFRC = NSFetchedResultsController(fetchRequest: RoadSign.sortedFetchRequest, managedObjectContext: persistanceService.context, sectionNameKeyPath: nil, cacheName: nil)
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
            // Error message
            // Show alert letting the user know they have to turn this on
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
        // Error message
        roadSignsInDatabase = roadSignFRC.fetchedObjects ?? []
        roadSignsArray.onNext(roadSignsInDatabase)
    }
    
    func fetchRoadConditions(_ completion:((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        manager.getRoadConditions { (_, error) in
            guard
                let error = error
            else {
                print("Road Conditions updated successfully")
                return
            }
            // Error message
            print(error.localizedDescription)
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

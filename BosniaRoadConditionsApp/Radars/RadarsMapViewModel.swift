//
//  RadarsMapViewModel.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/30/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa
import CoreData
import Foundation
import CoreLocation

enum AuthorizationStatus {
    case authorizedWhenInUse
    case denied
    case notDetermined
    case restricted
    case authorizedAlways
    case error
}

final class RadarsMapViewModel: NSObject {
    
    private var radarsFRC: NSFetchedResultsController<Radar>!
    private let persistanceService: PersistanceService!
    private let locationManager: CLLocationManager!
    private let manager: MainManager!
    
    let radarsArray = PublishSubject<[Radar]>()
    let messageTransmitter = PublishSubject<String>()
    let userLocationStatus = PublishSubject<AuthorizationStatus>()
    var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var radarsInDatabase: [Radar] = []
    private let locationDistance: CLLocationDistance = 50000
    
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
        radarsFRC = NSFetchedResultsController(fetchRequest: Radar.sortedFetchRequest, managedObjectContext: persistanceService.context, sectionNameKeyPath: nil, cacheName: nil)
        radarsFRC.delegate = self
        do {
            try radarsFRC.performFetch()
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
    
    private func handleRadarsData() {
        // Error message
        radarsInDatabase = radarsFRC.fetchedObjects ?? []
        if radarsInDatabase.isEmpty {
            messageTransmitter.onNext(NO_RADARS_FOUND)
        } else {
            radarsArray.onNext(radarsInDatabase)
        }
    }
    
    func fetchNewRadars(_ completion:((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        manager.getRadars { (_, error) in
            guard
                let error = error
            else {
                print("Radars updated successfully")
                completion?(true, nil)
                return
            }
            // Error message
            print(error.localizedDescription)
            completion?(false, error)
        }
    }
}

extension RadarsMapViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleRadarsData()
    }
}

extension RadarsMapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != currentAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
}

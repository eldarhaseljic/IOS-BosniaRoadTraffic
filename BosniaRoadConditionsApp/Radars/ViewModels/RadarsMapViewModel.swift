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
    
    let userLocationStatus = PublishSubject<AuthorizationStatus>()
    let radarsArray = PublishSubject<[Radar]>()
    
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
        case .denied:
            userLocationStatus.onNext(.denied)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            userLocationStatus.onNext(.restricted)
        case .authorizedAlways:
            userLocationStatus.onNext(.authorizedAlways)
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
    
    private func handleTeamsData() {
        // Error message
        radarsArray.onNext(radarsFRC.fetchedObjects ?? [])
    }
    
    func fetchNewRadars(_ completion:((_ success: Bool, _ error: NSError?) -> Void)? = nil) {
        manager.getRadars { (_, error) in
            guard
                let error = error
            else {
                print("Radars updated successfully")
                return
            }
            // Error message
            print(error.localizedDescription)
        }
    }
}

extension RadarsMapViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleTeamsData()
    }
    
}

extension RadarsMapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}

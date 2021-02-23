//
//  RadarsMapViewModel.swift
//  BosniaRoadTrafficApp
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

enum AuthorizationStatus: String {
    case authorizedWhenInUse
    case denied
    case notDetermined
    case restricted
    case authorizedAlways
    case error 
}

final class RadarsMapViewModel: NSObject {
    
    private var radarsFRC: NSFetchedResultsController<Radar>!
    private let locationDistance: CLLocationDistance = 50000
    private let persistanceService: PersistanceService!
    private let locationManager: CLLocationManager!
    private let manager: MainManager!
    private var currentMapTypeID = 1
    
    let radarsArray = PublishSubject<[Radar]>()
    let messageTransmitter = PublishSubject<Adviser>()
    let userLocationStatus = PublishSubject<AuthorizationStatus>()
    var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var radarsInDatabase: [Radar] = []
    
    private let mapTypes: [MKMapType] = [.standard, .hybrid, .hybridFlyover]
    
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
        radarsFRC = NSFetchedResultsController(fetchRequest: Radar.sortedFetchRequest,
                                               managedObjectContext: persistanceService.mainContext,
                                               sectionNameKeyPath: nil, cacheName: nil)
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
    
    func handleRadarsData() {
        showRadars(radars: radarsFRC.fetchedObjects ?? [])
    }
    
    private func showRadars(radars: [Radar], errorAdviser: Adviser? = nil) {
        if radars.isEmpty {
            messageTransmitter.onNext(Adviser(title: RADARS_INFO, message: NO_RADARS_FOUND))
        } else {
            radarsInDatabase = radars
            radarsArray.onNext(radarsInDatabase)
            if let errorAdviser = errorAdviser {
                messageTransmitter.onNext(errorAdviser)
            }
        }
    }
    
    func fetchData() {
        fetchNewRadars() { [weak self] (response,errorMessage) in
            guard
                let self = self,
                let response = response,
                let errorMessage = errorMessage
            else {
                print("Radars updated successfully")
                return
            }
            
            DispatchQueue.main.async {
                self.showRadars(radars: response,
                                errorAdviser: Adviser(title: ERROR_DESCRIPTION,
                                                      message: errorMessage,
                                                      isError: true))
            }
        }
    }
    
    private func fetchNewRadars(_ completion: ((_ success: [Radar]?, _ errorMessage: String?) -> Void)? = nil) {
        manager.getRadars { (response, errorMessage) in
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
    
    var currentMapType: MKMapType {
        let mapType = mapTypes[currentMapTypeID]
        if currentMapTypeID + 1 == mapTypes.count {
            currentMapTypeID = .zero
        } else {
            currentMapTypeID += 1
        }
        return mapType
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

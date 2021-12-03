//
//  RadarsMapViewModel.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/30/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import MapKit
import RxSwift
import CoreData
import Foundation
import CoreLocation

final class RadarsMapViewModel: NSObject {
    
    private let mapTypes: [MKMapType] = [.standard, .hybrid]
    private let locationDistance: CLLocationDistance = 20000
    private let persistanceService: PersistanceService!
    private let locationManager: CLLocationManager!
    private let manager: MainManager!
    
    private var radarsFRC: NSFetchedResultsController<Radar>!
    private var currentMapTypeID = 1
    
    let radarsArray = PublishSubject<[Radar]>()
    let messageTransmitter = PublishSubject<Adviser>()
    let userLocationStatus = PublishSubject<AuthorizationStatus>()
    
    var currentAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var radarsInDatabase: [Radar] = []
    
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
            messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION,
                                              message: LOCATION_SERVICE_DISABLED,
                                              isError: true))
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
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
        let radars = radarsFRC.fetchedObjects ?? []
        var errorAdviser: Adviser? = nil
        if radars.count > radarsInDatabase.count {
            errorAdviser = Adviser(title: RADARS_INFO, message: NEW_RADARS_FOUND)
        } else if Reachability.isConnectedToNetwork() == false {
            errorAdviser = Adviser(title: RADARS_INFO, message: YOU_ARE_CURRENTLY_OFFLINE)
        }
        showRadars(radars: radars, errorAdviser: errorAdviser)
    }
    
    private func showRadars(radars: [Radar], errorAdviser: Adviser? = nil) {
        radarsInDatabase = radars
        radarsArray.onNext(radarsInDatabase)
        if let errorAdviser = errorAdviser {
            messageTransmitter.onNext(errorAdviser)
        }
    }
    
    func fetchData() {
        manager.getRadars { [weak self] (response,errorAdviser) in
            guard
                let self = self,
                let response = response,
                let errorAdviser = errorAdviser
            else {
                print("Radars updated successfully")
                return
            }
            
            DispatchQueue.main.async {
                self.showRadars(radars: response, errorAdviser: errorAdviser)
            }
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
    
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        let latitude = mapView.centerCoordinate.latitude
        let longitude = mapView.centerCoordinate.longitude
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}

extension RadarsMapViewModel: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        handleRadarsData()
    }
}

extension RadarsMapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != currentAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
}

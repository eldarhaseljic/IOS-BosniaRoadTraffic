//
//  RoadConditionsViewModel.swift
//  Bosnia Road Traffic 
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
    
    private let mapTypes: [MKMapType] = [.standard, .hybrid]
    private let locationDistance: CLLocationDistance = 50000
    private let persistanceService: PersistanceService!
    private let locationManager: CLLocationManager!
    private let manager: MainManager!
    
    private var roadInfoFRC: NSFetchedResultsController<RoadConditionDetails>!
    private var roadSignFRC: NSFetchedResultsController<RoadSign>!
    private var mainRoadConditionsDetails: RoadConditionDetails? = nil
    private var currentMapTypeID = 1
    
    let roadInfoArray = PublishSubject<RoadConditionDetails?>()
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
        setupFetchControllers()
    }
    
    private func setupFetchControllers() {
        setupFetchRoadInfoController()
        setupFetchRoadSignController()
    }
    
    private func setupFetchRoadSignController() {
        roadSignFRC = NSFetchedResultsController(fetchRequest: RoadSign.sortedFetchRequest,
                                                 managedObjectContext: persistanceService.mainContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
        roadSignFRC.delegate = self
        do {
            try roadSignFRC.performFetch()
        } catch {
            fatalError("Road Conditions fetch request failed")
        }
    }
    
    private func setupFetchRoadInfoController() {
        roadInfoFRC = NSFetchedResultsController(fetchRequest: RoadConditionDetails.sortedFetchRequest,
                                                 managedObjectContext: persistanceService.mainContext,
                                                 sectionNameKeyPath: nil,
                                                 cacheName: nil)
        roadInfoFRC.delegate = self
        do {
            try roadInfoFRC.performFetch()
        } catch {
            fatalError("Road Condition Details fetch request failed")
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
        let roadData = roadSignFRC.fetchedObjects ?? []
        var errorAdviser: Adviser? = nil
        if roadData.count > roadSignsInDatabase.count {
            errorAdviser = Adviser(title: ROAD_CONDITIONS_INFO, message: NEW_ROAD_CONDITIONS_FOUND)
        } else if Reachability.isConnectedToNetwork() == false {
            errorAdviser = Adviser(title: ROAD_CONDITIONS_INFO, message: YOU_ARE_CURRENTLY_OFFLINE)
        }
        showRoadConditons(roadConditions: roadData, errorAdviser: errorAdviser)
    }
    
    private func handleRoadDetailsData() {
        let roadDetails = roadInfoFRC.fetchedObjects ?? []
        mainRoadConditionsDetails = roadDetails.first
    }
    
    func getRoadConditionsDetails() -> RoadConditionDetails? {
        return mainRoadConditionsDetails
    }
    
    private func showRoadConditons(roadConditions: [RoadSign], errorAdviser: Adviser? = nil) {
        roadSignsInDatabase = roadConditions
        roadSignsArray.onNext(roadSignsInDatabase)
        if let errorAdviser = errorAdviser {
            messageTransmitter.onNext(errorAdviser)
        }
    }
    
    func fetchData() {
        manager.getRoadConditionFullReport() { [weak self] in
            self?.manager.getRoadConditions { [weak self] (response,errorAdviser) in
                guard
                    let self = self,
                    let response = response,
                    let errorAdviser = errorAdviser
                else {
                    print("Road Conditons updated successfully")
                    return
                }
                
                DispatchQueue.main.async {
                    self.showRoadConditons(roadConditions: response, errorAdviser: errorAdviser)
                }
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

extension RoadConditionsViewModel: NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        if controller == roadSignFRC {
            handleRoadSignData()
        } else if controller == roadInfoFRC {
            handleRoadDetailsData()
        }
    }
}

extension RoadConditionsViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status != currentAuthorizationStatus {
            checkLocationAuthorization()
        }
    }
}

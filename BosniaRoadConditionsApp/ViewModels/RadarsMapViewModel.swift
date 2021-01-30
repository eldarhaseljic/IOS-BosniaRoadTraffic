//
//  RadarsMapViewModel.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/30/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import RxSwift
import RxCocoa
import CoreData
import Foundation
import CoreLocation

class RadarsMapViewModel: NSObject {
    
    private var manager: MainManager!
    private var locationManager: CLLocationManager!
    
    let userLocationStatus = PublishSubject<Bool>()
    
    var radars: [Radar] = []
    
    init(manager: MainManager = MainManager.shared,
         locationManager: CLLocationManager = CLLocationManager()) {
        
        self.manager = manager
        self.locationManager = locationManager
        
        super.init()
        radars = manager.fetchRadars()
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
            userLocationStatus.onNext(true)
        case .denied:
            // Error message
            break
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            // Error message
            break
        case .authorizedAlways:
            // Error message
            break
        default:
            // Error message
            break
        }
    }
}

extension RadarsMapViewModel: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}

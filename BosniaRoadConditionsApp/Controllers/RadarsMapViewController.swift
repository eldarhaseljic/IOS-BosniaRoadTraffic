//
//  RadarsMapViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class RadarsMapViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.register(RadarMarkerView.self,
                             forAnnotationViewWithReuseIdentifier:
                                MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }
    private let disposeBag = DisposeBag()
    var viewModel: RadarsMapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupObservers()
        viewModel.checkLocationServices()
        viewModel.fetchNewRadars()
    }
    
    func setupObservers() {
        viewModel.userLocationStatus.bind(onNext: { [unowned self] isVisible in
            mapView.showsUserLocation = isVisible
            if let currentLocation = viewModel.userCurrentLocation {
                mapView.setRegion(currentLocation, animated: true)
            }
        }).disposed(by: disposeBag)
        
        viewModel.radarsArray.bind(onNext: { [unowned self] radars in
            mapView.addAnnotations(radars)
            funkcijaZaProvjeru(radars)
        }).disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setViewModel() {
        viewModel = RadarsMapViewModel()
    }
    
    // Error message
    private func funkcijaZaProvjeru(_ radars: [Radar]) {
        var stacionarni = 0
        var nestacionarni = 0
        radars.forEach({ radar in
            if radar.type == 1 {
                stacionarni += 1
            } else {
                nestacionarni += 1
            }
        })
        
        print("Stacionarni \(stacionarni) ne \(nestacionarni)")
    }
}

extension RadarsMapViewController {
    static func getViewController() -> RadarsMapViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarsMapStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarsMapViewController.self)!

    }
    
    static func showRadars() -> RadarsMapViewController {
        let radarsViewController = RadarsMapViewController.getViewController()
        radarsViewController.setViewModel()
        return radarsViewController
    }
}

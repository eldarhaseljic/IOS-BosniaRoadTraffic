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
    
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView! {
        didSet {
            loadingIndicatorView.appendBlurredBackground()
            loadingIndicatorView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }
    }
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
    }
    
    func setupObservers() {
        viewModel.userLocationStatus.bind(onNext: { [unowned self] isVisible in
            switch isVisible {
            case .authorizedWhenInUse, .authorizedAlways:
                loadingIndicatorView.startAnimating()
                mapView.showsUserLocation = true
                viewModel.fetchNewRadars()
            case .denied: break
            // Error message
            case .notDetermined: break
            // Error message
            case .restricted: break
            // Error message
            case .error: break
            // Error message
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.radarsArray.bind(onNext: { [unowned self] radars in
            mapView.addAnnotations(radars)
            if let currentLocation = viewModel.userCurrentLocation {
                mapView.setRegion(currentLocation, animated: true)
            }
            loadingIndicatorView.stopAnimating()
            funkcijaZaProvjeru(radars)
        })
        .disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = getFilterButton(target: self,
                                                            action: #selector(tapEditButton))
    }
    
    private func setViewModel() {
        viewModel = RadarsMapViewModel()
    }
    
    @objc
    public func tapEditButton(_ sender: Any) {
        presentView(viewController: RadarFilterViewController.showFilters())
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

extension RadarsMapViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let radar = view.annotation as? Radar else { return }
        presentView(viewController: RadarDetailsViewController.showDetails(for: radar))
    }
}

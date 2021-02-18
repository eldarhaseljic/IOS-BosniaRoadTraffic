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
    
    lazy var radarFilterViewController: RadarFilterViewController = {
        return RadarFilterViewController.getViewController()
    }()
    
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
            case .denied:
                presentAlert(title: ERROR_DESCRIPTION,
                             message: String(format: LOCATION_SERVICE, AuthorizationStatus.denied.rawValue),
                             buttonTitle: OK,
                             handler: { _ in tapBackButton(self) })
            case .restricted:
                presentAlert(title: ERROR_DESCRIPTION,
                             message: String(format: LOCATION_SERVICE, AuthorizationStatus.restricted.rawValue),
                             buttonTitle: OK,
                             handler: { _ in tapBackButton(self) })
            case .error:
                presentAlert(title: ERROR_DESCRIPTION,
                             message: String(format: LOCATION_SERVICE, UNKNOWN),
                             buttonTitle: OK,
                             handler: { _ in tapBackButton(self) })
            case .notDetermined: break
            }
        })
        .disposed(by: disposeBag)
        
        viewModel.radarsArray.bind(onNext: { [unowned self] radars in
            mapView.addAnnotations(radars)
            if let currentLocation = viewModel.userCurrentLocation {
                mapView.setRegion(currentLocation, animated: true)
            }
            radarFilterViewController.setData(viewModel: RadarFilterViewModel(radars: radars))
            navigationItem.rightBarButtonItem?.isEnabled = true
            loadingIndicatorView.stopAnimating()
        })
        .disposed(by: disposeBag)
        
        viewModel.messageTransmitter.bind(onNext: { [unowned self] adviser in
            presentAlert(title: adviser.title,
                         message: adviser.message,
                         buttonTitle: OK,
                         handler: { _ in tapBackButton(self) })
        })
        .disposed(by: disposeBag)
        
        radarFilterViewController.filteredRadarsArray.bind(onNext: { [unowned self] radars in
            loadingIndicatorView.startAnimating()
            mapView.removeAnnotations(viewModel.radarsInDatabase)
            mapView.addAnnotations(radars)
            loadingIndicatorView.stopAnimating()
        })
        .disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = filterButton(target: self,
                                                         action: #selector(tapEditButton))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setViewModel() {
        viewModel = RadarsMapViewModel()
    }
    
    @objc
    public func tapEditButton(_ sender: Any) {
        presentView(viewController: radarFilterViewController)
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

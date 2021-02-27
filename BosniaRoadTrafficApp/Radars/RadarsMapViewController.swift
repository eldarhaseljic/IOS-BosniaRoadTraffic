//
//  RadarsMapViewController.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 1/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class RadarsMapViewController: UIViewController {
    
    @IBOutlet var reloadMapButton: UIButton!
    @IBOutlet var mapTypeButton: UIButton!
    @IBOutlet var containerView: UIView! {
        didSet {
            containerView.setRoundedBorder(borderWidth: Constants.BorderWidth.OnePoint,
                                           cornerRadius: Constants.CornerRadius.EightPoints,
                                           borderColor: CustomColor.slateGray.cgColor)
        }
    }
    
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
    
    lazy var radarFilterViewController: RadarFilterViewController = {
        return RadarFilterViewController.getViewController()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupObservers()
        loadingIndicatorView.startAnimating()
        viewModel.checkLocationServices()
    }
    
    func setupObservers() {
        viewModel.userLocationStatus.bind(onNext: { [unowned self] isVisible in
            switch isVisible {
            case .authorizedWhenInUse, .authorizedAlways:
                mapView.showsUserLocation = true
                viewModel.fetchData()
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
            print("Number of new radars: \(radars.count) \n \(radars)")
            self.prepareMapAndFilter(with: radars)
        })
        .disposed(by: disposeBag)
        
        viewModel.messageTransmitter.bind(onNext: { [unowned self] adviser in
            presentAlert(title: adviser.title,
                         message: adviser.message,
                         buttonTitle: OK,
                         handler: adviser.isError ? nil : { _ in tapBackButton(self) })
        })
        .disposed(by: disposeBag)
        
        radarFilterViewController.filteredRadarsArray.bind(onNext: { [unowned self] radars in
            loadingIndicatorView.startAnimating()
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(radars)
            loadingIndicatorView.stopAnimating()
        })
        .disposed(by: disposeBag)
        
        reloadMapButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.loadingIndicatorView.startAnimating()
            self.reloadMapButton.isEnabled = false
            self.navigationItem.rightBarButtonItem?.isEnabled = false
            self.viewModel.fetchData()
        }
        .disposed(by: disposeBag)
        
        mapTypeButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.mapView.mapType = self.viewModel.currentMapType
        }
        .disposed(by: disposeBag)
    }
    
    
    private func prepareMapAndFilter(with radars: [Radar]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(radars)
        
        if let currentLocation = viewModel.userCurrentLocation {
            mapView.setRegion(currentLocation, animated: true)
        }
        
        let filterViewModel = RadarFilterViewModel(radars: radars)
        if filterViewModel.numberOfFilters != 1 {
            radarFilterViewController.setData(viewModel: filterViewModel)
            navigationItem.rightBarButtonItem?.isEnabled = true
        }
        
        loadingIndicatorView.stopAnimating()
        delay(Constants.Time.TenSeconds) { [weak self] in
            guard let self = self else { return }
            self.reloadMapButton.isEnabled = true
        }
    }
    
    private func setupNavigationBar() {
        title = RADAR_LOCATIONS.localizedUppercase
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

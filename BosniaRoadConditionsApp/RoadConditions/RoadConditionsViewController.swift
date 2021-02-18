//
//  RoadConditionsViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class RoadConditionsViewController: UIViewController {
    
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView! {
        didSet {
            loadingIndicatorView.appendBlurredBackground()
            loadingIndicatorView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }
    }
    
    @IBOutlet var mapView: MKMapView! {
        didSet {
            mapView.register(RoadSignMarkerView.self,
                             forAnnotationViewWithReuseIdentifier:
                                MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }
    
    private let disposeBag = DisposeBag()
    var viewModel: RoadConditionsViewModel!
    
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
                viewModel.fetchRoadConditions()
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
        
        viewModel.roadSignsArray.bind(onNext: { [unowned self] roadSigns in
            mapView.addAnnotations(roadSigns)
            if let currentLocation = viewModel.userCurrentLocation {
                mapView.setRegion(currentLocation, animated: true)
            }
            loadingIndicatorView.stopAnimating()
        })
        .disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setViewModel() {
        viewModel = RoadConditionsViewModel()
    }
}

extension RoadConditionsViewController {
    static func getViewController() -> RoadConditionsViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RoadConditionsStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RoadConditionsViewController.self)!
    }
    
    static func showRoadConditions() -> RoadConditionsViewController {
        let roadConditionsViewController = RoadConditionsViewController.getViewController()
        roadConditionsViewController.setViewModel()
        return roadConditionsViewController
    }
}

extension RoadConditionsViewController: MKMapViewDelegate {
    
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            guard let roadSign = view.annotation as? RoadSign else { return }
            presentView(viewController: RoadConditionsDetailsViewController.showDetails(for: roadSign))
        }
}

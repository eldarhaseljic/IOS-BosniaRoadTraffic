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
    
    @IBOutlet var mapView: MKMapView!
   
    private let disposeBag = DisposeBag()
    var viewModel: RadarsMapViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupObservers()
        viewModel.checkLocationServices()
        print(viewModel.radars.count)
    }
    
    func setupObservers() {
        viewModel.userLocationStatus.bind(onNext: { [unowned self] isVisible in
            self.mapView.showsUserLocation = isVisible
        }).disposed(by: disposeBag)
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setViewModel() {
        viewModel = RadarsMapViewModel()
    }
}

extension RadarsMapViewController {
    static func getViewController() -> RadarsMapViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarsMapStoryboard,
                            bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarsMapViewController.self)!
    }
    
    static func showRadars() -> RadarsMapViewController {
        let radarsViewController = RadarsMapViewController.getViewController()
        radarsViewController.setViewModel()
        return radarsViewController
    }
}

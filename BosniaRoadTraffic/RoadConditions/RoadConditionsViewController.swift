//
//  RoadConditionsViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/14/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import MapKit
import RxSwift

class RoadConditionsViewController: UIViewController {
    
    @IBOutlet var reloadMapButton: UIButton!
    @IBOutlet var mapTypeButton: UIButton!
    @IBOutlet var roadConditionPin: UIImageView!
    @IBOutlet var reportContainer: UIStackView!
    @IBOutlet var reportButton: UIButton!
    
    @IBOutlet var confirmReportButton: UIButton! {
        didSet {
            confirmReportButton.setTitle(REPORT,
                                         for: .normal)
            confirmReportButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                                 borderColor: AppColor.black.cgColor)
            confirmReportButton.setShadow(shadowColor: AppColor.davysGrey.cgColor,
                                          shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
    @IBOutlet var cancelReportButton: UIButton! {
        didSet {
            cancelReportButton.setTitle(CANCEL,for: .normal)
            cancelReportButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                                borderColor: AppColor.black.cgColor)
            cancelReportButton.setShadow(shadowColor: AppColor.davysGrey.cgColor,
                                         shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
    @IBOutlet var containerView: UIView! {
        didSet {
            containerView.setRoundedBorder(borderWidth: Constants.BorderWidth.OnePoint,
                                           cornerRadius: Constants.CornerRadius.EightPoints,
                                           borderColor: AppColor.slateGray.cgColor)
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
            mapView.register(RoadConditionMarkerView.self,
                             forAnnotationViewWithReuseIdentifier:
                                MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.userTrackingMode = .followWithHeading
        }
    }
    
    lazy var filterViewController: FilterViewController = {
        return FilterViewController.getViewController()
    }()
    
    private let disposeBag = DisposeBag()
    private var viewModel: RoadConditionsViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupObservers()
        loadingIndicatorView.startAnimating()
        viewModel.checkLocationServices()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(willEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    @objc
    func willEnterForeground() {
        reloadView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupObservers() {
        viewModel.userLocationStatus.bind(onNext: { [unowned self] isVisible in
            switch isVisible {
            case .authorizedWhenInUse,
                 .authorizedAlways:
                mapView.showsUserLocation = true
                viewModel.fetchData()
            case .denied:
                presentAlert(title: ERROR_DESCRIPTION,
                             message: String(format: LOCATION_SERVICE, AuthorizationStatus.denied.translation),
                             buttonTitle: OK,
                             handler: { _ in tapBackButton(self) })
            case .restricted:
                presentAlert(title: ERROR_DESCRIPTION,
                             message: String(format: LOCATION_SERVICE, AuthorizationStatus.restricted.translation),
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
        
        viewModel.roadConditionsArray.bind(onNext: { [unowned self] roadConditions in
            print("Number of new conditions: \(roadConditions.count) \n \(roadConditions)")
            prepareMapAndFilter(with: roadConditions)
        })
        .disposed(by: disposeBag)
        
        viewModel.messageTransmitter.bind(onNext: { [unowned self] adviser in
            presentAlert(title: adviser.title,
                         message: adviser.message,
                         buttonTitle: OK,
                         handler: adviser.isError ? { _ in
                            tapBackButton(self) } : nil)
        })
        .disposed(by: disposeBag)
        
        filterViewController.filteredRoadConditionsArray.bind(onNext: { [unowned self] roadConditions in
            loadingIndicatorView.startAnimating()
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotations(roadConditions)
            loadingIndicatorView.stopAnimating()
        })
        .disposed(by: disposeBag)
        
        reloadMapButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.reloadScreen()
        }.disposed(by: disposeBag)
        
        mapTypeButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.mapView.mapType = self.viewModel.currentMapType
            self.mapView.showsTraffic = self.mapView.mapType == .hybrid
        }.disposed(by: disposeBag)
        
        reportButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility(isVisible: true)
        }.disposed(by: disposeBag)
        
        cancelReportButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility()
        }.disposed(by: disposeBag)
        
        confirmReportButton.rx.tap.bind { [unowned self] in
            pushView(viewController: ReportViewController.showReportPage(for: viewModel.getCenterLocation(for: mapView), reportType: .roadConditionReport, delegate: self))
        }.disposed(by: disposeBag)
    }
    
    private func reloadScreen() {
        setReportPinVisibility()
        loadingIndicatorView.startAnimating()
        reloadMapButton.isEnabled = false
        navigationItem.rightBarButtonItems = []
        viewModel.fetchData()
    }
    
    private func prepareMapAndFilter(with roadConditions: [RoadCondition]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(roadConditions)
        
        if let currentLocation = viewModel.userCurrentLocation {
            mapView.setRegion(currentLocation, animated: true)
        }
        
        let roadConditionsDetails = viewModel.getRoadConditionsDetails()
        if roadConditionsDetails != nil {
            navigationItem.rightBarButtonItems?.append(infoButton)
        }
        
        let filterViewModel = FilterViewModel(roadConditions: roadConditions)
        if filterViewModel.numberOfFilters > 1 {
            filterViewController.setData(viewModel: filterViewModel, filterType: .roadConditions)
            let button = filterButton
            button.imageInsets = UIEdgeInsets(top: 0.0, left: 15, bottom: 0, right: roadConditionsDetails != nil ? -15 : 0)
            navigationItem.rightBarButtonItems?.append(button)
        }
        
        reportButton.isHidden = !Reachability.isConnectedToNetwork()
        
        loadingIndicatorView.stopAnimating()
        delay(Constants.Time.TenSeconds) { [weak self] in
            guard let self = self else { return }
            self.reloadMapButton.isEnabled = true
        }
    }
    
    func setupNavigationBar() {
        title = ROAD_CONDITIONS.localizedUppercase
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItems = []
    }
    
    private func setViewModel() {
        viewModel = RoadConditionsViewModel()
    }
    
    @objc
    override func tapInfoButton(_ sender: Any) {
        guard let roadDetails = viewModel.getRoadConditionsDetails() else { return }
        presentView(viewController: DetailsViewController.showDetails(for: DetailsViewModel(roadDetails: roadDetails),
                                                                      delegate: self))
    }
    
    @objc
    override func tapFilterButton(_ sender: Any) {
        presentView(viewController: filterViewController)
    }
    
    private func setReportPinVisibility(isVisible: Bool = false) {
        reportContainer.isHidden = !isVisible
        roadConditionPin.isHidden = !isVisible
        
        guard
            isVisible == true,
            let userCurrentLocation = viewModel.userCurrentLocation
        else { return }
        mapView.setRegion(userCurrentLocation, animated: true)
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
        guard let roadCondition = view.annotation as? RoadCondition else { return }
        presentView(viewController: DetailsViewController.showDetails(for: DetailsViewModel(roadCondition: roadCondition),
                                                                      delegate: self))
    }
}

extension RoadConditionsViewController: ViewProtocol {
    
    func backButtonTaped() { setReportPinVisibility() }
    func reloadView() { reloadScreen() }
}

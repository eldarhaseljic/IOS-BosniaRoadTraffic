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
    
    @IBOutlet var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(CANCEL,for: .normal)
            cancelButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                          borderColor: AppColor.black.cgColor)
            cancelButton.setShadow(shadowColor: AppColor.davysGrey.cgColor,
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
            mapView.register(RoadSignMarkerView.self,
                             forAnnotationViewWithReuseIdentifier:
                                MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }
    
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
        
        viewModel.roadSignsArray.bind(onNext: { [unowned self] roadSigns in
            print("Number of new signs: \(roadSigns.count) \n \(roadSigns)")
            prepareMap(with: roadSigns)
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
        
        reloadMapButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.reloadScreen()
        }.disposed(by: disposeBag)
        
        mapTypeButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.mapView.mapType = self.viewModel.currentMapType
        }.disposed(by: disposeBag)
        
        reportButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility(isVisible: true)
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility()
        }.disposed(by: disposeBag)
        
        confirmReportButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RoadConditionReportViewController.showReportPage(for: viewModel.getCenterLocation(for: mapView), delegate: self))
        }.disposed(by: disposeBag)
    }
    
    private func reloadScreen() {
        setReportPinVisibility()
        loadingIndicatorView.startAnimating()
        reloadMapButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        viewModel.fetchData()
    }
    
    private func prepareMap(with roadSigns: [RoadSign]) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(roadSigns)
        
        if let currentLocation = viewModel.userCurrentLocation {
            mapView.setRegion(currentLocation, animated: true)
        }
        
        if viewModel.getRoadConditionsDetails() != nil {
            navigationItem.rightBarButtonItem?.isEnabled = true
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "info.circle"),
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(tapInfoButton))
        navigationItem.rightBarButtonItem?.isEnabled = false
    }
    
    private func setViewModel() {
        viewModel = RoadConditionsViewModel()
    }
    
    @objc
    public func tapInfoButton(_ sender: Any) {
        guard let roadDetails = viewModel.getRoadConditionsDetails() else { return }
        presentView(viewController: DetailsViewController.showDetails(for: DetailsData(roadDetails: roadDetails)))
    }
    
    private func setReportPinVisibility(isVisible: Bool = false) {
        reportContainer.isHidden = !isVisible
        roadConditionPin.isHidden = !isVisible
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
        presentView(viewController: DetailsViewController.showDetails(for: DetailsData(roadSign: roadSign)))
    }
}

extension RoadConditionsViewController: ReportProtocol {
    
    func backButtonTaped() {
        setReportPinVisibility()
    }
    
    func reloadView() {
        reloadScreen()
    }
}

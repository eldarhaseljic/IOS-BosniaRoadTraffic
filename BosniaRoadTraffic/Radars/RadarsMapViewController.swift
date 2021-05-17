//
//  RadarsMapViewController.swift
//  Bosnia Road Traffic 
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
    @IBOutlet var radarPin: UIImageView!
    @IBOutlet var reportContainer: UIStackView!
    @IBOutlet var reportButton: UIButton!
    
    @IBOutlet var confirmReportButton: UIButton! {
        didSet {
            confirmReportButton.setTitle(REPORT, for: .normal)
            confirmReportButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                                 borderColor: CustomColor.black.cgColor)
            confirmReportButton.setShadow(shadowColor: CustomColor.davysGrey.cgColor,
                                          shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
    @IBOutlet var cancelButton: UIButton! {
        didSet {
            cancelButton.setTitle(CANCEL,for: .normal)
            cancelButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                          borderColor: CustomColor.black.cgColor)
            cancelButton.setShadow(shadowColor: CustomColor.davysGrey.cgColor,
                                   shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
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
            mapView.register(RadarMarkerView.self, forAnnotationViewWithReuseIdentifier:
                                MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
    }
    
    private let disposeBag = DisposeBag()
    private var viewModel: RadarsMapViewModel!
    
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
        
        viewModel.radarsArray.bind(onNext: { [unowned self] radars in
            print("Number of new radars: \(radars.count) \n \(radars)")
            prepareMapAndFilter(with: radars)
        })
        .disposed(by: disposeBag)
        
        viewModel.messageTransmitter.bind(onNext: { [unowned self] adviser in
            presentAlert(title: adviser.title,
                         message: adviser.message,
                         buttonTitle: OK,
                         handler: adviser.isError ? { _ in tapBackButton(self) } : nil)
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
            self.reloadScreen()
        }.disposed(by: disposeBag)
        
        mapTypeButton.rx.tap.bind { [unowned self] in
            mapView.mapType = viewModel.currentMapType
        }.disposed(by: disposeBag)
        
        reportButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility(isVisible: true)
        }.disposed(by: disposeBag)
        
        cancelButton.rx.tap.bind { [unowned self] in
            setReportPinVisibility()
        }.disposed(by: disposeBag)
        
        confirmReportButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RadarReportViewController.showReportPage(for: viewModel.getCenterLocation(for: mapView),
                                                                              delegate: self))
        }.disposed(by: disposeBag)
    }
    
    private func reloadScreen() {
        setReportPinVisibility()
        loadingIndicatorView.startAnimating()
        reloadMapButton.isEnabled = false
        navigationItem.rightBarButtonItem?.isEnabled = false
        viewModel.fetchData()
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
        
        reportButton.isHidden = !Reachability.isConnectedToNetwork()
        
        loadingIndicatorView.stopAnimating()
        delay(Constants.Time.TenSeconds) { [weak self] in
            guard let self = self else { return }
            self.reloadMapButton.isEnabled = true
        }
    }
    
    private func setupNavigationBar() {
        title = RADAR_LOCATIONS.localizedUppercase
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(image:  #imageLiteral(resourceName: "slider.horizontal"), style: .done, target: self,
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
    
    private func setReportPinVisibility(isVisible: Bool = false) {
        reportContainer.isHidden = !isVisible
        radarPin.isHidden = !isVisible
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
        setReportPinVisibility()
        presentView(viewController: RadarDetailsViewController.showDetails(for: radar))
    }
}

extension RadarsMapViewController: RadarReportProtocol {
    
    func backButtonTaped() { setReportPinVisibility() }
    func reloadView() { reloadScreen() }
}

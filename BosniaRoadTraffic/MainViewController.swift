//
//  MainViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/3/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import RxSwift
import RxCocoa

protocol ReportProtocol: AnyObject {
    func backButtonTaped()
    func reloadView()
}

class MainViewController: UIViewController {
    
    @IBOutlet var facebookButton: UIButton!
    @IBOutlet var instagramButton: UIButton!
    @IBOutlet var twitterButton: UIButton!
    @IBOutlet var linkedInButton: UIButton!
    
    @IBOutlet var radarsButton: UIButton! {
        didSet {
            radarsButton.setTitle(RADAR_LOCATIONS, for: .normal)
            radarsButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                          borderColor: AppColor.black.cgColor)
            radarsButton.setShadow(shadowColor: AppColor.davysGrey.cgColor,
                                   shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
    @IBOutlet var roadConditionsButton: UIButton! {
        didSet {
            roadConditionsButton.setTitle(ROAD_CONDITIONS, for: .normal)
            roadConditionsButton.setRoundedBorder(borderWidth: Constants.BorderWidth.TwoPoints,
                                                  borderColor: AppColor.black.cgColor)
            roadConditionsButton.setShadow(shadowColor: AppColor.davysGrey.cgColor,
                                           shadowRadius: Constants.ShadowRadius.ThreePoints)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = BOSNIA_ROAD_TRAFFIC.localizedUppercase
        setupObservers()
    }
    
    func setupObservers() {
        radarsButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RadarsMapViewController.showRadars())
        }.disposed(by: disposeBag)
        
        roadConditionsButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RoadConditionsViewController.showRoadConditions())
        }.disposed(by: disposeBag)
        
        facebookButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.openExternalUrl(urlString: Constants.URLPaths.facebookURL)
        }.disposed(by: disposeBag)
        
        instagramButton.rx.tap.bind {  [weak self] in
            guard let self = self else { return }
            self.openExternalUrl(urlString: Constants.URLPaths.instagramURL)
        }.disposed(by: disposeBag)
        
        twitterButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.openExternalUrl(urlString: Constants.URLPaths.twitterURL)
        }.disposed(by: disposeBag)
        
        linkedInButton.rx.tap.bind {  [weak self] in
            guard let self = self else { return }
            self.openExternalUrl(urlString: Constants.URLPaths.errorURL)
        }.disposed(by: disposeBag)
    }
}

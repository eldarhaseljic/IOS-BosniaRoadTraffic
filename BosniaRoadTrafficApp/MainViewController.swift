//
//  MainViewController.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 1/3/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    private let borderWidth: CGFloat = 2.0
    private let shadowRadius: CGFloat = 3.0
    @IBOutlet var radarsButton: UIButton! {
        didSet {
            radarsButton.setTitle(RADAR_LOCATIONS,for: .normal)
            radarsButton.setRoundedBorder(borderWidth: borderWidth,
                                          borderColor: CustomColor.black.cgColor)
            radarsButton.setShadow(shadowColor: CustomColor.davysGrey.cgColor,
                                   shadowRadius: shadowRadius)
        }
    }
    
    @IBOutlet var roadConditionsButton: UIButton! {
        didSet {
            roadConditionsButton.setTitle(ROAD_CONDITIONS, for: .normal)
            roadConditionsButton.setRoundedBorder(borderWidth: borderWidth,
                                                  borderColor: CustomColor.black.cgColor)
            roadConditionsButton.setShadow(shadowColor: CustomColor.davysGrey.cgColor,
                                           shadowRadius: shadowRadius)
        }
    }
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = BOSNIA_ROAD_TRAFFIC.localizedUppercase
        setupObservers()
    }
    
    func setupObservers() {
        radarsButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RadarsMapViewController.showRadars())
        }
        .disposed(by: disposeBag)
        
        roadConditionsButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RoadConditionsViewController.showRoadConditions())
        }
        .disposed(by: disposeBag)
    }
}


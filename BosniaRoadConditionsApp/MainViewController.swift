//
//  MainViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/3/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import RxSwift
import RxCocoa

class MainViewController: UIViewController {
    
    @IBOutlet var radarsButton: UIButton!
    private let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        title = BOSNIA_ROAD_CONDITIONS
        setupObservers()
    }
    
    func setupObservers() {
        radarsButton.rx.tap.bind { [unowned self] in
            pushView(viewController: RadarsMapViewController.showRadars())
        }.disposed(by: disposeBag)
    }
}

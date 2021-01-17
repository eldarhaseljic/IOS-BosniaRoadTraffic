//
//  ViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/3/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private let persistanceService = PersistanceService.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        MainManager.shared.getRadars() { [weak self] success, error in
            guard let self = self else { return }
            if success {
                let newRadars = MainManager.shared.fetchRadars(objectContext: self.persistanceService.context)
                print("Number of new radars: \(newRadars.count) \n \(newRadars)")
                print("Done")
            } else {
                print((String(describing: error?.description)))
            }
        }
    }
}


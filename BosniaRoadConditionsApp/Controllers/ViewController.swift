//
//  ViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/3/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        AppManager.shared.getRadars {
            allPokemons in
            
            switch allPokemons {
            case .failure(let error):
                print(error)
            case .success(_):
                print("done")
            }
        }
    }
}


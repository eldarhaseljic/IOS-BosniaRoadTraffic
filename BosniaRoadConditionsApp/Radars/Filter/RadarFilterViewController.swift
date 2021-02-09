//
//  RadarFilterViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/9/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RadarFilterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension RadarFilterViewController {
    static func getViewController() -> RadarFilterViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarFilterStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarFilterViewController.self)!
    }
    
    static func showFilters() -> RadarFilterViewController {
        let radarDetailsViewController = RadarFilterViewController.getViewController()
        return radarDetailsViewController
    }
}

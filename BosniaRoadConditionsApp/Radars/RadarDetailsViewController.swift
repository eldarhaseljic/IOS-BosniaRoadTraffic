//
//  RadarDetailsViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RadarDetailsViewController: UIViewController {

    @IBOutlet var navigationBarItem: UINavigationItem!
    private var currentRadar: Radar!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBarItem.leftBarButtonItem = closeButton
    }
    
    func setData(for radar: Radar) {
        currentRadar = radar
    }
}

extension RadarDetailsViewController {
    static func getViewController() -> RadarDetailsViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarDetailsStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarDetailsViewController.self)!
    }
    
    static func showDetails(for radar: Radar) -> RadarDetailsViewController {
        let radarDetailsViewController = RadarDetailsViewController.getViewController()
        radarDetailsViewController.setData(for: radar)
        return radarDetailsViewController
    }
}

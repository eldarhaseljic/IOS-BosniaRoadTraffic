//
//  RadarDetailsViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RadarDetailsViewController: UIViewController {

    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = closeButton
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: RadarDetailsViewCell.self)
        }
    }
    
    override func viewDidLoad() { super .viewDidLoad() }
    private var currentRadar: Radar!
    
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

extension RadarDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RadarDetailsViewCell.self,
                                                 for: indexPath)
        cell.configure(for: currentRadar)
        return cell
    }
}

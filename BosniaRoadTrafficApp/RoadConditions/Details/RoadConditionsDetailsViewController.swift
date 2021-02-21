//
//  RoadConditionsDetailsViewController.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RoadConditionsDetailsViewController: UIViewController {

    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = closeButton
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: RoadConditionsDetailsViewCell.self)
        }
    }
    
    private var currentSign: RoadSign!
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    func setData(for roadSign: RoadSign) {
        currentSign = roadSign
    }
}

extension RoadConditionsDetailsViewController {
    static func getViewController() -> RoadConditionsDetailsViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RoadConditionsDetailsStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RoadConditionsDetailsViewController.self)!
    }
    
    static func showDetails(for roadSign: RoadSign) -> RoadConditionsDetailsViewController {
        let roadConditionsDetailsViewController = RoadConditionsDetailsViewController.getViewController()
        roadConditionsDetailsViewController.setData(for: roadSign)
        return roadConditionsDetailsViewController
    }
}

extension RoadConditionsDetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RoadConditionsDetailsViewCell.self, for: indexPath)
        cell.configure(for: currentSign)
        return cell
    }
}

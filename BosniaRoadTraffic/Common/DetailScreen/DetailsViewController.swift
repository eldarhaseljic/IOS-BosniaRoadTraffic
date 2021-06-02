//
//  DetailsViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

import UIKit

class DetailsViewController: UIViewController {

    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = closeButton
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: DetailsViewCell.self)
        }
    }
    
    private var data: DetailsData!
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    func setData(for data: DetailsData) {
        self.data = data
    }
}

extension DetailsViewController {
    static func getViewController() -> DetailsViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.DetailsStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(DetailsViewController.self)!
    }
    
    static func showDetails(for data: DetailsData) -> DetailsViewController {
        let detailsViewController = DetailsViewController.getViewController()
        detailsViewController.setData(for: data)
        return detailsViewController
    }
}

extension DetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: DetailsViewCell.self, for: indexPath)
        cell.configure(for: data)
        return cell
    }
}

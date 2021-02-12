//
//  RadarFilterViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/9/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class RadarFilterViewController: UIViewController {
    
    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = cancelButton(action: #selector(tapCancelButton))
            navigationBarItem.rightBarButtonItem = applyButton(action: #selector(tapApplyButton))
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: RadarFilterOptionTableViewCell.self)
        }
    }
    
    private var viewModel: RadarFilterViewModel!
    
    let filteredRadarsArray = PublishSubject<[Radar]>()
    
    @objc
    private func tapCancelButton(_ sender: Any) {
        viewModel.resetFilters()
        contextView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func tapApplyButton(_ sender: Any) {
        filteredRadarsArray.onNext(viewModel.filterRadars())
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super .viewDidLoad()
        
    }
    
    func setData(viewModel: RadarFilterViewModel) {
        self.viewModel = viewModel
    }
}

extension RadarFilterViewController {
    static func getViewController() -> RadarFilterViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarFilterStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarFilterViewController.self)!
    }
    
    static func showFilters(for viewModel: RadarFilterViewModel) -> RadarFilterViewController {
        let radarFilterViewController = RadarFilterViewController.getViewController()
        radarFilterViewController.setData(viewModel: viewModel)
        return radarFilterViewController
    }
}

extension RadarFilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFilters
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: RadarFilterOptionTableViewCell.self,
                                                 for: indexPath)
        let radarOption = viewModel.getRadarOption(index: indexPath.row)
        cell.configureCell(radarType: radarOption.type,
                           isSwitchEnabled: viewModel.checkRadarType(type: radarOption.type),
                           isSwitchOn: radarOption.isOn)
        cell.optionSwitch.rx.isOn
            .changed
            .distinctUntilChanged()
            .bind { [weak self] isOn in
                self?.viewModel.selectRadarType(index: indexPath.row, selected: isOn)
                self?.contextView.reloadData()
            }
            .disposed(by: cell.disposeBag)
        return cell
    }
}

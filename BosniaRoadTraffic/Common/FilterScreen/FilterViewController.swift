//
//  FilterViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/9/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class FilterViewController: UIViewController {
    
    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = cancelButton(action: #selector(tapCancelButton))
            navigationBarItem.rightBarButtonItem = applyButton(action: #selector(tapApplyButton))
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: FilterOptionTableViewCell.self)
        }
    }
    
    private var viewModel: FilterViewModel!
    private var filterType: FilterType = .radars
    
    let filteredRadarsArray = PublishSubject<[Radar]>()
    let filteredRoadSignArray = PublishSubject<[RoadSign]>()
    
    override func viewDidLoad() { super .viewDidLoad() }
    
    @objc
    private func tapCancelButton(_ sender: Any) {
        viewModel.resetFilters()
        contextView.reloadData()
        dismiss(animated: true)
    }
    
    @objc
    private func tapApplyButton(_ sender: Any) {
        switch filterType {
        case .radars:
            filteredRadarsArray.onNext(viewModel.filterRadars())
        case .roadConditions:
            filteredRoadSignArray.onNext(viewModel.filterRoadSigns())
        }
        
        dismiss(animated: true)
    }
    
    func setData(viewModel: FilterViewModel, filterType: FilterType) {
        self.viewModel = viewModel
        self.filterType = filterType
        if let view = contextView { view.reloadData() }
    }
}

extension FilterViewController {
    static func getViewController() -> FilterViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.FilterStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(FilterViewController.self)!
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfFilters
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: FilterOptionTableViewCell.self,
                                                 for: indexPath)
        cell.configureCell(radarOption: viewModel.getOption(index: indexPath.row))
        cell.optionSwitch.rx.isOn
            .changed
            .distinctUntilChanged()
            .bind { [weak self] isOn in
                guard let self = self else { return }
                self.viewModel.selectType(index: indexPath.row,
                                          selected: isOn)
                self.contextView.reloadData()
            }.disposed(by: cell.disposeBag)
        return cell
    }
}

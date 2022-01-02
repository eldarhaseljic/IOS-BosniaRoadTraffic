//
//  ReportViewController.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 4/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift
import MapKit

enum ReportType {
    case radarReport
    case roadConditionReport
}

class ReportViewController: UIViewController {
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: RoadConditionReportViewCell.self)
            contextView.registerCell(cellType: RadarReportViewCell.self)
        }
    }
    
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView! {
        didSet {
            loadingIndicatorView.appendBlurredBackground()
            loadingIndicatorView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }
    }
    
    private var location: CLLocation!
    private var disposeBag: DisposeBag = DisposeBag()
    private var reportType: ReportType!
    weak var delegate: ViewProtocol?
    
    override func viewDidLoad() {
        super .viewDidLoad()
        setupNavigationBar()
        hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillDisappear),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setData(location: CLLocation,
                 reportType: ReportType,
                 delegate: ViewProtocol? = nil) {
        self.location = location
        self.reportType = reportType
        self.delegate = delegate
    }
    
    private func setupNavigationBar() {
        title = reportType == .radarReport ? REPORT_RADAR : REPORT_ROAD_CONDITION
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc
    override func tapBackButton(_ sender: Any) {
        delegate?.backButtonTaped()
        navigationController?.popViewController(animated: true)
    }
    
    @objc
    func keyboardWillAppear(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            contextView.contentInset.bottom = keyboardHeight
        }
    }

    @objc
    func keyboardWillDisappear() {
        contextView.contentInset.bottom = .zero
    }
}

extension ReportViewController {
    static func getViewController() -> ReportViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.ReportStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(ReportViewController.self)!
    }
    
    static func showReportPage(for location: CLLocation, reportType: ReportType, delegate: ViewProtocol? = nil) -> ReportViewController {
        let reportViewController = ReportViewController.getViewController()
        reportViewController.setData(location: location,
                                     reportType: reportType,
                                     delegate: delegate)
        return reportViewController
    }
}


extension ReportViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch reportType {
        case .radarReport:
            let cell = tableView.dequeueReusableCell(with: RadarReportViewCell.self, for: indexPath)
            cell.configure(viewModel: RadarReportCellViewModel(for: location))
            cell.messageTransmitter.bind(onNext: { [unowned self] adviser in
                presentAlert(title: adviser.title,
                             message: adviser.message,
                             buttonTitle: OK,
                             handler: adviser.isError ? { _ in
                                delegate?.reloadView()
                                tapBackButton(self)
                             } : nil)
            })
            .disposed(by: disposeBag)
            
            cell.loaderStatus.bind(onNext: { [unowned self] status in
                if status == true {
                    loadingIndicatorView.startAnimating()
                } else {
                    loadingIndicatorView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
            
            cell.selectedTexView.bind(onNext: { [unowned self] textViewFrame in
                contextView.scrollRectToVisible(textViewFrame, animated: true)
            })
            .disposed(by: disposeBag)
            return cell
        case .roadConditionReport:
            let cell = tableView.dequeueReusableCell(with: RoadConditionReportViewCell.self, for: indexPath)
            cell.configure(viewModel: RoadConditionReportCellViewModel(for: location))
            cell.messageTransmitter.bind(onNext: { [unowned self] adviser in
                presentAlert(title: adviser.title,
                             message: adviser.message,
                             buttonTitle: OK,
                             handler: adviser.isError ? { _ in
                                delegate?.reloadView()
                                tapBackButton(self)
                             } : nil)
            })
            .disposed(by: disposeBag)
            
            cell.loaderStatus.bind(onNext: { [unowned self] status in
                if status == true {
                    loadingIndicatorView.startAnimating()
                } else {
                    loadingIndicatorView.stopAnimating()
                }
            })
            .disposed(by: disposeBag)
            
            cell.selectedTexView.bind(onNext: { [unowned self] textViewFrame in
                contextView.scrollRectToVisible(textViewFrame, animated: true)
            })
            .disposed(by: disposeBag)
            return cell
        case .none:
            return UITableViewCell()
        }
    }
}

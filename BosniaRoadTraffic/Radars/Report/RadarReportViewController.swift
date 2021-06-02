//
//  RadarReportViewController.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 4/17/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift
import MapKit

class RadarReportViewController: UIViewController {
    
    @IBOutlet var contextView: UITableView! {
        didSet {
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
    weak var delegate: ReportProtocol?
    
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
    
    
    func setData(location: CLLocation, delegate: ReportProtocol? = nil) {
        self.location = location
        self.delegate = delegate
    }
    
    private func setupNavigationBar() {
        title = REPORT_RADAR
        navigationItem.leftBarButtonItem = backButton(action: #selector(tapBack))
    }
    
    @objc
    public func tapBack(_ sender: Any) {
        delegate?.backButtonTaped()
        tapBackButton(sender)
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

extension RadarReportViewController {
    static func getViewController() -> RadarReportViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarReportStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(RadarReportViewController.self)!
    }
    
    static func showReportPage(for location: CLLocation, delegate: ReportProtocol? = nil) -> RadarReportViewController {
        let radarReportViewController = RadarReportViewController.getViewController()
        radarReportViewController.setData(location: location, delegate: delegate)
        return radarReportViewController
    }
}


extension RadarReportViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
        return cell
    }
}

//
//  DetailsViewController.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class DetailsViewController: UIViewController {
    
    weak var delegate: ViewProtocol?
    
    @IBOutlet var navigationBarItem: UINavigationItem! {
        didSet {
            navigationBarItem.leftBarButtonItem = closeButton
            if data.detailsType != .roadDetails {
                navigationBarItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "report_annotation"),
                                                                       style: .done,
                                                                       target: self,
                                                                       action: #selector(tapReportButton))
            }
        }
    }
    
    @IBOutlet var loadingIndicatorView: UIActivityIndicatorView! {
        didSet {
            loadingIndicatorView.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
        }
    }
    
    @IBOutlet var contextView: UITableView! {
        didSet {
            contextView.registerCell(cellType: DetailsViewCell.self)
        }
    }
    
    private var data: DetailsViewModel!
    
    override func viewDidLoad() { super.viewDidLoad() }
    
    func setData(for data: DetailsViewModel,
                 delegate: ViewProtocol?) {
        self.data = data
        self.delegate = delegate
    }
    
    @objc
    func tapReportButton(_ sender: Any) {
        let blurEffect = UIBlurEffect(style: .regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = contextView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contextView.addSubview(blurEffectView)
        loadingIndicatorView.startAnimating()
        data.updateOrDeleteElement { [weak self] status, message in
            guard let self = self else { return }
            switch status {
            case .updated:
                self.presentAlert(title: SUCCESSFULLY_REPORTED,
                                  message: message,
                                  buttonTitle: OK)
                for subview in self.contextView.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                self.contextView.reloadData()
                self.delegate?.reloadView()
                self.loadingIndicatorView.stopAnimating()
            case .deleted:
                self.loadingIndicatorView.stopAnimating()
                for subview in self.contextView.subviews {
                    if subview is UIVisualEffectView {
                        subview.removeFromSuperview()
                    }
                }
                self.presentAlert(title: SUCCESSFULLY_DELETED,
                                  message: message,
                                  buttonTitle: OK,
                                  handler: { _ in
                                    self.delegate?.reloadView()
                                    self.tapCloseButton(self)
                                  })
            case .error:
                self.loadingIndicatorView.stopAnimating()
                self.contextView.removeFromSuperview()
                self.presentAlert(title: ERROR_DESCRIPTION,
                                  message: message,
                                  buttonTitle: OK)
            }
        }
    }
}

extension DetailsViewController {
    static func getViewController() -> DetailsViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.DetailsStoryboard, bundle: nil)
            .instantiateViewControllerWithIdentifier(DetailsViewController.self)!
    }
    
    static func showDetails(for data: DetailsViewModel,
                            delegate: ViewProtocol?) -> DetailsViewController {
        let detailsViewController = DetailsViewController.getViewController()
        detailsViewController.setData(for: data, delegate: delegate)
        return detailsViewController
    }
}

extension DetailsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(with: DetailsViewCell.self,
                                                 for: indexPath)
        cell.configure(for: data)
        return cell
    }
}

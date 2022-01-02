//
//  RoadConditionReportViewCell.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 1/6/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class RoadConditionReportViewCell: UITableViewCell {
    
    @IBOutlet var conditionTypePickerField: DesignableUITextField! {
        didSet {
            conditionTypePickerView.delegate = self
            conditionTypePickerView.dataSource = self
            conditionTypePickerView.toolbarDelegate = self
            conditionTypePickerField.inputView = conditionTypePickerView
            conditionTypePickerField.inputAccessoryView = conditionTypePickerView.toolbar
            conditionTypePickerField.delegate = self
        }
    }
    
    @IBOutlet var roadTypePickerField: DesignableUITextField! {
        didSet {
            roadTypePickerView.delegate = self
            roadTypePickerView.dataSource = self
            roadTypePickerView.toolbarDelegate = self
            roadTypePickerField.inputView = roadTypePickerView
            roadTypePickerField.inputAccessoryView = roadTypePickerView.toolbar
            roadTypePickerField.delegate = self
        }
    }
    
    @IBOutlet var roadConditionCoordinatesTitle: UILabel!
    @IBOutlet var roadConditionTitleLabel: UILabel!
    @IBOutlet var conditionTypeLabel: UILabel!
    @IBOutlet var roadConditionStreetLabel: UILabel!
    @IBOutlet var roadTypeLabel: UILabel!
    @IBOutlet var roadConditionDetailLabel: UILabel!
    
    @IBOutlet var roadConditionCordinatesContext: UILabel! {
        didSet {
            roadConditionCordinatesContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints,
                                                           masksToBounds: true)
        }
    }
    
    @IBOutlet var roadConditionTitleContext: UITextView! {
        didSet {
            roadConditionTitleContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints,
                                                      masksToBounds: true)
        }
    }
    
    @IBOutlet var roadConditionStreetContext: UITextView! {
        didSet {
            roadConditionStreetContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints,
                                                       masksToBounds: true)
        }
    }
    
    @IBOutlet var roadConditionDetailContext: UITextView!{
        didSet {
            roadConditionDetailContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints,
                                                       masksToBounds: true)
        }
    }
    
    @IBOutlet var applyButton: UIButton! {
        didSet {
            applyButton.setTitle(REPORT_ROAD_CONDITION, for: .normal)
            applyButton.setCornerRadius(cornerRadius: Constants.CornerRadius.EightPoints)
        }
    }
    
    private var conditionTypePickerView = ToolbarPickerView()
    private var roadTypePickerView = ToolbarPickerView()
    private var viewModel: RoadConditionReportCellViewModel!
    let selectedTexView = PublishSubject<CGRect>()
    let messageTransmitter = PublishSubject<Adviser>()
    let loaderStatus = PublishSubject<Bool>()
    let disposeBag: DisposeBag = DisposeBag()
    
    func configure(viewModel: RoadConditionReportCellViewModel) {
        self.viewModel = viewModel
        setupLabels()
        setupObservers()
    }
    
    func setupObservers() {
        applyButton.rx.tap.bind { [weak self] in
            guard let self = self else { return }
            self.loaderStatus.onNext(true)
            self.handleApplyButton()
        }.disposed(by: disposeBag)
    }
    
    private func handleApplyButton() {
        if let roadType = viewModel.getRoadType(for: roadTypePickerField.text) {
            if let conditionType = viewModel.getConditionType(for: conditionTypePickerField.text) {
                if let title = roadConditionTitleContext.text, title.isNotEmpty {
                    loaderStatus.onNext(true)
                    viewModel.addNewRoadCondition(roadType: roadType,
                                                  road: roadConditionStreetContext.text,
                                                  text: roadConditionDetailContext.text,
                                                  title: title,
                                                  conditionType: conditionType) { [weak self] status,error in
                        self?.messageTransmitter.onNext(Adviser(title: ROAD_CONDITIONS_INFO, message: error, isError: true))
                        self?.loaderStatus.onNext(false)
                    }
                } else {
                    messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: ENTER_ROAD_CONDITION_TITLE))
                    loaderStatus.onNext(false)
                    return
                }
            } else {
                messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: SELECT_CONDITION_SIGN))
                loaderStatus.onNext(false)
                return
            }
        } else {
            messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: SELECT_ROAD_TYPE))
            loaderStatus.onNext(false)
            return
        }
    }
    
    private func setupLabels() {
        roadConditionCoordinatesTitle.text = ROAD_CONDITION_LOCATION
        roadConditionCordinatesContext.text = viewModel.locationString
        roadTypeLabel.text = ROAD_TYPE
        roadTypePickerField.text = viewModel.currentRoadType
        roadConditionTitleLabel.text = INSERT_ROAD_CONDITION_TITLE
        roadConditionStreetLabel.text = STREET
        conditionTypeLabel.text = TYPE_OF_ROAD_CONDITION
        conditionTypePickerField.text = viewModel.currentConditionType
        roadConditionDetailLabel.text = DETAILS
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    private func clear() {
        roadConditionCordinatesContext.text = String()
        roadTypePickerField.text = String()
        conditionTypePickerField.text = String()
        roadConditionTitleContext.text = String()
        roadConditionTitleLabel.text = String()
        roadTypeLabel.text = String()
        roadConditionStreetLabel.text = String()
        conditionTypeLabel.text = String()
        roadConditionDetailLabel.text = String()
        roadConditionCordinatesContext.text = String()
        roadConditionTitleContext.text = String()
        roadConditionStreetContext.text = String()
        roadConditionDetailContext.text = String()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillAppear),
                                               name: UIResponder.keyboardWillShowNotification,
                                               object: nil)
    }
    
    @objc
    func keyboardWillAppear(_ notification: Notification) {
        if roadConditionDetailContext.isFirstResponder {
            selectedTexView.onNext(roadConditionDetailContext.frame)
        } else if roadConditionStreetContext.isFirstResponder {
            selectedTexView.onNext(roadConditionStreetContext.frame)
        } else if roadConditionTitleContext.isFirstResponder {
            selectedTexView.onNext(roadConditionTitleContext.frame)
        }
    }
}

extension RoadConditionReportViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case conditionTypePickerView:
            return viewModel.numberOfConditionTypes
        case roadTypePickerView:
            return viewModel.numberOfRoadTypes
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case conditionTypePickerView:
            return viewModel.getConditionTypeName(for: row)
        case roadTypePickerView:
            return viewModel.getRoadTypeName(for: row)
        default:
            return nil
        }
    }
}

extension RoadConditionReportViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case conditionTypePickerView,
             roadTypePickerView:
            return false
        default:
            return true
        }
    }
}

extension RoadConditionReportViewCell: ToolbarPickerViewDelegate {
    
    func didTapDone(_ picker: ToolbarPickerView) {
        switch picker {
        case conditionTypePickerView:
            viewModel.currentConditionType = viewModel.getConditionTypeName(for: conditionTypePickerView.selectedRow(inComponent: .zero))
            conditionTypePickerField.text = viewModel.currentConditionType
            conditionTypePickerField.resignFirstResponder()
        case roadTypePickerView:
            viewModel.currentRoadType = viewModel.getRoadTypeName(for: roadTypePickerView.selectedRow(inComponent: .zero))
            roadTypePickerField.text = viewModel.currentRoadType
            roadTypePickerField.resignFirstResponder()
        default:
            break
        }
    }
    
    func didTapCancel(_ picker: ToolbarPickerView) {
        switch picker {
        case conditionTypePickerView:
            if conditionTypePickerField.text != viewModel.currentConditionType {
                conditionTypePickerField.text = viewModel.currentConditionType
            }
            conditionTypePickerField.resignFirstResponder()
        case roadTypePickerView:
            if roadTypePickerField.text != viewModel.currentRoadType {
                roadTypePickerField.text = viewModel.currentRoadType
            }
            roadTypePickerField.resignFirstResponder()
        default:
            break
        }
    }
}

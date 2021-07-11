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
    
    @IBOutlet var conditionSingPickerField: UITextField! {
        didSet {
            conditionSingPickerView.delegate = self
            conditionSingPickerView.dataSource = self
            conditionSingPickerView.toolbarDelegate = self
            conditionSingPickerField.inputView = conditionSingPickerView
            conditionSingPickerField.inputAccessoryView = conditionSingPickerView.toolbar
            conditionSingPickerField.delegate = self
        }
    }
    
    @IBOutlet var roadTypePickerField: UITextField! {
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
    @IBOutlet var conditionSingLabel: UILabel!
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
    
    private var conditionSingPickerView = ToolbarPickerView()
    private var roadTypePickerView = ToolbarPickerView()
    private var viewModel: RoadConditionReportCellViewModel!
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
            if let conditionSing = viewModel.getConditionSing(for: conditionSingPickerField.text) {
                if let title = roadConditionTitleContext.text, title.isNotEmpty {
                    loaderStatus.onNext(true)
                    viewModel.addNewRoadCondition(roadType: roadType,
                                                  road: roadConditionStreetContext.text,
                                                  text: roadConditionDetailContext.text,
                                                  title: title,
                                                  signIcon: conditionSing) { [weak self] status,error in
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
        conditionSingLabel.text = TYPE_OF_ROAD_CONDITION
        conditionSingPickerField.text = viewModel.currentConditionSing
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
        conditionSingPickerField.text = String()
        roadConditionTitleContext.text = String()
        roadConditionTitleLabel.text = String()
        roadTypeLabel.text = String()
        roadConditionStreetLabel.text = String()
        conditionSingLabel.text = String()
        roadConditionDetailLabel.text = String()
        roadConditionCordinatesContext.text = String()
        roadConditionTitleContext.text = String()
        roadConditionStreetContext.text = String()
        roadConditionDetailContext.text = String()
    }
}

extension RoadConditionReportViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case conditionSingPickerView:
            return viewModel.numberOfConditionSings
        case roadTypePickerView:
            return viewModel.numberOfRoadTypes
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case conditionSingPickerView:
            return viewModel.getConditionSingName(for: row)
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
        case conditionSingPickerView,
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
        case conditionSingPickerView:
            viewModel.currentConditionSing = viewModel.getConditionSingName(for: conditionSingPickerView.selectedRow(inComponent: .zero))
            conditionSingPickerField.text = viewModel.currentConditionSing
            conditionSingPickerField.resignFirstResponder()
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
        case conditionSingPickerView:
            if conditionSingPickerField.text != viewModel.currentConditionSing {
                conditionSingPickerField.text = viewModel.currentConditionSing
            }
            conditionSingPickerField.resignFirstResponder()
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

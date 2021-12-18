//
//  RadarReportViewCell.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 4/24/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class RadarReportViewCell: UITableViewCell {
    
    @IBOutlet var radarTypePickerField: DesignableUITextField! {
        didSet {
            radarTypePickerView.delegate = self
            radarTypePickerView.dataSource = self
            radarTypePickerView.toolbarDelegate = self
            radarTypePickerField.inputView = radarTypePickerView
            radarTypePickerField.inputAccessoryView = radarTypePickerView.toolbar
            radarTypePickerField.delegate = self
        }
    }
    
    @IBOutlet var MUPTypePickerField: DesignableUITextField! {
        didSet {
            MUPTypePickerView.delegate = self
            MUPTypePickerView.dataSource = self
            MUPTypePickerView.toolbarDelegate = self
            MUPTypePickerField.inputView = MUPTypePickerView
            MUPTypePickerField.inputAccessoryView = MUPTypePickerView.toolbar
            MUPTypePickerField.delegate = self
        }
    }
    
    @IBOutlet var radarCoordinatesTitle: UILabel!
    @IBOutlet var radarTitleLabel: UILabel!
    @IBOutlet var radarTypeLabel: UILabel!
    @IBOutlet var radarStreetLabel: UILabel!
    @IBOutlet var MUPTypeLabel: UILabel!
    @IBOutlet var radarDetailLabel: UILabel!
    
    @IBOutlet var radarCordinatesContext: UILabel! {
        didSet {
            radarCordinatesContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints, masksToBounds: true)
        }
    }
    
    @IBOutlet var radarTitleContext: UITextView! {
        didSet {
            radarTitleContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints, masksToBounds: true)
        }
    }
    
    @IBOutlet var radarStreetContext: UITextView! {
        didSet {
            radarStreetContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints, masksToBounds: true)
        }
    }
    
    @IBOutlet var radarDetailContext: UITextView!{
        didSet {
            radarDetailContext.setCornerRadius(cornerRadius: Constants.CornerRadius.FourPoints, masksToBounds: true)
        }
    }
    
    @IBOutlet var applyButton: UIButton! {
        didSet {
            applyButton.setTitle(REPORT_RADAR, for: .normal)
            applyButton.setCornerRadius(cornerRadius: Constants.CornerRadius.EightPoints)
        }
    }
    
    private var radarTypePickerView = ToolbarPickerView()
    private var MUPTypePickerView = ToolbarPickerView()
    private var viewModel: RadarReportCellViewModel!
    let messageTransmitter = PublishSubject<Adviser>()
    let loaderStatus = PublishSubject<Bool>()
    let disposeBag: DisposeBag = DisposeBag()
    
    func configure(viewModel: RadarReportCellViewModel) {
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
        if let radarType = viewModel.getRadarType(for: radarTypePickerField.text) {
            if let title = radarTitleContext.text, title.isNotEmpty {
                loaderStatus.onNext(true)
                viewModel.addNewRadar(policeDepartmentName: MUPTypePickerField.text,
                                      road: radarStreetContext.text,
                                      text: radarDetailContext.text,
                                      title: title,
                                      type: radarType) { [weak self] status,error in
                    self?.messageTransmitter.onNext(Adviser(title: RADARS_INFO, message: error, isError: true))
                    self?.loaderStatus.onNext(false)
                }
            } else {
                messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: ENTER_RADAR_TITLE))
                loaderStatus.onNext(false)
                return
            }
        } else {
            messageTransmitter.onNext(Adviser(title: ERROR_DESCRIPTION, message: SELECT_RADAR_TYPE))
            loaderStatus.onNext(false)
            return
        }
    }
    
    private func setupLabels() {
        MUPTypePickerField.text = viewModel.currentMUP
        radarTypePickerField.text = viewModel.currentRadarType
        radarCordinatesContext.text = viewModel.locationString
        radarCoordinatesTitle.text = RADAR_LOCATION
        radarTitleLabel.text = INSERT_RADAR_TITLE
        radarTypeLabel.text = TYPE_OF_RADAR
        radarStreetLabel.text = STREET
        MUPTypeLabel.text = POLICE_DEPARTMENT
        radarDetailLabel.text = DETAILS
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
        radarCordinatesContext.text = String()
        radarTypePickerField.text = String()
        MUPTypePickerField.text = String()
        radarCoordinatesTitle.text = String()
        radarTitleLabel.text = String()
        radarTypeLabel.text = String()
        radarStreetLabel.text = String()
        MUPTypeLabel.text = String()
        radarDetailLabel.text = String()
        radarCordinatesContext.text = String()
        radarTitleContext.text = String()
        radarStreetContext.text = String()
        radarDetailContext.text = String()
    }
}

extension RadarReportViewCell: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case radarTypePickerView:
            return viewModel.numberOfRadarTypes
        case MUPTypePickerView:
            return viewModel.numberOfMUPs
        default:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case radarTypePickerView:
            return viewModel.getRadarType(for: row)
        case MUPTypePickerView:
            return viewModel.getMUPType(for: row)
        default:
            return nil
        }
    }
}

extension RadarReportViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        switch textField {
        case radarTypePickerField,
             MUPTypePickerField:
            return false
        default:
            return true
        }
    }
}

extension RadarReportViewCell: ToolbarPickerViewDelegate {
    
    func didTapDone(_ picker: ToolbarPickerView) {
        switch picker {
        case radarTypePickerView:
            viewModel.currentRadarType = viewModel.getRadarType(for: radarTypePickerView.selectedRow(inComponent: .zero))
            radarTypePickerField.text = viewModel.currentRadarType
            radarTypePickerField.resignFirstResponder()
        case MUPTypePickerView:
            viewModel.currentMUP = viewModel.getMUPType(for: MUPTypePickerView.selectedRow(inComponent: .zero))
            MUPTypePickerField.text = viewModel.currentMUP
            MUPTypePickerField.resignFirstResponder()
        default:
            break
        }
    }
    
    func didTapCancel(_ picker: ToolbarPickerView) {
        switch picker {
        case radarTypePickerView:
            if radarTypePickerField.text != viewModel.currentRadarType {
                radarTypePickerField.text = viewModel.currentRadarType
            }
            radarTypePickerField.resignFirstResponder()
        case MUPTypePickerView:
            if MUPTypePickerField.text != viewModel.currentMUP {
                MUPTypePickerField.text = viewModel.currentMUP
            }
            MUPTypePickerField.resignFirstResponder()
        default:
            break
        }
    }
}

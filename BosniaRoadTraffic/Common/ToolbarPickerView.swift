//
//  ToolbarPickerView.swift
//  BosniaRoadTraffic
//
//  Created by Eldar Haseljic on 5/8/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import UIKit

protocol ToolbarPickerViewDelegate: AnyObject {
    func didTapDone(_ picker: ToolbarPickerView)
    func didTapCancel(_ picker: ToolbarPickerView)
}

class ToolbarPickerView: UIPickerView {
    
    var toolbar: UIToolbar?
    weak var toolbarDelegate: ToolbarPickerViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.barTintColor = AppColor.davysGrey.color
        toolBar.tintColor = .white
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: DONE, style: .done, target: self, action: #selector(self.doneTapped))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: CANCEL, style: .done, target: self, action: #selector(self.cancelTapped))
        
        toolBar.setItems([cancelButton, spaceButton, doneButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        self.toolbar = toolBar
    }
    
    @objc
    func doneTapped() { toolbarDelegate?.didTapDone(self) }
    
    @objc
    func cancelTapped() { toolbarDelegate?.didTapCancel(self) }
}

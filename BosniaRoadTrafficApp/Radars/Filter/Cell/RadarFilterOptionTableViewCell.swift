//
//  RadarFilterOptionTableViewCell.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/10/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit
import RxSwift

class RadarFilterOptionTableViewCell: UITableViewCell {

    @IBOutlet var optionName: UILabel!
    @IBOutlet var optionSwitch: UISwitch!
    var disposeBag = DisposeBag()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    func configureCell(radarOption: RadarTypeOption) {
        optionName.text = String(format: NUMBER_OF_TYPE, radarOption.type.rawValue, radarOption.numberOfElements)
        optionSwitch.isOn = radarOption.isOn
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    private func clear() {
        disposeBag = DisposeBag()
        optionName.text = String()
        optionSwitch.isOn = false
        optionSwitch.isEnabled = true
    }
}

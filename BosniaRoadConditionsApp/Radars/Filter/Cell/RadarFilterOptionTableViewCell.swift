//
//  RadarFilterOptionTableViewCell.swift
//  BosniaRoadConditionsApp
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
    
    func configureCell(radarType: RadarType, isSwitchEnabled: Bool, isSwitchOn: Bool) {
        optionName.text = radarType.rawValue
        optionSwitch.isOn = isSwitchEnabled ? isSwitchOn : false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    private func clear() {
        disposeBag = DisposeBag()
        optionName.text = String()
        optionSwitch.isOn = false
    }
}

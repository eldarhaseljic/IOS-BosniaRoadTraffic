//
//  RadarDetailsViewCell.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/7/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RadarDetailsViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var policeDepartmentLabel: UILabel!
    @IBOutlet var roadLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    func configure(for radar: Radar) {
        titleLabel.text = radar.title
        typeLabel.text = String(format: RADAR_TYPE, radar.radarType.rawValue)
        
        if let policeDepartmentName = radar.policeDepartmentName {
            policeDepartmentLabel.text = policeDepartmentName
            policeDepartmentLabel.isHidden = false
        }
        
        if let road = radar.road, road.isNotEmpty {
            roadLabel.text = String(format: STREET_NAME, road.withoutHtmlTags)
            roadLabel.isHidden = false
        }
        
        if let text = radar.text, text.isNotEmpty {
            descriptionLabel.text = text.withoutHtmlTags
            descriptionLabel.isHidden = false
        }
        
        if let validFrom = radar.validFrom, validFrom.isNotEmpty,
           let validTo = radar.validTo, validTo.isNotEmpty {
            durationLabel.text = String(format: RADAR_DURATION, validFrom, validTo)
            durationLabel.isHidden = false
        }
    }
    
    private func clear() {
        titleLabel.text = String()
        policeDepartmentLabel.text = String()
        policeDepartmentLabel.isHidden = true
        roadLabel.text = String()
        roadLabel.isHidden = true
        descriptionLabel.text = String()
        descriptionLabel.isHidden = true
        durationLabel.text = String()
        durationLabel.isHidden = true
        typeLabel.text = String()
    }
}

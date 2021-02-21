//
//  RoadConditionsDetailsViewCell.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class RoadConditionsDetailsViewCell: UITableViewCell {

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var typeLabel: UILabel!
    @IBOutlet var roadLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        clear()
    }
    
    func configure(for roadSign: RoadSign) {
        titleLabel.text = roadSign.title
        
        if let type = roadSign.categoryName {
            typeLabel.text = type
            typeLabel.isHidden = false
        }
        
        if let road = roadSign.road, road.isNotEmpty {
            roadLabel.text = String(format: STREET_NAME, road.withoutHtmlTags)
            roadLabel.isHidden = false
        }
        
        if let text = roadSign.text, text.isNotEmpty {
            descriptionLabel.text = text.withoutHtmlTags
            descriptionLabel.isHidden = false
        }
        
        if let validFrom = roadSign.validFrom, validFrom.isNotEmpty,
           let validTo = roadSign.validTo.isNotNilNotEmpty ? roadSign.validTo : NOT_DEFINED {
            durationLabel.text = String(format: ROAD_ROAD_CONDITIONS_DURATION, validFrom, validTo)
            durationLabel.isHidden = false
        }
    }
    
    private func clear() {
        titleLabel.text = String()
        typeLabel.text = String()
        typeLabel.isHidden = true
        roadLabel.text = String()
        roadLabel.isHidden = true
        descriptionLabel.text = String()
        descriptionLabel.isHidden = true
        durationLabel.text = String()
        durationLabel.isHidden = true
    }
}

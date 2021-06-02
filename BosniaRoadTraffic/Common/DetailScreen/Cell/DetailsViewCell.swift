//
//  DetailsViewCell.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/7/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import UIKit

class DetailsViewCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subtitleLabel: UILabel!
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
    
    func configure(for data: DetailsData) {
        titleLabel.text = data.title
       
        if let subtitle = data.subtitle {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        }
        
        if let road = data.road, road.isNotEmpty {
            roadLabel.text = String(format: STREET_NAME, road.withoutHtmlTags)
            roadLabel.isHidden = false
        }
        
        if let text = data.text, text.isNotEmpty {
            descriptionLabel.text = String(format: DETAILS_DESCRIPTION,
                                           text.withoutHtmlTags)
            descriptionLabel.isHidden = false
        }
        
        if let validFrom = data.validFrom, validFrom.isNotEmpty,
           let validTo = data.validTo.isNotNilNotEmpty ? data.validTo : NOT_DEFINED {
            durationLabel.text = String(format: DETAILS_DURATION, validFrom, validTo)
            durationLabel.isHidden = false
        }
        
        if let type = data.type, type.isNotEmpty {
            typeLabel.text = String(format: RADAR_TYPE, type)
            typeLabel.isHidden = false
        }
    }
    
    private func clear() {
        titleLabel.text = String()
        subtitleLabel.text = String()
        subtitleLabel.isHidden = true
        roadLabel.text = String()
        roadLabel.isHidden = true
        descriptionLabel.text = String()
        descriptionLabel.isHidden = true
        durationLabel.text = String()
        durationLabel.isHidden = true
        typeLabel.text = String()
        typeLabel.isHidden = true
    }
}

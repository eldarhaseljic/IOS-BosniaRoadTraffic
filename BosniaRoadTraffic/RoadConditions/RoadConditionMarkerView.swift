//
//  RoadConditionMarkerView.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 2/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import MapKit

class RoadConditionMarkerView: MKAnnotationView {
   
    override var annotation: MKAnnotation? {
        willSet {
            guard let roadCondition = newValue as? RoadCondition else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: .zero, y: -2)
            detailCalloutAccessoryView = getDescriptionLabel(text: roadCondition.subtitle)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            image = roadCondition.image
        }
    }
    
    func getDescriptionLabel(text: String?) -> UILabel {
        let detailLabel = UILabel()
        detailLabel.numberOfLines = 2
        detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = text
        return detailLabel
    }
}

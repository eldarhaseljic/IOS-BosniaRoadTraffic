//
//  RoadSignMarkerView.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 2/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation
import MapKit

class RoadSignMarkerView: MKAnnotationView {
   
    override var annotation: MKAnnotation? {
        willSet {
            guard let roadSign = newValue as? RoadSign else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: -2)
            detailCalloutAccessoryView = getDescriptionLabel(text: roadSign.subtitle)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            image = roadSign.image
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

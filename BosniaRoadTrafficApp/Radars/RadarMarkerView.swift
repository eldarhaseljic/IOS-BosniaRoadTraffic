//
//  RadarMarkerView.swift
//  BosniaRoadTrafficApp
//
//  Created by Eldar Haseljic on 2/5/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import MapKit
import UIKit

class RadarMarkerView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            guard let radar = newValue as? Radar else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: 0, y: 0)
            markerTintColor = radar.markerTintColor
            detailCalloutAccessoryView = getDescriptionLabel(text: radar.subtitle)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            glyphImage = radar.image
        }
    }
    
    func getDescriptionLabel(text: String?) -> UILabel {
        let detailLabel = UILabel()
        detailLabel.numberOfLines = .zero
        detailLabel.font = detailLabel.font.withSize(12)
        detailLabel.text = text
        return detailLabel
    }
}

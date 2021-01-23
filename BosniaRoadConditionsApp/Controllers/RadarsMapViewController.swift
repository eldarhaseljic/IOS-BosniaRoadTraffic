//
//  RadarsMapViewController.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/17/21.
//

import UIKit
import MapKit

class RadarsMapViewController: UIViewController {

    @IBOutlet var mapView: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupNavigationBar()
    }
    
    func setupNavigationBar() {
        title = BOSNIA_ROAD_CONDITIONS
        navigationItem.leftBarButtonItem = backButton
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension RadarsMapViewController {
    static func getViewController() -> RadarsMapViewController {
        return UIStoryboard(name: Constants.StoryboardIdentifiers.RadarsMapStoryboard, bundle: nil).instantiateViewController(withIdentifier: Constants.StoryboardIdentifiers.RadarsMapStoryboard) as! RadarsMapViewController
    }
}

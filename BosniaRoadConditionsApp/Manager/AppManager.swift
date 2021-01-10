//
//  AppManager.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/10/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation
import UIKit

class AppManager {
    static let shared = AppManager()
    
    func getRadars(completion: @escaping(Result<[Radar], RaradError>) -> Void) {
        let dataTask = URLSession.shared.dataTask(with: TrafficEndponins.radars.endpoint) { data, _ , _ in
            guard
                let jsonData = data
            else {
                completion(.failure(.noDataAvailable))
                return
            }
            
            do {
                let radarsResponse = try JSONDecoder().decode([Radar].self, from: jsonData)
                print(radarsResponse)
                completion(.success(radarsResponse))
            } catch {
                completion(.failure(.canNotProcessData))
            }
        }
        dataTask.resume()
    }
}

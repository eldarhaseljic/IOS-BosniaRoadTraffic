//
//  NetworkService.swift
//  BosniaRoadConditionsApp
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Fakultet Elektrotehnike Tuzla. All rights reserved.
//

import Foundation

enum RaradError: Error {
    case noDataAvailable
    case canNotProcessData
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    func request(_ urlPath: String, completion: @escaping (Result<Data, NSError>) -> Void) {
        guard let url = URL(string: urlPath) else {
            // Error message
            fatalError()
        }
        
        URLSession.shared.dataTask(with: url) { data, _ , error in
            if let error = error {
                completion(.failure(error as NSError))
            } else if let data = data {
                completion(.success(data))
            } else {
                // Error message
                fatalError()
            }
        }.resume()
    }
}

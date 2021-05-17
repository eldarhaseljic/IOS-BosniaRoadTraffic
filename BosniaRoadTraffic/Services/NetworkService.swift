//
//  NetworkService.swift
//  Bosnia Road Traffic 
//
//  Created by Eldar Haseljic on 1/16/21.
//  Copyright © 2021 Eldar Haseljic. All rights reserved.
//

import Foundation

enum CustomError: LocalizedError {
    case canNotProcessData
    case dataBaseError
    case internalError
    case requestError
    
    var errorDescription: String {
        switch self {
        case .dataBaseError:
            return DATABASE_ERROR
        case .canNotProcessData:
            return CAN_NOT_PROCESS_DATA
        case .internalError:
            return INTERNAL_ERROR
        case .requestError:
            return REQUEST_ERROR
        }
    }
}

final class NetworkService {
    
    static let shared = NetworkService()
    
    func request(_ urlPath: String, completion: @escaping(Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlPath) else {
            completion(.failure(CustomError.requestError))
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, _ , error in
            if let error = error {
                completion(.failure(error as NSError))
            } else if let data = data {
                completion(.success(data))
            } else {
                completion(.failure(CustomError.requestError))
            }
        }.resume()
    }
}

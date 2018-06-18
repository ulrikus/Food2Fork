//
//  FoodError.swift
//  Food2Fork
//
//  Created by Ulrik Utheim Sverdrup on 15.06.2018.
//  Copyright © 2018 Utheim Sverdrup, Ulrik. All rights reserved.
//

import Foundation

enum FoodError: Error {
    case urlError
    case responseError
    case statusCodeNot2XX(Int)
    case noData
    case couldNotParseToJSON(Data)
    
    var localizedDescription: String {
        switch self {
        case .urlError: return "Not valid URL."
        case .responseError: return "There was an error with the response."
        case .statusCodeNot2XX(let code): return "Your request returned a status code other than 2XX. Returned \(code)."
        case .noData: return "No data was returned by the request."
        case .couldNotParseToJSON(let data): return "Could not parse data to JSON:\n\(data)."
        }
    }
}

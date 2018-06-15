//
//  RecipesCoordinator.swift
//  Food2Fork
//
//  Created by Ulrik Utheim Sverdrup on 15.06.2018.
//  Copyright © 2018 Utheim Sverdrup, Ulrik. All rights reserved.
//

import Foundation

class RecipesCoordinator {
    
    let decoder = JSONDecoder()
    
    private func getRecipes(with parameters: [String: AnyObject], completionBlock block: @escaping (_ result: Recipe?, _ error: Error?) -> Void) {
        var parameters = parameters
        parameters[Constants.Food2ForkParameterKeys.APIKey] = Constants.Food2ForkParameterValues.APIKey as AnyObject
        
        // Create session and request
        let session = URLSession.shared
        let url = food2ForkURLFor(method: "", parameters)
        var request = URLRequest(url: url)
        request.httpMethod = Constants.Food2ForkMethods.Get
        
        // Make the request
        let task = session.dataTask(with: request) { (data, response, error) in
        
            guard error == nil else {
                block(nil, FoodError.requestError)
                return
            }
            
            if let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 {
                block(nil, FoodError.statusCodeNot2XX(statusCode))
                return
            }
            
            guard let data = data else {
                block(nil, FoodError.noData)
                return
            }
            
            do {
                let recipe = try self.decoder.decode(Recipe.self, from: data)
                block(recipe, nil)
            } catch {
                block(nil, FoodError.couldNotParseToJSON)
            }
        }
        task.resume()
    }
    
    private func food2ForkURLFor(method: String, _ parameters: [String: AnyObject]) -> URL {
        
        var components = URLComponents()
        components.scheme = Constants.Food2Fork.APIScheme
        components.host = Constants.Food2Fork.APIHost
        
        if method == Constants.Food2ForkMethods.Get {
            components.path = Constants.Food2Fork.APIPathGet
        } else if method == Constants.Food2ForkMethods.Search {
            components.path = Constants.Food2Fork.APIPathSearch
        }
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url!
    }
}

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
    
    // MARK: - Coordinator API
    
    func getRecipe(with recipeId: String, completionBlock: @escaping ((_ result: Recipe?, _ error: Error?) -> ())) {
        let parameters = [Constants.Food2ForkParameterKeys.RecipeId: recipeId as AnyObject]
        
        getRecipe(parameters: parameters) { (recipe, error) in
            performUIUpdatesOnMain {
                completionBlock(recipe, error)
            }
        }
    }
    
    func performSearch(with searchPhrase: String, completionBlock: @escaping ((_ result: ListRecipe?, _ error: Error?) -> ())) {
        let parameters = [Constants.Food2ForkParameterKeys.SearchQuery: searchPhrase as AnyObject]
        
        getRecipesList(parameters: parameters) { (recipeList, error) in
            performUIUpdatesOnMain {
                completionBlock(recipeList, error)
            }
        }
    }
    
    // MARK: - Network requests
    
    private func getRecipe(parameters: [String: AnyObject], completionBlock block: @escaping (_ result: Recipe?, _ error: Error?) -> Void) {
        
        let url = food2ForkURLFor(method: .get, parameters)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
        
            guard error == nil else {
                block(nil, error)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                block(nil, FoodError.statusCodeNot2XX(0))
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                block(nil, FoodError.statusCodeNot2XX(statusCode))
                return
            }
            
            guard let data = data else {
                block(nil, FoodError.noData)
                return
            }
            
            do {
                let recipeTopLayer = try self.decoder.decode(RecipeTopLayer.self, from: data)
                block(recipeTopLayer.recipe, nil)
            } catch {
                block(nil, FoodError.couldNotParseToJSON(data))
            }
        }
        task.resume()
    }
    
    private func getRecipesList(parameters: [String: AnyObject], completionBlock block: @escaping (_ result: ListRecipe?, _ error: Error?) -> Void) {
        
        let url = food2ForkURLFor(method: .search, parameters)
        let request = URLRequest(url: url)
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            guard error == nil else {
                block(nil, error)
                return
            }
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode else {
                block(nil, FoodError.statusCodeNot2XX(0))
                return
            }
            
            guard statusCode >= 200 && statusCode <= 299 else {
                block(nil, FoodError.statusCodeNot2XX(statusCode))
                return
            }
            
            guard let data = data else {
                block(nil, FoodError.noData)
                return
            }
            
            do {
                let recipesList = try self.decoder.decode(ListRecipe.self, from: data)
                block(recipesList, nil)
            } catch {
                block(nil, FoodError.couldNotParseToJSON(data))
            }
        }
        task.resume()
    }
    
    private func food2ForkURLFor(method: APIMethod, _ parameters: [String: AnyObject]) -> URL {
        var parameters = parameters
        parameters[Constants.Food2ForkParameterKeys.APIKey] = Constants.Food2ForkParameterValues.APIKey as AnyObject
        
        var components = URLComponents()
        components.scheme = Constants.Food2Fork.APIScheme
        components.host = Constants.Food2Fork.APIHost
        
        if method == .get {
            components.path = Constants.Food2Fork.APIPathGet
        } else if method == .search {
            components.path = Constants.Food2Fork.APIPathSearch
        }
        
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        return components.url! // TODO: Don't force unwrap
    }
}

//
//  RecipesProvider.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 24.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import Foundation

class RecipesProvider {
    static let sharedProvider = RecipesProvider()
    
    var lastSearchString: String?
    
    // MARK: Network request
    func getRecipeFromFood2ForkBySearch(searchPhrase: String, completionBlock: @escaping (([ListRecipe]) -> ())) {
        let parameters = [Constants.Food2ForkParameterKeys.SearchQuery: searchPhrase as AnyObject]
        let method = Constants.Food2ForkMethods.Search
        lastSearchString = searchPhrase
        
        let netwotkClient = NetworkClient()
        
        netwotkClient.taskForSEARCHMethod(method: method, parameters: parameters) { (result, error) in
            guard let result = result else {
                print("\(String(describing: error))")
                completionBlock([])
                return
            }
            
            let listRecipes = ListRecipe.createListReicpes(recipeDictionary: result)
            
            performUIUpdatesOnMain {
                completionBlock(listRecipes)
            }
        }
    }
}

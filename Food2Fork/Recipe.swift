//
//  Recipe.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import Foundation

struct ListRecipe2: Codable { // TODO (UUS): Remove `2`
    let count: Int
    let recipes: [Recipe]
}

struct RecipeTopLayer: Codable {
    let recipe: Recipe
}

struct Recipe: Codable {
    let publisher: String
    let food2forkUrl: URL
    let ingredients: [String]?
    let sourceUrl: String
    let recipeId: String
    let imageUrl: URL
    let socialRank: Double
    let publisherUrl: URL
    let title: String
    
    enum CodingKeys: String, CodingKey {
        case publisher
        case food2forkUrl = "f2f_url"
        case ingredients
        case sourceUrl = "source_url"
        case recipeId = "recipe_id"
        case imageUrl = "image_url"
        case socialRank = "social_rank"
        case publisherUrl = "publisher_url"
        case title
    }
}

struct ListRecipe {
    let recipeId: String
    let title: String
    let imageUrlString: String
    
    static func createListReicpes(recipeDictionary: [String: AnyObject]) -> [ListRecipe] {
        // GUARD: Is the "recipes" key in out result?
        guard let recipesArray = recipeDictionary[Constants.Food2ForkResponseKeys.Recipes] as? [[String: AnyObject]] else {
            print("Cannot find keys '\(Constants.Food2ForkResponseKeys.Recipes)' in \(recipeDictionary).")
            return []
        }
        
        if recipesArray.count == 0 {
            print("No recipes found. Search again.")
            return []
        } else {
            var tempArray = [ListRecipe]()
            for recipe in recipesArray {
                // GUARD: Does our image have a key for 'image_url'?
                guard let imageURLString = recipe[Constants.Food2ForkResponseKeys.ImageUrl] as? String else {
                    print("Cannot find key '\(Constants.Food2ForkResponseKeys.ImageUrl)'")
                    continue
                }
                guard let recipeId = recipe[Constants.Food2ForkResponseKeys.RecipeId] as? String else {
                    print("Cannot find key '\(Constants.Food2ForkParameterKeys.RecipeId)'")
                    continue
                }
                
                if let recipeTitle = recipe[Constants.Food2ForkResponseKeys.Title] as? String, recipeTitle != "" {
                    let image = ListRecipe(recipeId: recipeId, title: recipeTitle, imageUrlString: imageURLString)
                    tempArray.append(image)
                } else {
                    let image = ListRecipe(recipeId: recipeId, title: "(Untitled)", imageUrlString: imageURLString)
                    tempArray.append(image)
                }
            }
            return tempArray
        }
    }
}

struct DetailRecipe {
    let recipeId: String
    let title: String
    let imageUrlString: String
    let sourceUrlString: String
    let food2ForkUrlString: String
    let publisherName: String
    let publisherUrl: String
    let socialRank: Double
    let ingredients: [String]
    
    static func createDetailRecipe(recipeDictionary: [String: AnyObject]) -> DetailRecipe? {
        
        // GUARD: Is the "recipe" key in out result?
        guard let recipe = recipeDictionary[Constants.Food2ForkResponseKeys.Recipe] as? [String: AnyObject] else {
            print("Cannot find keys '\(Constants.Food2ForkResponseKeys.Recipe)' in \(recipeDictionary).")
            return nil
        }
        guard let imageURLString = recipe[Constants.Food2ForkResponseKeys.ImageUrl] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.ImageUrl)'")
            return nil
        }
        guard let recipeId = recipe[Constants.Food2ForkResponseKeys.RecipeId] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.RecipeId)'")
            return nil
        }
        guard let sourceUrlString = recipe[Constants.Food2ForkResponseKeys.SourceUrl] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.SourceUrl)'")
            return nil
        }
        guard let f2fUrlString = recipe[Constants.Food2ForkResponseKeys.F2FUrl] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.F2FUrl)'")
            return nil
        }
        guard let publisherName = recipe[Constants.Food2ForkResponseKeys.PublisherName] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.PublisherName)'")
            return nil
        }
        guard let publisherUrl = recipe[Constants.Food2ForkResponseKeys.PublisherUrl] as? String else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.PublisherUrl)'")
            return nil
        }
        guard let socialRank = recipe[Constants.Food2ForkResponseKeys.SocialRank] as? Double else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.SocialRank)'")
            return nil
        }
        guard let ingredients = recipe[Constants.Food2ForkResponseKeys.Ingredients] as? [String] else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.Ingredients)'")
            return nil
        }
        guard let title = recipe[Constants.Food2ForkResponseKeys.Title] as? String, title != "" else {
            print("Cannot find key '\(Constants.Food2ForkResponseKeys.Ingredients)'")
            return nil
        }
        
        return DetailRecipe(recipeId: recipeId, title: title, imageUrlString: imageURLString, sourceUrlString: sourceUrlString, food2ForkUrlString: f2fUrlString, publisherName: publisherName, publisherUrl: publisherUrl, socialRank: socialRank, ingredients: ingredients)
    }
}

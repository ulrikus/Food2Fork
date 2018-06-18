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

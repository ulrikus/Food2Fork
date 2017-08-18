//
//  Recipe.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import Foundation

struct ListRecipe {
    let recipeId: String
    let title: String
    let imageUrlString: String
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
}

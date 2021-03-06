//
//  Constants.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

struct Constants {
    
    // MARK: Food2Fork URL base
    struct Food2Fork {
        static let APIScheme = "http"
        static let APIHost = "food2fork.com"
        static let APIPath = "/api"
        static let APIPathSearch = "/api/search"
        static let APIPathGet = "/api/get"
        static let baseUrl = "https://food2fork.com/api/"
    }
    
    // MARK: Food2Fork Parameter Keys
    struct Food2ForkParameterKeys {
        static let APIKey = "key"
        static let Sort = "sort"            // (optional) How the results should be sorted
        static let Page = "page"            // (optional) Used to get additional results (search only)
        static let SearchQuery = "q"        // (optional) Search Query (Ingredients should be separated by commas). If this is omitted top rated recipes will be returned
        static let RecipeId = "rId"         // Id of desired recipe as returned by Search Query
    }
    
    // MARK: Food2Fork Parameter Values
    struct Food2ForkParameterValues {
        static let APIKey = "d9fd3789c0b440c594997be0647ee30c"
        static let SortByRating = "r"       // Rating based off of social media scores to determine the best recipes
        static let SortByTrending = "t"     // Trend score based on how quickly they are gaining popularity
    }
   
    // MARK: String Literals
    struct StringLiterals {
        static let SegueIdentifier = "detailViewSegue"
        static let Ingredients = "Ingredients"
        static let PublisherName = "Name of the Publisher"
        static let PublisherUrl = "Base URL of the publisher"
        static let SocialRank = "Social Ranking"
        static let F2FUrl = "URL of the recipe on Food2Fork.com"
    }
}

// MARK: - Network Methods

enum APIMethod: String {
    case get = "GET"
    case search = "SEARCH"
}

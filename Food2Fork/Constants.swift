//
//  Constants.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 17.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

struct Constants {
    
    // MARK: Food2Fork
    struct Food2Fork {
        static let APIScheme = "https"
        static let APIHost = "food2fork.com"
        static let APIPath = "/api"
    }
    
    // MARK: Food2Fork Parameter Keys
    struct Food2ForkParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
    }
    
    // MARK: Food2Fork Parameter Values
    struct Food2ForkParameterValues {
        static let SearchMethod = ""
        static let APIKey = "c1a88056f7f2205fd9b24ed67c428cbb"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" // 1 means "yes"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Food2Fork Response Keys
    struct Food2ForkResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
}

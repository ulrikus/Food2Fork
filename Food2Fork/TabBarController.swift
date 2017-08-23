//
//  TabBarController.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 23.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.barTintColor = .foodBlack
        tabBar.backgroundColor = .foodBlack
        tabBar.tintColor = .foodGreen
    }
    
}

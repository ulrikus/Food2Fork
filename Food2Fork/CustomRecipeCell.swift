//
//  CustomRecipeCell.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 16.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class CustomRecipeCell: UITableViewCell {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        fadeBottom(of: recipeImage)
    }
    
    func fadeBottom(of imageView: UIImageView) {
        let gradient = CAGradientLayer()
        let endColor = UIColor(white: 0, alpha: 0.8)
        
        gradient.frame = imageView.bounds
        gradient.colors = [UIColor.clear.cgColor, endColor.cgColor]
        gradient.locations = [0.7, 1]
        
        imageView.layer.insertSublayer(gradient, at: 0)
    }
}

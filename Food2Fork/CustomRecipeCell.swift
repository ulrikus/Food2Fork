//
//  CustomRecipeCell.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 16.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class CustomRecipeCell: UICollectionViewCell {
    @IBOutlet weak var recipeImage: UIImageView!
    @IBOutlet weak var recipeTitleLabel: UILabel!
    private var gradientLayer: CAGradientLayer?
    
    override func awakeFromNib() {
        super.awakeFromNib()
            
        fadeBottom(of: recipeImage)
        
        layer.cornerRadius = 8
        
        addObserver(self, forKeyPath: "recipeImage.bounds", options: .new, context: nil)
    }
    
    deinit {
        removeObserver(self, forKeyPath: "recipeImage.bounds")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "recipeImage.bounds") {
            updategradientLayerFrame()
            return
        }
        super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
    }
    
    func fadeBottom(of imageView: UIImageView) {
        let gradient = CAGradientLayer()
        let endColor = UIColor(white: 0, alpha: 0.8)
        
        gradient.frame = imageView.bounds
        gradient.colors = [UIColor.clear.cgColor, endColor.cgColor]
        gradient.locations = [0.7, 1]
        
        imageView.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    func updategradientLayerFrame() {
        gradientLayer?.removeFromSuperlayer()
        fadeBottom(of: recipeImage)
    }
}

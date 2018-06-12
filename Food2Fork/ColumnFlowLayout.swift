//
//  ColumnFlowLayout.swift
//  Food2Fork
//
//  Created by Ulrik Utheim Sverdrup on 12.06.2018.
//  Copyright © 2018 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class ColumnFlowLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        
        guard let collectionView = collectionView else { return }
        let horizontalLayoutMargin = (collectionView.layoutMargins.right + collectionView.layoutMargins.left) / 2
        
        let availableWidth = collectionView.bounds.insetBy(dx: horizontalLayoutMargin, dy: collectionView.layoutMargins.top).width
        
        let minColumnWidth: CGFloat = 300
        let maxNumberOfColumns = Int(availableWidth / minColumnWidth)
        let cellWidth = (availableWidth / CGFloat(maxNumberOfColumns)).rounded(.down)
        
        itemSize = CGSize(width: cellWidth, height: 120)
        
        sectionInset = UIEdgeInsets(top: minimumInteritemSpacing, left: 0, bottom: 0, right: 0)
        sectionInsetReference = .fromSafeArea
    }
}

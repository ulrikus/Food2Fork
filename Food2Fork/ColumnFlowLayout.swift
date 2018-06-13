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
        
        minimumInteritemSpacing = 4
        
        guard let collectionView = collectionView else { return }
        let horizontalLayoutMargin = (collectionView.layoutMargins.right + collectionView.layoutMargins.left) / 2 + minimumInteritemSpacing
        
        let availableWidth = collectionView.bounds.insetBy(dx: horizontalLayoutMargin, dy: collectionView.layoutMargins.top).width
        
        var minColumnWidth: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 340
            } else {
                return 300
            }
        }
        let maxNumberOfColumns = Int((availableWidth + horizontalLayoutMargin) / minColumnWidth)
        let cellWidth = (availableWidth / CGFloat(maxNumberOfColumns)).rounded(.down)
        
        var cellHeight: CGFloat {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return 200
            } else {
                return 150
            }
        }
        itemSize = CGSize(width: cellWidth, height: cellHeight)
        sectionInset = UIEdgeInsets(top: minimumInteritemSpacing, left: minimumInteritemSpacing, bottom: 0, right: minimumInteritemSpacing)
        sectionInsetReference = .fromSafeArea
    }
}

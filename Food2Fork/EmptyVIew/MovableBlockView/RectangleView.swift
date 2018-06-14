//
//  RectangleView.swift
//  Food2Fork
//
//  Created by Ulrik Utheim Sverdrup on 16.01.2018.
//  Copyright © 2018 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class RectangleView: UIView, AttachableView {
    
    var attach: UIAttachmentBehavior?
    private let cornerRadius: CGFloat = 4.0
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .foodGreen
        layer.cornerRadius = cornerRadius
    }
    
    // MARK: - Override methods
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .rectangle
    }
}

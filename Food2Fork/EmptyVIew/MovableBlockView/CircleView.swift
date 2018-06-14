//
//  CircleView.swift
//  Food2Fork
//
//  Created by Ulrik Utheim Sverdrup on 16.01.2018.
//  Copyright © 2018 Utheim Sverdrup, Ulrik. All rights reserved.
//

import UIKit

class CircleView: UIView, AttachableView {
    
    var attach: UIAttachmentBehavior?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .lightGray
        layer.cornerRadius = frame.width / 2
        clipsToBounds = true
    }
    
    // MARK: - Override methods
    override var collisionBoundsType: UIDynamicItemCollisionBoundsType {
        return .ellipse
    }
}

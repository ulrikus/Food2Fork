//
//  EmptySearchView.swift
//  Food2Fork
//
//  Created by Utheim Sverdrup, Ulrik on 21.08.2017.
//  Copyright © 2017 Utheim Sverdrup, Ulrik. All rights reserved.
//

import CoreMotion
import UIKit

public class EmptyView: UIView {
    
    // MARK: - Internal properties
    
    private let sizeOfTriangle = CGSize(width: 90, height: 90)
    private let sizeOfCircle = CGSize(width: 75, height: 75)
    private let sizeOfRectangle = CGSize(width: 100, height: 100)
    
    private var hasLayedOut = false
    private var shouldRearrangeBlocks = false
    
    private lazy var triangle: TriangleView = {
        let view = TriangleView(frame: CGRect(x: 0, y: 0, width: sizeOfTriangle.width, height: sizeOfTriangle.height))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var circle: CircleView = {
        let view = CircleView(frame: CGRect(x: 0, y: 0, width: sizeOfCircle.width, height: sizeOfCircle.height))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var rectangle: RectangleView = {
        let view = RectangleView(frame: CGRect(x: 0, y: 0, width: sizeOfRectangle.width, height: sizeOfRectangle.height))
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        view.addGestureRecognizer(pan)
        return view
    }()
    
    private lazy var animator: UIDynamicAnimator = {
        let animator = UIDynamicAnimator(referenceView: self)
        return animator
    }()
    
    private lazy var gravity: UIGravityBehavior = {
        let gravity = UIGravityBehavior(items: allShapes)
        gravity.gravityDirection = CGVector(dx: 0, dy: 1.0)
        return gravity
    }()
    
    private lazy var collision: UICollisionBehavior = {
        let collision = UICollisionBehavior(items: allShapes)
        collision.setTranslatesReferenceBoundsIntoBoundary(with: UIEdgeInsetsMake(-10000, 0, 0, 0))
        return collision
    }()
    
    private lazy var itemBehavior: UIDynamicItemBehavior = {
        let itemBehavior = UIDynamicItemBehavior(items: allShapes)
        itemBehavior.elasticity = 0.5
        itemBehavior.friction = 0.3
        itemBehavior.angularResistance = 0.1
        itemBehavior.resistance = 0.1
        itemBehavior.density = 0.75
        return itemBehavior
    }()
    
    private var rectangleSnapBehavior: UISnapBehavior?
    private var triangleSnapBehavior: UISnapBehavior?
    private var circleSnapBehavior: UISnapBehavior?
    
    private lazy var motionManager: CMMotionManager = {
        let motionManager = CMMotionManager()
        motionManager.accelerometerUpdateInterval = 1 / 60
        return motionManager
    }()
    
    private lazy var motionQueue = OperationQueue()
    
    private lazy var allShapes: [UIView] = {
        return [rectangle, triangle, circle]
    }()
    
    // MARK: - Setup
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addSubview(rectangle)
        addSubview(triangle)
        addSubview(circle)
        
        NotificationCenter.default.addObserver(self, selector: #selector(viewDidRotate), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        getAccelerometerData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        // We only want to lay out once
        guard hasLayedOut == false else { return }
        
        let slice = frame.width / 8
        
        // We reposition the shapes after the EmptyView itself has layed out its frame.
        // At this point we will have its size even if we use constraints to lay it out.
        triangle.center = CGPoint(x: slice * 2, y: frame.height - (sizeOfTriangle.height / 2))
        circle.center = CGPoint(x: slice * 4, y: frame.height - (sizeOfCircle.height / 2))
        rectangle.center = CGPoint(x: slice * 6, y: frame.height - (sizeOfRectangle.height / 2))
        
        // We add the behaviors after laying out the subviews to avoid issues with initial positions of the shapes
        animator.addBehavior(gravity)
        animator.addBehavior(collision)
        animator.addBehavior(itemBehavior)
        
        hasLayedOut = true
    }
    
    // MARK: - Actions
    
    @objc func panAction(sender: UIPanGestureRecognizer) {
        guard let objectView = sender.view, var attachable = objectView as? AttachableView else {
            return
        }
        
        let location = sender.location(in: self)
        let touchLocation = sender.location(in: objectView)
        let touchOffset = UIOffsetMake(touchLocation.x - objectView.bounds.midX, touchLocation.y - objectView.bounds.midY)
        
        if sender.state == .began {
            let newAttach = UIAttachmentBehavior(item: objectView, offsetFromCenter: touchOffset, attachedToAnchor: location)
            animator.addBehavior(newAttach)
            attachable.attach = newAttach
        } else if sender.state == .changed {
            if let attach = attachable.attach {
                attach.anchorPoint = location
            }
        } else if sender.state == .ended {
            if let attach = attachable.attach {
                animator.removeBehavior(attach)
                itemBehavior.addLinearVelocity(sender.velocity(in: self), for: objectView)
            }
        }
    }
    
    @objc private func viewDidRotate() {
        if hasLayedOut, shouldRearrangeBlocks {
            setAllSnapBehaviors(to: center)
            
            let delayTime = 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) { [weak self] in
                self?.removeAllSnapBehaviors()
            }
        }
        shouldRearrangeBlocks = true
    }
    
    // MARK: - SnapBehavior methods
    
    @objc private func userHasLongPressed(gesture: UILongPressGestureRecognizer) {
        if rectangleSnapBehavior != nil, triangleSnapBehavior != nil, circleSnapBehavior != nil {
            removeAllSnapBehaviors()
        }
        let touchPosition = gesture.location(in: self)
        setAllSnapBehaviors(to: touchPosition)
        
        if gesture.state == .ended {
            removeAllSnapBehaviors()
        }
    }
    
    private func setAllSnapBehaviors(to point: CGPoint) {
        rectangleSnapBehavior = UISnapBehavior(item: rectangle, snapTo: point)
        triangleSnapBehavior = UISnapBehavior(item: triangle, snapTo: point)
        circleSnapBehavior = UISnapBehavior(item: circle, snapTo: point)
        
        addAllSnapBehaviors()
    }
    
    private func addAllSnapBehaviors() {
        if let rectangleSnapBehavior = rectangleSnapBehavior {
            animator.addBehavior(rectangleSnapBehavior)
        }
        if let triangleSnapBehavior = triangleSnapBehavior {
            animator.addBehavior(triangleSnapBehavior)
        }
        if let circleSnapBehavior = circleSnapBehavior {
            animator.addBehavior(circleSnapBehavior)
        }
    }
    
    private func removeAllSnapBehaviors() {
        if let rectangleSnapBehavior = rectangleSnapBehavior {
            animator.removeBehavior(rectangleSnapBehavior)
        }
        if let triangleSnapBehavior = triangleSnapBehavior {
            animator.removeBehavior(triangleSnapBehavior)
        }
        if let circleSnapBehavior = circleSnapBehavior {
            animator.removeBehavior(circleSnapBehavior)
        }
    }
    
    // MARK: 3D-touch
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if traitCollection.forceTouchCapability == .available {
                let normalizedTouch = touch.force / touch.maximumPossibleForce
                
                if normalizedTouch >= 0.95 {
                    if rectangleSnapBehavior != nil, triangleSnapBehavior != nil, circleSnapBehavior != nil {
                        removeAllSnapBehaviors()
                    }
                    let touchPosition = touch.location(in: self)
                    setAllSnapBehaviors(to: touchPosition)
                }
            } else {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(userHasLongPressed))
                longPressGesture.minimumPressDuration = 2.5
                addGestureRecognizer(longPressGesture)
            }
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        removeAllSnapBehaviors()
    }

    // MARK: - Accelerometer calculations
    
    func getAccelerometerData() {
        motionManager.startAccelerometerUpdates()
        motionManager.startDeviceMotionUpdates(to: motionQueue, withHandler: { motion, error in
            if error != nil {
                return
            }
            
            guard let motion = motion else {
                return
            }
            
            let gravity: CMAcceleration = motion.gravity
            var vector = CGVector(dx: CGFloat(gravity.x), dy: CGFloat(gravity.y))
            
            DispatchQueue.main.async {
                // Correct for orientation
                let orientation = UIApplication.shared.statusBarOrientation
                
                switch orientation {
                case .portrait:
                    vector.dy *= -1
                case .landscapeLeft:
                    vector.dx = CGFloat(gravity.y)
                    vector.dy = CGFloat(gravity.x)
                case .landscapeRight:
                    vector.dx = CGFloat(-gravity.y)
                    vector.dy = CGFloat(-gravity.x)
                default: break
                }
                
                self.gravity.gravityDirection = vector
            }
        })
    }
}

//
//  GraphView.swift
//  GraphingCalculator
//
//  Created by Jordan Doczy on 11/3/15.
//  Copyright © 2015 Jordan Doczy. All rights reserved.
//

//for testing: https://www.desmos.com/calculator


import UIKit
import QuartzCore
import SpriteKit

protocol GraphViewDataSource: class{
    func yForX(x:CGFloat) -> CGFloat?
}

@IBDesignable
class GraphView : UIView {
    
    struct GestureRecognizer{
        static let Scale = "scale"
        static let Pan = "pan"
        static let ResetOrigin = "resetOrigin"
    }
    
    
    private var axis = AxesDrawer(color: UIColor.darkGrayColor())
    weak var dataSource:GraphViewDataSource?

    @IBInspectable
    var scale: CGFloat = 50 { didSet { setNeedsDisplay() } }

    var lineWidth: CGFloat = 1.0
    
    var origin : CGPoint? {
        didSet{
            setNeedsDisplay()
        }
    }
    
    
    func resetOrigin(){
        origin = CGPoint(x: bounds.width/2, y: bounds.height/2)
    }
    
    func pan(gesture: UIPanGestureRecognizer){
        if gesture.state == .Changed{
            let translation = gesture.translationInView(self)
            if origin != nil {
                origin = CGPoint(x: origin!.x + translation.x, y: origin!.y + translation.y)
            }
            gesture.setTranslation(CGPointZero, inView: self)
        }
    }
    
    func scale(gesture: UIPinchGestureRecognizer){
        if gesture.state == .Changed{
            scale /= gesture.scale
            gesture.scale = 1
        }
    }

    
    override var bounds : CGRect {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var path = UIBezierPath()
    var point = CGPoint()
    
    var position:CGFloat = 0 {
        didSet{
            point.x = CGFloat(position)
            if let y = getYForX(point.x){
                point.y = y
                path.addLineToPoint(point)
                path.moveToPoint(point)
            }
        }
    }
    
    let shapeLayer = CAShapeLayer()


    override func drawRect(rect: CGRect) {

        shapeLayer.removeFromSuperlayer()
        path.removeAllPoints()
        resetOrigin()
        
        axis.contentScaleFactor = contentScaleFactor
        axis.drawAxesInRect(bounds, origin: origin!, pointsPerUnit: scale)
        
        let x:CGFloat = 0;
        let y:CGFloat = getYForX(x) ?? origin!.y
        
        point.x = x
        point.y = y
        path.moveToPoint(point)

        for x in 0...Int(bounds.width) {
            position = CGFloat(x)
        }
        
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.duration = 2.8
        animation.fromValue = 0
        animation.toValue = 1

        shapeLayer.addAnimation(animation, forKey: "strokeEndAnimation")
        shapeLayer.lineWidth = 1
        shapeLayer.strokeColor = UIColor.darkGrayColor().CGColor
        shapeLayer.strokeStart = 0
        shapeLayer.strokeEnd = 1
        shapeLayer.path = path.CGPath

        layer.addSublayer(shapeLayer)
       
        
    }
    
    private func getYForX(x:CGFloat) -> CGFloat?{
        
        if let y = dataSource?.yForX((x-origin!.x)/scale) {
            if y.isNormal || y.isZero {
                return (-y*scale) + origin!.y
            }
        }
        return nil
    }
    
    
    private func getPath(start start:CGPoint,end:CGPoint) -> UIBezierPath {
        let path = UIBezierPath()
        path.moveToPoint(start)
        path.addLineToPoint(end)
        path.lineWidth = 1.0
        return path
    }

    
    
}

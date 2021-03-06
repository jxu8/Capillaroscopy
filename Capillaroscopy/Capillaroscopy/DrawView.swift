//
//  DrawView.swift
//  Capillaroscopy
//
//  Created by Xu, James (NIH/NIBIB) [F] on 6/29/17.
//  Copyright © 2017 Xu, James (NIH/NIBIB) [F]. All rights reserved.
//

import UIKit

class DrawView: UIView {
    
    var coordinates = [CGPoint]()
    //coordinatesTracker is used for drawing the line since only two points can be considered at a time
    var coordinatesTracker = [CGPoint]()
    var currentLine: Line?
    var finishedLines = [Line]()
    
    //defining the function that is called to draw the actual line
    func stroke (_ line: Line){
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineCapStyle = .round
        path.move(to: line.begin)
        path.addLine(to: line.end)
        path.stroke()
        
        let endCircle = UIBezierPath(arcCenter: CGPoint(x:line.end.x, y:line.end.y), radius: CGFloat(1), startAngle: CGFloat(0), endAngle: CGFloat(M_PI * 2), clockwise: true)
        let endCircleLayer = CAShapeLayer()
        endCircleLayer.path = endCircle.cgPath
        endCircleLayer.fillColor = UIColor.blue.cgColor
        endCircleLayer.strokeColor = UIColor.blue.cgColor
        endCircleLayer.lineWidth = 1.0
        self.layer.addSublayer(endCircleLayer)
    }
    
    override func draw (_ rect: CGRect){
        let lineColor = UIColor.init(red: 0.0, green: 0.0, blue: 1, alpha: 0.5)
        lineColor.setStroke()
        for line in finishedLines{
            stroke(line)
        }
    }
    
    override func touchesBegan (_ touches: Set<UITouch>, with event: UIEvent?){
        let touch = touches.first!
        
        //Get location of the touch in view's coordinate system
        let location = touch.location(in: self)
        coordinates.append(location)
        coordinatesTracker.append(location)
        
        //draw the line only after first two points have been selected
        if coordinatesTracker.count == 2 {
            currentLine = Line (begin: coordinatesTracker[0], end: coordinatesTracker[1])
            finishedLines.append(currentLine!)
            setNeedsDisplay()
            currentLine = nil
            coordinatesTracker.remove(at:0)
        }
    }
    
    func resetDrawView(){
        coordinates.removeAll()
        coordinatesTracker.removeAll()
        finishedLines.removeAll()
        self.layer.sublayers = nil
        setNeedsDisplay()
    }
}



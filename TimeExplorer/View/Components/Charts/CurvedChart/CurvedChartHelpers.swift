//
//  File.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 17/06/2021.
//

import Foundation
import UIKit
import SwiftUI


extension Path{
    
    static func drawCurvedChart(dataPoints:[Float],step:CGPoint) -> Path{
        var path = Path()
        if dataPoints.count < 2 {return path}
        let offset = dataPoints.min() ?? 0
        let pathDataPoints = dataPoints.map({CGFloat($0 - offset)})
        
        
        var p1 = CGPoint(x: 0, y: pathDataPoints[0] * step.y)
        path.move(to: p1)
        for idx in 1..<pathDataPoints.count{
            let data = pathDataPoints[idx]
            let p2 = CGPoint(x: step.x * CGFloat(idx), y: step.y * data)
            let midPoint = CGPoint.midPoint(p1: p1, p2: p2)
            path.addQuadCurve(to: midPoint, control: .controlPointForPoints(p1: midPoint, p2: p1))
            path.addQuadCurve(to: p2, control: .controlPointForPoints(p1: midPoint, p2: p2))
            p1 = p2
        }
        return  path
    }
}



extension CGPoint{

    static func midPoint(p1:CGPoint,p2:CGPoint) -> CGPoint{
        return .init(x: (p2.x + p1.x) * 0.5, y: (p2.y + p1.y) * 0.5)
    }
    
    static func controlPointForPoints(p1:CGPoint, p2:CGPoint) -> CGPoint {
        var controlPoint = CGPoint.midPoint(p1:p1, p2:p2)
        let diffY = abs(p2.y - controlPoint.y)
        
        if (p1.y < p2.y){
            controlPoint.y += diffY
        } else if (p1.y > p2.y) {
            controlPoint.y -= diffY
        }
        return controlPoint
    }
}

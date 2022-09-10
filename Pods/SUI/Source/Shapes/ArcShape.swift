//
//  ArcShape.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import SwiftUI
import SwiftUI

public struct ArcShape: Shape {
	let pct: CGFloat
	let style: StrokeStyle
	
	public init(pct: CGFloat,
				style: StrokeStyle) {
		self.pct  = pct
		self.style = style
	}
	
	public func path(in rect: CGRect) -> Path {
		
		var p = Path()
		
		p.addArc(center: .init(x: rect.width.half, y: rect.height.half),
				 radius: (max(rect.width, rect.height) + style.lineWidth).half,
				 startAngle: .init(degrees: 0),
				 endAngle: .init(degrees: pct * 360), clockwise: false)
		
		return p.strokedPath(style)
	}
}


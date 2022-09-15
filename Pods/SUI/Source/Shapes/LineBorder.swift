//
//  LineBorder.swift
//  SUI
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI

struct LineBorder: Shape {
	
	var pct: CGFloat
	let lineWidth: CGFloat
	
	public init(pct: CGFloat, lineWidth: CGFloat) {
		self.pct = pct
		self.lineWidth = lineWidth
	}
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		
		path.move(to: rect.origin)
		switch pct {
			case 0..<0.25:
				path.addLine(to: .init(x: rect.maxX * (0...0.25).normalize(pct), y: rect.minY))
			case 0.25..<0.5:
				path.addLine(to: .init(x: rect.maxX, y: rect.minY))
				path.addLine(to: .init(x: rect.maxX, y: rect.maxY * (0.25...0.5).normalize(pct)))
			case 0.5..<0.75:
				path.addLine(to: .init(x: rect.maxX, y: rect.minY))
				path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
				path.addLine(to: .init(x: rect.maxX * (1 - (0.5...0.75).normalize(pct)), y: rect.maxY))
			case 0.75...1:
				path.addLine(to: .init(x: rect.maxX, y: rect.minY))
				path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
				path.addLine(to: .init(x: rect.minX, y: rect.maxY))
				path.addLine(to: .init(x: rect.minX, y: rect.maxY * (1 - (0.75...1).normalize(pct))))
			default:
				path.move(to: rect.origin)
				path.addLine(to: .init(x: rect.maxX, y: rect.minY))
				path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
				path.addLine(to: .init(x: rect.minX, y: rect.maxY))
				path.addLine(to: .init(x: rect.minX, y: rect.minY))
				path.closeSubpath()
		}
		
		return path.strokedPath(.init(lineWidth: lineWidth, lineCap: .round))
	}
	
}

//
//  LineBorder.swift
//  SUI
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI

fileprivate extension CGPoint {

	static func * (lhs: CGPoint, rhs: CGFloat) -> CGPoint {
		.init(x: lhs.x * rhs, y: lhs.y * rhs)
	}

}

fileprivate extension CGSize {

	static func * (lhs: CGSize, rhs: CGFloat) -> CGSize {
		.init(width: lhs.width * rhs, height: lhs.height * rhs)
	}

}

struct LineBorder: Shape {
	
	var pct: CGFloat
	let lineWidth: CGFloat
	let cornerRadius: CGFloat
	
	public init(pct: CGFloat, lineWidth: CGFloat, cornerRadius: CGFloat) {
		self.pct = pct
		self.lineWidth = lineWidth
		self.cornerRadius = cornerRadius
	}
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: .init(x: rect.minX + cornerRadius, y: rect.minY))
		switch pct {
		case 0..<0.25:
			let percent = (0...0.23).normalize(pct).boundedTo()
			path.addLine(to: .init(x: (rect.maxX - cornerRadius) * percent + cornerRadius * (1 - percent), y: rect.minY))
			if pct >= 0.23 {
				path.addCurve(to: .init(x: rect.maxX, y: (rect.minY + cornerRadius)),
							  control1: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.minY),
							  control2: .init(x: rect.maxX, y: rect.minY + cornerRadius * 0.25))
			}
		case 0.25..<0.5:
			path.addLine(to: .init(x: rect.maxX - cornerRadius, y: rect.minY))
			path.addCurve(to: .init(x: rect.maxX, y: (rect.minY + cornerRadius)),
						  control1: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.minY),
						  control2: .init(x: rect.maxX, y: rect.minY + cornerRadius * 0.25))
			let percent = (0.25...0.48).normalize(pct).boundedTo()
			path.addLine(to: .init(x: rect.maxX, y: cornerRadius + (rect.maxY - 2 * cornerRadius) * percent))
			if pct >= 0.48 {
				path.addCurve(to: .init(x: (rect.maxX - cornerRadius), y: rect.maxY),
							  control1: .init(x: rect.maxX, y: rect.maxY - cornerRadius * 0.25),
							  control2: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.maxY))
			}
		case 0.5..<0.75:
			path.addLine(to: .init(x: rect.maxX - cornerRadius, y: rect.minY))
			path.addCurve(to: .init(x: rect.maxX, y: (rect.minY + cornerRadius)),
						  control1: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.minY),
						  control2: .init(x: rect.maxX, y: rect.minY + cornerRadius * 0.25))
			path.addLine(to: .init(x: rect.maxX, y: rect.maxY - cornerRadius))
			path.addCurve(to: .init(x: (rect.maxX - cornerRadius), y: rect.maxY),
						  control1: .init(x: rect.maxX, y: rect.maxY - cornerRadius * 0.25),
						  control2: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.maxY))
			let percent: CGFloat = (0.5...0.74).normalize(pct).boundedTo()
			path.addLine(to: .init(x: (rect.maxX - cornerRadius) * (1 - percent) + cornerRadius * percent, y: rect.maxY))
			if pct == 0.74 {
				path.addCurve(to: .init(x: rect.minX , y: (rect.maxY -  cornerRadius)),
							  control1: .init(x: rect.minX + cornerRadius * 0.25, y: rect.maxY),
							  control2: .init(x: rect.minX, y: rect.maxY - cornerRadius * 0.75))
			}
		case 0.75...1:
			path.addLine(to: .init(x: rect.maxX - cornerRadius, y: rect.minY))
			path.addCurve(to: .init(x: rect.maxX, y: (rect.minY + cornerRadius)),
						  control1: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.minY),
						  control2: .init(x: rect.maxX, y: rect.minY + cornerRadius * 0.25))
			path.addLine(to: .init(x: rect.maxX, y: rect.maxY - cornerRadius))
			path.addCurve(to: .init(x: (rect.maxX - cornerRadius), y: rect.maxY),
						  control1: .init(x: rect.maxX, y: rect.maxY - cornerRadius * 0.25),
						  control2: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.maxY))
			path.addLine(to: .init(x: rect.minX + cornerRadius , y: rect.maxY))
			path.addCurve(to: .init(x: rect.minX , y: (rect.maxY -  cornerRadius)),
						  control1: .init(x: rect.minX + cornerRadius * 0.25, y: rect.maxY),
						  control2: .init(x: rect.minX, y: rect.maxY - cornerRadius * 0.75))
			let percent: CGFloat = (0.75...0.99).normalize(pct).boundedTo()
			path.addLine(to: .init(x: rect.minX, y: (rect.maxY - cornerRadius) * (1 - percent) + cornerRadius * percent))
			if pct >= 1 {
				path.addCurve(to: .init(x: rect.minX + cornerRadius , y: rect.minY),
							  control1: .init(x: rect.minX, y: rect.minY + cornerRadius * 0.25),
							  control2: .init(x: rect.minX + cornerRadius * 0.75, y: rect.minY))
			}
			
		default:
			path.addLine(to: .init(x: rect.maxX - cornerRadius, y: rect.minY))
			path.addCurve(to: .init(x: rect.maxX, y: (rect.minY + cornerRadius)),
						  control1: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.minY),
						  control2: .init(x: rect.maxX, y: rect.minY + cornerRadius * 0.25))
			path.addLine(to: .init(x: rect.maxX, y: rect.maxY - cornerRadius))
			path.addCurve(to: .init(x: (rect.maxX - cornerRadius), y: rect.maxY),
						  control1: .init(x: rect.maxX, y: rect.maxY - cornerRadius * 0.25),
						  control2: .init(x: rect.maxX - cornerRadius * 0.75, y: rect.maxY))
			path.addLine(to: .init(x: rect.minX + cornerRadius , y: rect.maxY))
			path.addCurve(to: .init(x: rect.minX , y: (rect.maxY -  cornerRadius)),
						  control1: .init(x: rect.minX + cornerRadius * 0.25, y: rect.maxY),
						  control2: .init(x: rect.minX, y: rect.maxY - cornerRadius * 0.75))
			path.addLine(to: .init(x: rect.minX, y: rect.minY + cornerRadius))
			path.addCurve(to: .init(x: rect.minX + cornerRadius , y: rect.minY),
						  control1: .init(x: rect.minX, y: rect.minY + cornerRadius * 0.25),
						  control2: .init(x: rect.minX + cornerRadius * 0.75, y: rect.minY))
		}
		
		return path.strokedPath(.init(lineWidth: lineWidth, lineCap: .round))
	}
	
}

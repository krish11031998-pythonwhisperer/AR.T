//
//  CustomizableRoundBorder.swift
//  SUI
//
//  Created by Krishna Venkatramani on 17/09/2022.
//

import SwiftUI

struct CustomizableBorder: Shape {
	
	let size: CGSize
	let isEditting: Bool
	let cornerRadius: CGFloat
	let inset: CGFloat
	
	init(size: CGSize, cornerRadius: CGFloat, inset: CGFloat, isEditting: Bool) {
		self.size = size
		self.cornerRadius = cornerRadius
		self.isEditting = isEditting
		self.inset = inset
	}
	
	var cutOff: CGFloat {
		isEditting ? size.width : 0
	}
	
	func path(in rect: CGRect) -> Path {
		var path = Path()
		path.move(to: .init(x: rect.minX + inset, y: rect.minY))
		path.addCurve(to: .init(x: rect.minX, y: rect.minY + cornerRadius),
					  control1: .init(x: rect.minX, y: rect.minY),
					  control2: .init(x: rect.minX, y: rect.minY))
		path.addLine(to: .init(x: rect.minX, y: rect.maxY - cornerRadius))
		path.addCurve(to: .init(x: rect.minX + cornerRadius, y: rect.maxY),
					  control1: .init(x: rect.minX, y: rect.maxY),
					  control2: .init(x: rect.minX, y: rect.maxY))
		path.addLine(to: .init(x: rect.maxX - cornerRadius, y: rect.maxY))
		path.addCurve(to: .init(x: rect.maxX, y: rect.maxY - cornerRadius),
					  control1: .init(x: rect.maxX, y: rect.maxY),
					  control2: .init(x: rect.maxX, y: rect.maxY))
		path.addLine(to: .init(x: rect.maxX, y: rect.minY + cornerRadius))
		path.addCurve(to: .init(x: rect.maxX - cornerRadius, y: rect.minY),
					  control1: .init(x: rect.maxX, y: rect.minY),
					  control2: .init(x: rect.maxX, y: rect.minY))
		path.addLine(to: .init(x: rect.minX + cutOff + inset, y: rect.minY))
//		path.addArc(tangent1End: .init(x: rect.minX, y: rect.minY), tangent2End: .init(x: rect.minX, y: rect.minY + cornerRadius), radius: cornerRadius)
//		path.addLine(to: .init(x: rect.minX, y: rect.maxY - cornerRadius))
//		path.addArc(tangent1End: .init(x: rect.minX, y: rect.maxY), tangent2End: .init(x: rect.minX + cornerRadius, y: rect.maxY), radius: cornerRadius)
//		path.addArc(tangent1End: .init(x: rect.maxX, y: rect.maxY), tangent2End: .init(x: rect.maxX, y: rect.maxY - cornerRadius), radius: cornerRadius)
//		path.addArc(tangent1End: .init(x: rect.maxX, y: rect.minY), tangent2End: .init(x: rect.maxX - cornerRadius, y: rect.minY), radius: cornerRadius)
//		path.addLine(to: .init(x: rect.minX + cutOff + inset , y: rect.minY))
		return path
	}
	
}


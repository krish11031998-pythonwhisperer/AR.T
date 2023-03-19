//
//  ViewStyling.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI

//MARK: View Styling

fileprivate struct BorderCard: ViewModifier {
	
	var borderColor: Color
	var radius: CGFloat
	var borderWidth: CGFloat
	
	public init(borderColor: Color, radius: CGFloat = 8, borderWidth: CGFloat = 1) {
		self.borderColor = borderColor
		self.radius = radius
		self.borderWidth = borderWidth
	}
	
	
	public func body(content: Content) -> some View {
		content
            .clipContent(radius: radius)
			.overlay(
				RoundedRectangle(cornerRadius: radius)
					.strokeBorder(borderColor, lineWidth: borderWidth)
			)
	}
}

public extension View {
	
	func borderCard(borderColor: Color, radius: CGFloat = 8, borderWidth: CGFloat = 1) -> some View {
		modifier(BorderCard(borderColor: borderColor, radius: radius, borderWidth: borderWidth))
	}
}

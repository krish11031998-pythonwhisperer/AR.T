//
//  BorderAnimation.swift
//  SUI
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI

private struct BorderAnimation: Animatable, ViewModifier {
	var pct: CGFloat
	let cornerRadius: CGFloat
	
	init(pct:CGFloat,cornerRadius: CGFloat) {
		self.pct = pct
		self.cornerRadius = cornerRadius
	}
	
	var animatableData: CGFloat {
		get { pct }
		set { pct = newValue }
	}
	
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .center) {
				ZStack(alignment: .center) {
					LineBorder(pct: pct, lineWidth: 3, cornerRadius: cornerRadius)
						.foregroundColor(Color.blue.opacity(1))
				}
			}
	}
}

public extension View {
	
	func animatableBorder(pct: CGFloat, cornerRadius: CGFloat) -> some View {
		modifier(BorderAnimation(pct: pct, cornerRadius: cornerRadius))
	}
}

fileprivate struct BorderAnimationTest: View {
	@State var animate: Bool = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			RoundedRectangle(cornerRadius: 10)
				.fill(Color.red)
				.frame(size: .init(squared: 100))
				.buttonify {
					withAnimation(.linear(duration: 10)) {
						animate.toggle()
					}
				}
				.modifier(BorderAnimation(pct: animate ? 1 : 0, cornerRadius: 10))
		}
	}
}

fileprivate struct BorderAnimation_Previews: PreviewProvider {
    static var previews: some View {
		BorderAnimationTest()
    }
}

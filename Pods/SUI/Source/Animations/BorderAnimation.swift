//
//  BorderAnimation.swift
//  SUI
//
//  Created by Krishna Venkatramani on 15/09/2022.
//

import SwiftUI

struct BorderAnimation: Animatable, ViewModifier {
	var pct: CGFloat
	
	var animatableData: CGFloat {
		get { pct }
		set { pct = newValue }
	}
	
	func body(content: Content) -> some View {
		content
			.overlay(alignment: .center) {
				ZStack(alignment: .center) {
					LineBorder(pct: pct, lineWidth: 5)
						.foregroundColor(Color.blue.opacity(1))
					String(format: "%.2f", pct).systemBody().text
				}
			}
	}
}

struct BorderAnimationTest: View {
	@State var animate: Bool = false
	
	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			RoundedRectangle(cornerRadius: 10)
				.fill(Color.red)
				.frame(size: .init(squared: 100))
				.buttonify {
					withAnimation(.linear(duration: 0.75)) {
						animate.toggle()
					}
				}
				.modifier(BorderAnimation(pct: animate ? 1 : 0))
			if animate {
				"animating".systemBody().text
			}
		}
	}
}

struct BorderAnimation_Previews: PreviewProvider {
    static var previews: some View {
		BorderAnimationTest()
    }
}

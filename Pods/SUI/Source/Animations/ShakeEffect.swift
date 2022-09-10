//
//  ShakeEffect.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

////MARK: - ShakeEffect

private struct ShakeEffect: Animatable,ViewModifier {

	var shakes: CGFloat

	var animatableData: CGFloat {
		get { shakes }
		set { shakes = newValue }
	}

	func body(content: Content) -> some View {
		content
			.offset(x: sin(shakes * .pi * 2) * 10)
	}
}

public extension View {
	
	func shakeView(shakes: CGFloat) -> some View {
		modifier(ShakeEffect(shakes: shakes))
	}
}

fileprivate struct ExampleView: View {
	@State var numberOfShakes: CGFloat = 0

	var body: some View {
		VStack(alignment: .center) {
			"Hello"
				.styled(font: .systemFont(ofSize: 15, weight: .semibold), color: .white)
				.text
				.padding(20)
				.background(Color.red)
				.clipShape(RoundedRectangle(cornerRadius: 20))
				.shakeView(shakes: numberOfShakes)
				
		}
		.onAppear {
			withAnimation(.easeIn(duration: 2.0)) {
				numberOfShakes = 5
			}
		}
	}
}



fileprivate struct ShakeEffect_Preview: PreviewProvider {
	static var previews: some View {
		ExampleView()
	}
}


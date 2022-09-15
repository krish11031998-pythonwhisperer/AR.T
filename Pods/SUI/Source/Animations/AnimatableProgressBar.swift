//
//  AnimatableProgressBar.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import SwiftUI

public enum AnimatableProgressBarConfig {
	case horizontal(lineColor: Color)
	case circle(lineWidth: CGFloat,lineColor: Color)
}


//MARK: - AnimatableProgressBar

private struct AnimatableProgressBarModifer: Animatable, ViewModifier {
	
	var pct: CGFloat
	var type: AnimatableProgressBarConfig
	
	var animatableData: CGFloat {
		get { pct }
		set { pct = newValue }
	}
	
	@ViewBuilder var progressBar: some View {
		switch type {
		case .horizontal(let lineColor):
			Line(pct: pct)
				.fill(lineColor)
				.cornerRadius(20)
				.foregroundColor(lineColor)
		case .circle(let lineWidth, let lineColor):
			ArcShape(pct: pct,style: .init(lineWidth: lineWidth))
				.foregroundColor(lineColor)
		}
		
	}
	
	func body(content: Content) -> some View {
		content
			.overlay {
				progressBar
			}
	}
	
}

public extension View {
	
	func horizontalProgressBar(pct: CGFloat, lineColor: Color = .blue) -> some View {
		modifier(AnimatableProgressBarModifer(pct: pct, type: .horizontal(lineColor: lineColor)))
	}
	
	func circularProgressBar(pct: CGFloat, lineWidth: CGFloat, lineColor: Color = .black) -> some View {
		modifier(AnimatableProgressBarModifer(pct: pct, type: .circle(lineWidth: lineWidth, lineColor: .red)))
	}
}


fileprivate struct AnimatableProgressBar: View {
	
	@State var pct: CGFloat = .zero
	
    var body: some View {
		VStack(alignment: .center, spacing: 20) {
			RoundedRectangle(cornerRadius: 20)
				.fill(Color.gray.opacity(0.5))
				.horizontalProgressBar(pct: pct)
				.containerize(header: HeaderCaptionView(title: "Horizontal Progress Bar", subTitle: "Click for animation").anyView)
				.padding(.horizontal)
				.frame(width: .totalWidth, height: 20, alignment: .leading)
				
			Circle()
				.fill(Color.cyan)
				.frame(size: .init(squared: 200))
				.clipped()
				.circularProgressBar(pct: pct, lineWidth: 10, lineColor: .red)
				.containerize(header: HeaderCaptionView(title: "Circular Progress Bar", subTitle: "Click for animation").anyView)
				.padding(.horizontal)
		}
		.fillFrame(alignment: .top)
		.onTapGesture {
			withAnimation(.easeInOut(duration: 0.75)) {
				self.pct = pct != 0 ? 0 : CGFloat.random(in: 0...1)
			}
		}
    }
}

struct AnimatableProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        AnimatableProgressBar()
    }
}

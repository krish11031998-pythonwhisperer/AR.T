//
//  AnimatableProgressBar.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import SwiftUI

public enum AnimatableProgressBarConfig {
	case horizontal(alignment: Alignment,lineColor: Color, size: CGSize)
	case circle(lineWidth: CGFloat,lineColor: Color, size: CGSize)
}

extension AnimatableProgressBarConfig {
	var size: CGSize {
		switch self {
		case .horizontal(_, _, let size):
			return size
		case .circle(_, _, let size):
			return size
		}
	}
	
	var alignment: Alignment {
		switch self {
		case .horizontal(let alignment, _, _):
			return alignment
		default:
			return .center
		}
	}
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
		case .horizontal(let alignment, let lineColor, let size):
			RoundedRectangle(cornerRadius: 20)
				.fill(lineColor)
				.frame(width: pct * size.width, height: size.height, alignment: alignment)
		case .circle(let lineWidth, let lineColor, _):
			ArcShape(pct: pct,style: .init(lineWidth: lineWidth))
				.foregroundColor(lineColor)
		}
		
	}
	
	func body(content: Content) -> some View {
		content
			//.frame(size: type.size)
			.overlay(alignment: type.alignment) {
				progressBar
			}
	}
	
}

public extension View {
	
	func horizontalProgressBar(pct: CGFloat, lineColor: Color = .blue, size: CGSize) -> some View {
		modifier(AnimatableProgressBarModifer(pct: pct, type: .horizontal(alignment: .leading, lineColor: lineColor, size: size)))
	}
	
	func circularProgressBar(pct: CGFloat, lineWidth: CGFloat, lineColor: Color = .black, size: CGSize) -> some View {
		modifier(AnimatableProgressBarModifer(pct: pct, type: .circle(lineWidth: lineWidth, lineColor: .red, size: size)))
	}
}


fileprivate struct AnimatableProgressBar: View {
	
	@State var pct: CGFloat = .zero
	
    var body: some View {
		VStack(alignment: .center, spacing: 20) {
			RoundedRectangle(cornerRadius: 20)
				.fill(Color.gray.opacity(0.5))
				.horizontalProgressBar(pct: pct, size: .init(width: .totalWidth - 30, height: 20))
				.containerize(header: HeaderCaptionView(title: "Horizontal Progress Bar", subTitle: "Click for animation").anyView)
				.padding(.horizontal)
				.frame(width: .totalWidth, height: 20, alignment: .leading)
				
			Circle()
				.fill(Color.cyan)
				.frame(size: .init(squared: 200))
				.clipped()
				.circularProgressBar(pct: pct, lineWidth: 10, lineColor: .red, size: .init(squared: 200))
				.containerize(header: HeaderCaptionView(title: "Circular Progress Bar", subTitle: "Click for animation").anyView)
				.padding(.horizontal)
		}
		.fillFrame(alignment: .top)
		.onTapGesture {
			withAnimation(.easeInOut(duration: 0.75)) {
				self.pct = pct == 1 ? 0 : 1
			}
		}
    }
}

struct AnimatableProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        AnimatableProgressBar()
    }
}

//
//  CascadingCardStack.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

//typealias CascadingCardData = Any
fileprivate struct CascadingCard: ViewModifier {
	
	let delta: Int
	let offFactor: CGFloat
	let pivotFactor: CGFloat
	
	init(delta: Int, offFactor: CGFloat = 50, pivotFactor: CGFloat = 20) {
		self.delta = delta
		self.offFactor = offFactor
		self.pivotFactor = pivotFactor
	}
	
	var pivot: Angle { Angle(degrees: delta == 0 ? 0 : pivotFactor * (delta > 0 ? 1 : -1)) }
	var off: CGFloat { delta.cgFloat * offFactor }
	var scale: CGFloat { delta == .zero ? 1 : 1 - (0.15 * delta.abs.cgFloat) }
	
	func body(content: Content) -> some View {
		content
			.offset(x: off)
			.scaleEffect(scale)
			.rotation3DEffect(-pivot, axis: (x: 0, y: 1, z: 0))
			.zIndex(delta == 0 ? 1 : -delta.abs.double)
	}
}


fileprivate extension View {
	
	func cascadingCard(delta: Int, offFactor: CGFloat = 50, pivotFactor: CGFloat = 10) -> some View {
		modifier(CascadingCard(delta: delta, offFactor: offFactor, pivotFactor: pivotFactor))
	}
}

public struct CascadingCardStack<T:Codable, Content: View>: View {
	
	@State var currentIdx: Int
	@State var offset: CGFloat = .zero
	@State var off: CGFloat = .zero

	let data: [T]
	let viewBuilder: (T,Bool) -> Content
	let offFactor: CGFloat
	let pivotFactor: CGFloat
	let action: ((T) -> Void)?
	
	public init(data: [T],
				offFactor: CGFloat = 50,
				pivotFactor: CGFloat = 10,
				action: ((T) -> Void)? = nil,
				@ViewBuilder viewBuilder: @escaping (T,Bool) -> Content)
	{
		self.data = data
		_currentIdx = .init(initialValue: Int(Double(data.count) * 0.5))
		self.viewBuilder = viewBuilder
		self.offFactor = offFactor
		self.pivotFactor = pivotFactor
		self.action = action
	}
	
	private func change(_ value: DragGesture.Value) {
		let xOff = value.translation.width
		asyncMainAnimation(animation: .easeInOut) {
			self.off = xOff
		}
	}
	
	private func end(_ value: DragGesture.Value) {
		let xOff = value.translation.width
		asyncMainAnimation(animation: .easeInOut) {
			let delta = (xOff > 0 ? -1 : 1)
			if abs(xOff) >= 100, self.currentIdx + delta >= 0 && self.currentIdx + delta <= self.data.count - 1 {
				self.currentIdx += delta
			}
			self.off = .zero
		}
	}
	
	private var dragGesture: some Gesture {
		DragGesture().onChanged(change(_:)).onEnded(end(_:))
	}
	
	private func tapGesture(idx: Int) -> some Gesture {
		TapGesture().onEnded { _ in
			if idx == currentIdx {
				action?(data[currentIdx])
			} else {
				asyncMainAnimation {
					self.currentIdx = idx
				}
			}
			
		}
	}
	
	public var body: some View {
		ZStack(alignment: .center) {
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				
				let delta = data.offset - currentIdx
				
				if data.offset >= currentIdx - 3 &&  data.offset <= currentIdx + 3 {
					viewBuilder(data.element, currentIdx == data.offset)
						.cascadingCard(delta: delta, offFactor: offFactor, pivotFactor: pivotFactor)
						.offset(x: data.offset == currentIdx ? off : 0)
						.gesture(dragGesture.simultaneously(with: tapGesture(idx: data.offset)))
				}
			}
		}
		.frame(width: .totalWidth)
	}
}


fileprivate struct CascadingCardStack_Preview: PreviewProvider {

	static var previews: some View {
		CascadingCardStack(data: CodableColors.allCases.map { ColorCodable(data: $0) }) { color, isSelected in
			RoundedRectangle(cornerRadius: 20)
				.fill(color.data.color)
				.frame(width: 200, height: 350)
		}
	}
}

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
			.opacity(delta == 0 ? 1 : 0.75)
	}
}


fileprivate extension View {
	
	func cascadingCard(delta: Int, offFactor: CGFloat = 50, pivotFactor: CGFloat = 10) -> some View {
		modifier(CascadingCard(delta: delta, offFactor: offFactor, pivotFactor: pivotFactor))
	}
}

public struct CascadingCardStack<Content: View>: View {
	
	@State var currentIdx: Int
	@State var offset: CGFloat = .zero
	@State var off: CGFloat = .zero
	
	
	let data: [Any]
	let viewBuilder: (Any) -> Content
	let offFactor: CGFloat
	let pivotFactor: CGFloat
	
	public init(data: [Any], offFactor: CGFloat = 50, pivotFactor: CGFloat = 10, @ViewBuilder viewBuilder: @escaping (Any) -> Content) {
		self.data = data
		_currentIdx = .init(initialValue: Int(Double(data.count) * 0.5))
		self.viewBuilder = viewBuilder
		self.offFactor = offFactor
		self.pivotFactor = pivotFactor
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
	
	public var body: some View {
		ZStack(alignment: .center) {
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				
				let delta = data.offset - currentIdx
				
				if data.offset >= currentIdx - 3 &&  data.offset <= currentIdx + 3 {
					viewBuilder(data.element)
						.cascadingCard(delta: delta, offFactor: offFactor, pivotFactor: pivotFactor)
						.offset(x: data.offset == currentIdx ? off : 0)
				}
			}
		}
		.gesture(dragGesture)
		.frame(width: .totalWidth)
	}
}


fileprivate struct CascadingCardStack_Preview: PreviewProvider {
	
	static var previews: some View {
		CascadingCardStack(data: [Color.red, Color.blue, Color.mint,Color.red, Color.blue]) { color in
			RoundedRectangle(cornerRadius: 20)
				.fill((color as? Color) ?? .red)
				.frame(width: 200, height: 350)
		}
	}
}

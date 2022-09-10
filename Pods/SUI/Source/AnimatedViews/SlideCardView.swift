//
//  SlideCardView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

//MARK: - SlideCardView
public struct SlideCardView<Content: View>: View {
	
	let data:[Any]
	let viewBuilder: (Any,Bool) -> Content
	let spacing: CGFloat
	let leading: Bool
	let size: CGSize
	
	@State var selected: Int = .zero
	@State var swipeOffset: CGFloat = .zero
	
	public init(data: [Any], itemSize: CGSize, spacing: CGFloat, leading: Bool = false, @ViewBuilder viewBuilder: @escaping (Any,Bool) -> Content) {
		self.data = data
		self.spacing = spacing
		self.viewBuilder = viewBuilder
		self.leading = leading
		self.size = itemSize
	}
	
	private var backButton: some View {
		ZStack(alignment: .leading) {
			HStack(alignment: .center, spacing: 5) {
				Image(systemName: "arrow.left")
					.resizable()
					.scaledToFit()
					.frame(width: 12.5, height: 12.5, alignment: .center)
					.foregroundColor(.white)
					.padding(5)
					.background(Color.black)
					.clipShape(Circle())
				"Back".text
			}.frame(alignment: .leading)
		}
		.frame(size: size)
		.background(Color.blue.blur(radius: 1))
		.clipShape(RoundedRectangle(cornerRadius: 20))
		.onTapGesture {
			asyncMainAnimation(animation: .easeInOut) {
				selected = .zero
			}
		}
	}
	
	
	private var offset: CGFloat {
		-(selected.cgFloat).boundedTo(higher: 2) * size.width
	}
	
	private func onChanged(_ value: DragGesture.Value) {
		let width: CGFloat = value.translation.width
		if abs(width) < 35{
			asyncMainAnimation {
				self.swipeOffset = width
			}
		}
	}
	
	private func onEnded(_ value: DragGesture.Value) {
		let width: CGFloat = value.translation.width
		if abs(swipeOffset) > 15 {
			let change: Int = width > 0 ? -1 : 1
			asyncMainAnimation(animation: .easeInOut) {
				if self.selected + change >= 0 &&  self.selected + change < self.data.count - 1 {
					self.selected += change
				}
			}
		}
		asyncMainAnimation {
			self.swipeOffset = .zero
		}
	}

	private var dragGesture: _EndedGesture<_ChangedGesture<DragGesture>> {
		DragGesture().onChanged(onChanged(_:)).onEnded(onEnded(_:))
	}
	
	public var body: some View {
		HStack(alignment: .center, spacing: spacing) {
			Spacer().frame(size: .init(width: leading ? 0 : (.totalWidth - size.width).half, height: 10))
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				if data.offset >= selected - 2 && data.offset <= selected + 2 {
					viewBuilder(data.element,data.offset == selected)
						.scaleEffect(selected == data.offset ? 1 : 0.85)
						.gesture(dragGesture.simultaneously(with: TapGesture().onEnded{ _ in
							asyncMainAnimation {
								self.selected = data.offset
							}
						}))
				}
			}
			if leading { backButton.scaleEffect(0.85) }
			Spacer().frame(size: .init(width: (.totalWidth - size.width).half, height: 10))
		}
		.offset(x: offset + swipeOffset)
		.frame(width: .totalWidth,height: size.height, alignment: .leading)
	}
}

fileprivate struct SlideCardView_Preview: PreviewProvider {
	
	static var previews: some View {
		ZStack(alignment: .center) {
			SlideCardView(data: [Color.red, Color.blue, Color.mint,Color.red, Color.blue,Color.red, Color.blue, Color.mint,Color.red, Color.blue], itemSize: .init(width: 200, height: 200), spacing: 0, leading: false) { color,isSelected in
				RoundedRectangle(cornerRadius: 20)
					.fill((color as? Color) ?? .red)
					.frame(width: 200, height: 200)
					.overlay {
						VStack(alignment: .leading) {
							Spacer()
							if isSelected {
								"isSelected".text
									.transition(.move(edge: .bottom))
									.padding(.bottom,20)
							}
						}.frame(size: .init(width: 200, height: 200))
						.scaleEffect(0.85)
					}
			}
		}
	}
}


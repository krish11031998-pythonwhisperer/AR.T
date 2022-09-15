//
//  SlideCardView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

//MARK: - SlideCardView
public struct SlideCardView<T: Codable, Content: View>: View {
	
	let data:[T]
	let viewBuilder: (T,Bool) -> Content
	let leading: Bool
	let size: CGSize
	let action: ((T) -> Void)?
	
	@State var selected: Int = .zero
	@State var swipeOffset: CGFloat = .zero
	
	public init(data: [T],
				itemSize: CGSize,
				leading: Bool = false,
				action: ((T) -> Void)? = nil,
				@ViewBuilder viewBuilder: @escaping (T,Bool) -> Content) {
		self.data = data
		self.action = action
		self.viewBuilder = viewBuilder
		self.leading = leading
		self.size = itemSize
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

	
	private var dragGesture: some Gesture{
		DragGesture().onChanged(onChanged(_:)).onEnded(onEnded(_:))
	}
	
	private func tapGesture(idx: Int) -> some Gesture {
		TapGesture().onEnded { _ in
			if idx == selected {
				action?(data[idx])
			} else {
				asyncMainAnimation {
					self.selected = idx
				}
			}
		}
	}
	
	public var body: some View {
		HStack(alignment: .center) {
			Spacer().frame(size: .init(width: leading ? 0 : (.totalWidth - size.width).half, height: 10))
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				if data.offset >= selected - 2 && data.offset <= selected + 2 {
					viewBuilder(data.element,data.offset == selected)
						.scaleEffect(selected == data.offset ? 1 : 0.85)
						.gesture(dragGesture.simultaneously(with: tapGesture(idx: data.offset)))
				}
			}
			Spacer().frame(size: .init(width: (.totalWidth - size.width).half, height: 10))
		}
		.offset(x: offset + swipeOffset)
		.frame(width: .totalWidth,height: size.height, alignment: .leading)
	}
}

fileprivate struct SlideCardView_Preview: PreviewProvider {

	static var data: [ColorCodable] { CodableColors.allCases.map { ColorCodable(data: $0) } }

	static func action(idx: Any) {
		print("(DEBUG) clicked on: ",idx)
	}

	static var previews: some View {
		ZStack(alignment: .center) {
			SlideCardView(data: Self.data, itemSize: .init(width: 200, height: 200), leading: false, action: Self.action(idx:)) { color,isSelected in
				RoundedRectangle(cornerRadius: 20)
					.fill(color.data.color)
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


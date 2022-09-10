//
//  DiscoveryView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import Foundation
import SwiftUI


//MARK: - CardOffsetPrferenceKey

private struct CardOffsetPreferenceKey: PreferenceKey {
	
	static var defaultValue: CGSize = .zero
	
	static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

public extension View {
	
	func cardOffsetSet(_ value: CGSize) -> some View {
		preference(key: CardOffsetPreferenceKey.self, value: value)
	}
	
	func cardOffsetChange(_ handler: @escaping (CGSize) -> Void) -> some View {
		onPreferenceChange(CardOffsetPreferenceKey.self, perform: handler)
	}
}


//MARK: - Card Zoom
private struct DiscoveryCardZoomModifier: ViewModifier {
	
	let size: CGSize
	
	init(size: CGSize) {
		self.size = size
	}
	
	@ViewBuilder func cardBuilder(g: GeometryProxy, content: Content) -> some View {
			
		let midX = g.frame(in: .global).midX
		let midY = g.frame(in: .global).midY
		let diffX = ((0...CGFloat.totalWidth.half).normalize(abs(abs(midX) - .totalWidth.half)).boundedTo(lower: 0, higher: 1))
		let diffY = ((0...CGFloat.totalHeight.half).normalize(abs(abs(midY) - .totalHeight.half)).boundedTo(lower: 0, higher: 1))
		let scaleX = 1 - 0.25 * diffX
		let scaleY = 1 - 0.25 * diffY
		let opacity = (0...CGFloat.totalWidth).isInRange(midX) && (0...CGFloat.totalHeight).isInRange(midY) ? 0.95 + [diffX,diffY].average * 0.05 : 0.5
		content
			.scaleEffect([scaleX, scaleY].average)
			.opacity(opacity)
		
	}
	
	func body(content: Content) -> some View {
		GeometryReader { g in
			cardBuilder(g: g, content: content)
				.frame(size: g.size)
		}.frame(size: size)
	}
	
}

public extension View {
	
	func discoveryCardZoom(size: CGSize) -> some View {
		modifier(DiscoveryCardZoomModifier(size: size))
	}
}


//MARK: - Discovery View

public struct DiscoveryViewModel {
	let cardSize: CGSize
	let rows: Int
	let spacing: CGFloat
	let bgColor: Color
	
	public init(cardSize: CGSize,
				rows: Int,
				spacing: CGFloat,
				bgColor: Color)
	{
		self.cardSize = cardSize
		self.rows = rows
		self.spacing = spacing
		self.bgColor = bgColor
	}
}

public struct DiscoveryView<Content: View>: View {
	
	let data: [Any]
	@ViewBuilder let viewBuilder: (Any) -> Content
	let model: DiscoveryViewModel
	
	@State var dy_xOff: CGFloat = .zero
	@State var dy_yOff: CGFloat = .zero
	@State var static_xOff: CGFloat = .zero
	@State var static_yOff: CGFloat = .zero
	
	public init(data: [Any], model: DiscoveryViewModel, @ViewBuilder viewBuilder: @escaping (Any) -> Content) {
		self.data = data
		self.viewBuilder = viewBuilder
		self.model = model
	}
	
	
	var gridView: some View {
		let rows: [GridItem] = Array(repeating: .init(.fixed(model.cardSize.height), spacing: model.spacing, alignment: .center), count: model.rows)
		return LazyHGrid(rows: rows, alignment: .center, spacing: model.spacing) {
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				viewBuilder(data.element)
					.discoveryCardZoom(size: model.cardSize)
			}
		}
	}
	
	var width: CGFloat {
		let columns: Int = data.count / model.rows
		return model.cardSize.width * columns.cgFloat +  model.spacing * (columns - 1).cgFloat
	}
	
	var height: CGFloat {
		model.cardSize.height * model.rows.cgFloat +  model.spacing * (model.rows - 1).cgFloat
	}
	
	var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				asyncMainAnimation(animation: .default) {
					self.dy_xOff = value.translation.width
					self.dy_yOff = value.translation.height
				}
			}.onEnded { value in
				asyncMainAnimation(animation: .default) {
					self.static_xOff += self.dy_xOff
					self.static_yOff += self.dy_yOff
					self.dy_yOff = .zero
					self.dy_xOff = .zero
				}
			}
	}
	
	func innerView(g: GeometryProxy) -> some View {
		
		let origin: CGPoint = g.frame(in: .global).origin
		
		asyncMainAnimation(animation: .spring()) {
			guard self.dy_xOff == .zero && self.dy_yOff == .zero else { return }
			if origin.x > 20 {
				self.static_xOff -= origin.x - 20
			}

			if origin.y > .safeAreaInsets.top + 20 {
				self.static_yOff -= origin.y - .safeAreaInsets.top - 20
			}
			
			if abs(origin.y) + .totalHeight > g.size.height + CGFloat.safeAreaInsets.bottom {
				self.static_yOff += (abs(origin.y) + .totalHeight) - (g.size.height + CGFloat.safeAreaInsets.bottom)
			}
			
			if abs(origin.x) + .totalWidth > g.size.width + 20 {
				self.static_xOff += (abs(origin.x) + .totalWidth) - (g.size.width + 20)
			}
		}

		return gridView
			.frame(size: g.size)
	}
	
	public var body: some View {
		ZStack(alignment: .top) {
			model.bgColor
			GeometryReader { g in
				innerView(g: g)
			}
			.offset(x: static_xOff + dy_xOff, y: static_yOff + dy_yOff)
			.gesture(dragGesture)
			.frame(width: width, height: height, alignment: .topLeading)
		}
		.frame(size: .init(width: .totalWidth, height: .totalHeight))
		.clipped()
		.edgesIgnoringSafeArea(.all)
		
	}
	
}

private struct DiscoveryView_Preview: PreviewProvider {
	
	static var colors: [Color] {
		let blue = Array(repeating: Color.blue, count: 5)
		let red = Array(repeating: Color.red, count: 5)
		let green = Array(repeating: Color.green, count: 5)
		let indigo = Array(repeating: Color.indigo, count: 5)
		
		return blue + red + green + indigo
	}
	
	static var discoveryModel: DiscoveryViewModel {
		.init(cardSize: .init(squared: 200), rows: 4, spacing: 50, bgColor: .black)
	}
	
	static var previews: some View {
		ZStack(alignment: .center) {
			Color.black
			DiscoveryView(data: Self.colors, model: Self.discoveryModel) { color in
				RoundedRectangle(cornerRadius: 20)
					.fill((color as? Color) ?? .brown)
					.frame(size: .init(squared: 200))
			}
		}.frame(size: .init(width: .totalWidth, height: .totalHeight))
		.edgesIgnoringSafeArea(.all)
	}
}

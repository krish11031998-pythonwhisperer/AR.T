//
//  DiscoveryView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import Foundation
import SwiftUI

//MARK: - Definations

public struct DiscoveryCardData {
	public let id: Int
	public let data: Any
	
	public init(id: Int, data: Any) {
		self.id = id
		self.data = data
	}
}

//MARK: - SelectedCardPreferenceKey

private struct SelectedCardPreferenceKey: PreferenceKey {
	
	static var defaultValue: Int = -1
	
	static func reduce(value: inout Int, nextValue: () -> Int) {
		if nextValue() != defaultValue {
			value = nextValue()
		}
	}
}

public extension View {
	
	func cardSelected(_ value: Int) -> some View {
		preference(key: SelectedCardPreferenceKey.self, value: value)
	}
	
	func selectedCardChange(_ handler: @escaping (Int) -> Void) -> some View {
		onPreferenceChange(SelectedCardPreferenceKey.self, perform: handler)
	}
}

//MARK: - CardOffsetPrferenceKey

private struct CentralizeCard: PreferenceKey {
	
	static var defaultValue: CGRect? = nil
	
	static func reduce(value: inout CGRect?, nextValue: () -> CGRect?) {
		let newValue = nextValue()
		if newValue != nil {
			value = newValue
		}
	}
}

public extension View {
	
	func cardOffsetSet(_ value: CGRect?) -> some View {
		preference(key: CentralizeCard.self, value: value)
	}
	
	func cardOffsetChange(_ handler: @escaping (CGRect?) -> Void) -> some View {
		onPreferenceChange(CentralizeCard.self, perform: handler)
	}
}


//MARK: - Card Zoom
private struct DiscoveryCardZoomModifier: ViewModifier {
	
	let size: CGSize
	let isSelected: Bool
	
	init(size: CGSize, isSelected: Bool = false) {
		self.size = size
		self.isSelected = isSelected
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
			.cardOffsetSet(isSelected ? g.frame(in: .global).midFrame : nil)
	}
	
	func body(content: Content) -> some View {
		GeometryReader { g in
			cardBuilder(g: g, content: content)
				.frame(size: g.size)
		}.frame(size: size)
	}
	
}

public extension View {
	
	func discoveryCardZoom(size: CGSize, isSelected: Bool) -> some View {
		modifier(DiscoveryCardZoomModifier(size: size, isSelected: isSelected))
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
	
	let data: [DiscoveryCardData]
	@ViewBuilder let viewBuilder: (DiscoveryCardData) -> Content
	let model: DiscoveryViewModel
	
	@State var dy_xOff: CGFloat = .zero
	@State var dy_yOff: CGFloat = .zero
	@State var static_xOff: CGFloat = .zero
	@State var static_yOff: CGFloat = .zero
	@State var selectedIdx: Int = -1
	@State var selectedFrame: CGRect? = nil
	
	public init(data: [DiscoveryCardData], model: DiscoveryViewModel, @ViewBuilder viewBuilder: @escaping (DiscoveryCardData) -> Content) {
		self.data = data
		self.viewBuilder = viewBuilder
		self.model = model
	}
	
	
	var gridView: some View {
		let rows: [GridItem] = Array(repeating: .init(.fixed(model.cardSize.height), spacing: model.spacing, alignment: .center), count: model.rows)
		return LazyHGrid(rows: rows, alignment: .center, spacing: model.spacing) {
			ForEach(data, id: \.id) { data in
				viewBuilder(data)
					.discoveryCardZoom(size: model.cardSize, isSelected: selectedIdx == data.id)
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
				resetSelectedCard()
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
		updateAfterScroll(g: g)
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
			.frame(width: width, height: height, alignment: .topLeading)
		}
		.gesture(dragGesture)
		.frame(size: .init(width: .totalWidth, height: .totalHeight))
		.clipped()
		.edgesIgnoringSafeArea(.all)
		.cardOffsetChange { newValue in
			asyncMainAnimation {
				self.selectedFrame = newValue
			}
		}
		.selectedCardChange { newValue in
			asyncMainAnimation {
				self.selectedIdx = newValue
			}
		}
		
	}
	
}

//MARK: - DiscoveryView Methods

extension DiscoveryView {
	
	private func updateAfterScroll(g: GeometryProxy) {
		if selectedIdx != -1 && selectedFrame != nil {
			centralizeCardAfterSelection(g: g)
		} else if dy_xOff == .zero && selectedIdx == -1 {
			comeIntoBoundsAfterScroll(g: g)
		}
	}
	
	
	private func comeIntoBoundsAfterScroll(g: GeometryProxy) {
		let origin: CGPoint = g.frame(in: .global).origin
		asyncMainAnimation(animation: .spring().speed(0.75)) {
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
	}
	
	private func centralizeCardAfterSelection(g: GeometryProxy) {
		guard let validSelectedFrame = selectedFrame else { return }
		asyncMainAnimation(animation: .easeInOut(duration: 0.75)) {
			self.static_xOff += .totalWidth.half - validSelectedFrame.origin.x
			self.static_yOff += .totalHeight.half - validSelectedFrame.origin.y
			selectedFrame = nil
		}
	}
	
	private func resetSelectedCard() {
		asyncMainAnimation(animation: .easeInOut(duration: 0.5)) {
			selectedIdx = -1
			selectedFrame = nil
		}
	}
	
}

private struct DiscoveryView_Preview: PreviewProvider {
	
	static var colors: [DiscoveryCardData] {
		let blue = Array(repeating: Color.blue, count: 5)
		let red = Array(repeating: Color.red, count: 5)
		let green = Array(repeating: Color.green, count: 5)
		let indigo = Array(repeating: Color.indigo, count: 5)
		
		return (blue + red + green + indigo).enumerated().map { .init(id: $0.offset, data: $0.element) }
	}
	
	static var discoveryModel: DiscoveryViewModel {
		.init(cardSize: .init(squared: 200), rows: 4, spacing: 50, bgColor: .black)
	}
	
	@State static var selected: Int = -1
	
	static var previews: some View {
		ZStack(alignment: .center) {
			Color.black
			DiscoveryView(data: Self.colors, model: Self.discoveryModel) { color in
				RoundedRectangle(cornerRadius: 20)
					.fill((color.data as? Color) ?? .brown)
					.frame(size: .init(squared: 200))
					.buttonify {
						Self.selected = color.id
					}
			}
		}.frame(size: .init(width: .totalWidth, height: .totalHeight))
		.edgesIgnoringSafeArea(.all)
	}
}

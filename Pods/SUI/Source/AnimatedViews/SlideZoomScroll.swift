//
//  SlideZoomCardCarousel.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

//MARK: - View Modifier

fileprivate struct SlideZoomCard: ViewModifier {
	
	let size: CGSize
	@State var scale: CGFloat = 1
	init(size: CGSize) {
		self.size = size
	}
	
	func scaleFactor(midX: CGFloat){
		scale = midX > .totalWidth * 0.5 ? 0.9 : 1
	}
	
	func body(content: Content) -> some View {
		GeometryReader { g -> AnyView in
			let midX = g.frame(in: .global).midX
			
			DispatchQueue.main.async {
				withAnimation {
					scaleFactor(midX: midX)
				}
			}
			
			let view = content
				.scaleEffect(scale)
			
			return AnyView(view)
		}
		.frame(size: size, alignment: .center)
	}
}

//MARK: - View Extension

fileprivate extension View {
	
	func slideZoomCard(size: CGSize) -> some View { modifier(SlideZoomCard(size: size)) }
}

//MARK: - SlideZoomScroll

public struct SlideZoomScroll<Content: View>: View {
	
	@State var currentIdx: Int = .zero
	@State var off: CGFloat = .zero
	
	let size: CGSize
	let spacing: CGFloat
	let data: [Any]
	let cardBuilder: (Any) -> Content
	
	public init(data: [Any], itemSize: CGSize, spacing: CGFloat = 10, @ViewBuilder cardBuilder: @escaping (Any) -> Content) {
		self.data = data
		self.cardBuilder = cardBuilder
		self.spacing = spacing
		self.size = itemSize
	}
	
	public var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack(alignment: .center, spacing: spacing) {
				ForEach(Array(data.enumerated()), id: \.offset) { data in
					cardBuilder(data.element)
						.slideZoomCard(size: size)
						.fixedSize()
				}
				Spacer().frame(size: .init(width: .totalWidth.half.half, height: size.height))
			}
			.frame(height: size.height, alignment: .leading)
		}
	}
}


fileprivate struct SlideZoomCardCarousel_Preview: PreviewProvider {
	
	static var previews: some View {
		SlideZoomScroll(data: [Color.red, Color.blue, Color.mint,Color.red, Color.blue,Color.red, Color.blue, Color.mint,Color.red, Color.blue], itemSize: .init(width: 200, height: 200)) { color in
			RoundedRectangle(cornerRadius: 20)
				.fill((color as? Color) ?? .red)
				.frame(width: 200, height: 200)
		}
	}
}

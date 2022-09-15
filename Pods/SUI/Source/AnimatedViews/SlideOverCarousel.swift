//
//  SlideOverCarousel.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 05/09/2022.
//

import Foundation
import SwiftUI
import Combine

//MARK: - SlideCard ViewModifier

fileprivate struct SlideCard: ViewModifier {
	
	var isPrev: Bool
	var isNext: Bool
	
	init(isPrev: Bool, isNext: Bool) {
		self.isPrev = isPrev
		self.isNext = isNext
	}
	
	var offset: CGFloat {
		isNext ? .totalWidth : 0
	}
	
	var scale: CGFloat {
		isPrev ? 0.9 : 1
	}
	
	func body(content: Content) -> some View {
		content
			.offset(x: offset)
			.scaleEffect(scale)
	}
}

fileprivate extension View {
	
	func slideCard(isPrev: Bool, isNext: Bool) -> some View {
		self.modifier(SlideCard(isPrev: isPrev, isNext: isNext))
	}
}

//MARK: - TimerViewModifier

private struct TimerViewModifier: ViewModifier {
	
	let timeInterval: TimeInterval
	let timer: Publishers.Autoconnect<Timer.TimerPublisher>
	let action: Callback
	init(timeInterval: TimeInterval, action: @escaping Callback) {
		self.timeInterval = timeInterval
		self.timer = Timer.publish(every: timeInterval, on: .main, in: .common).autoconnect()
		self.action = action
	}
	
	func body(content: Content) -> some View {
		content
			.onReceive(timer, perform: { _ in action() })
	}
}

public extension View {
	
	func timer(timeInterval: TimeInterval, action: @escaping Callback) -> some View {
		modifier(TimerViewModifier(timeInterval: timeInterval, action: action))
	}
}

//MARK: - SlideOverCarousel Config

public struct SlideOverCarouselConfig {
	let hasTimer: Bool
	let time: TimeInterval
	let animation: Animation
	
	public init(hasTimer: Bool, time: TimeInterval = 0, animation: Animation = .linear(duration: 0.35)) {
		self.hasTimer = hasTimer
		self.time = time
		self.animation = animation
	}
	
	public static var noTimer: Self { .init(hasTimer: false) }
	public static var withTimer: Self { .init(hasTimer: true, time: 10) }
}

//MARK: - SlideOverCarousel

public typealias SlideOverCarouselCallback = (Int) -> Void

public struct SlideOverCarousel<T:Codable, Content: View>: View {
	
	let data: [T]
	let viewBuilder: (T) -> Content
	let config: SlideOverCarouselConfig
	let actionHandler: SlideOverCarouselCallback?
	@State var currentIdx: Int = .zero
	
	public init(data: [T],
				config: SlideOverCarouselConfig = .noTimer,
				@ViewBuilder viewBuilder: @escaping (T) -> Content,
				action: SlideOverCarouselCallback? = nil)
	{
		self.data = data
		self.viewBuilder = viewBuilder
		self.config = config
		self.actionHandler = action
	}
	
	private func handleTap() {
		asyncMainAnimation {
			if !config.hasTimer {
				currentIdx = currentIdx == data.count - 1 ? 0 : currentIdx + 1
			} else {
				actionHandler?(currentIdx)
			}
		}
	}
	
	func checkTime(){
		withAnimation(.linear(duration: 0.35)) {
			currentIdx = currentIdx + 1 < data.count ? currentIdx + 1 : 0
		}
	}
	
	private var carousel: some View {
		ZStack(alignment: .center) {
			ForEach(Array(data.enumerated()), id: \.offset) { data in
				if data.offset >= currentIdx - 1 && data.offset <= currentIdx + 1 {
					viewBuilder(data.element)
						.buttonify(action: handleTap)
						.slideCard(isPrev: data.offset == currentIdx - 1, isNext: data.offset == currentIdx + 1)
				}
			}
		}
	}
	
	public var body: some View {
		if config.hasTimer {
			carousel
				.timer(timeInterval: config.time, action: checkTime)
		} else {
			carousel
		}
	}
}

fileprivate struct SlideOverCarouselPreviewProvider: PreviewProvider {
	static var previews: some View {
		SlideOverCarousel(data: CodableColors.allCases.map { ColorCodable(data: $0) } , config: .init(hasTimer: false)) { color in
			RoundedRectangle(cornerRadius: 20)
				.fill(color.data.color)
				.frame(width: .totalWidth - 20, height: 200, alignment: .center)
		}
	}
}

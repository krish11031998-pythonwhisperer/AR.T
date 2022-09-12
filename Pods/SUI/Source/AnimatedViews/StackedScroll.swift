//
//  StackedScroll.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

//MARK: - StackScrollPreferenceKey

public struct StackScrollPreferenceKey: PreferenceKey {
	
	public static var defaultValue: Bool = true
	
	public static func reduce(value: inout Bool, nextValue: () -> Bool) {
		value = value && nextValue()
	}
	
}

public extension View {
	
	func scrollToggle(state: Bool) -> some View {
		preference(key: StackScrollPreferenceKey.self, value: state)
	}
}


//MARK: - StackedScroll

public struct StackedScroll<Page: View>: View {
	
	let data: [Any]
	let pageBuilder: (Any, Bool) -> Page
	@State var currentIdx: Int = .zero
	@State var offset: CGFloat = .zero
	@State var scrollEnabled: Bool = true
	
	public init(data: [Any], @ViewBuilder pageBuilder: @escaping (Any, Bool) -> Page) {
		self.data = data
		self.pageBuilder = pageBuilder
	}
	
	private var scrolledOffset: CGFloat {
		-currentIdx.cgFloat * .totalHeight
	}
	
	private var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				asyncMainAnimation {
					self.offset = value.translation.height
				}
			}
			.onEnded { value in
				let height = value.translation.height
				let delta = value.translation.height > 0 ? -1 : 1
				asyncMainAnimation {
					guard abs(height) > 50 else {
						self.offset = .zero
						return
					}
					if (currentIdx + delta).isInRange(lower: 0, higher: self.data.count - 1) {
						self.currentIdx += delta
					}
					self.offset = .zero
				}
			}
	}
	
	public var body: some View {
		LazyVStack(alignment: .center, spacing: 0) {
			ForEach(Array(data.enumerated()), id:\.offset) { data in
				pageBuilder(data.element, data.offset == currentIdx)
					.frame(size: .init(width: .totalWidth, height: .totalHeight))
			}
		}
		.onPreferenceChange(StackScrollPreferenceKey.self) { newValue in
			print("(DEBUG) Updating the scrollState : ", newValue)
			scrollEnabled = newValue
		}
		.offset(x: .zero, y: scrolledOffset + offset)
		.frame(width: .totalWidth, height: .totalHeight, alignment: .top)
		.gesture(scrollEnabled ? dragGesture : nil)
		.clipped()
		.edgesIgnoringSafeArea(.all)
	}
}

private struct StackedScroll_Preview: PreviewProvider {

	static var previews: some View {
		StackedScroll(data: [Color.red, Color.blue, Color.green]) { data, isSelected in
			
			VStack(alignment: .leading, spacing: 10) {
				RoundedButton(model: .testModel)
					.fixedHeight(height: 50)
				RoundedButton(model: .testModelLeading)
					.fixedHeight(height: 50)
				RoundedButton(model: .testModelTrailing)
					.fixedHeight(height: 50)
				RoundedButton(model: .testModelWithBlob)
					.fixedHeight(height: 50)
			}
			.padding(.init(top: .safeAreaInsets.top, leading: 20, bottom: .safeAreaInsets.bottom, trailing: 20))
			.frame(width: .totalWidth, height: .totalHeight, alignment: .topLeading)
			.background((data as? Color) ?? .black)
		}
	}
}

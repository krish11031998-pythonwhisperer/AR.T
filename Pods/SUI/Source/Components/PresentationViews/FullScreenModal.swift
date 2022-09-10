//
//  FullScreenModal.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

//MARK: - FullScreen Modal

public struct FullScreenModalConfig {
	let isDraggable: Bool
	let showCloseIndicator: Bool
	
	public init(isDraggable: Bool,
				showCloseIndicator: Bool)
	{
		self.isDraggable = isDraggable
		self.showCloseIndicator = showCloseIndicator
	}
}

private struct FullScreenModal<InnerContent: View>: ViewModifier {
	
	let config: FullScreenModalConfig
	@Binding var isActive: Bool
	let innerContent: InnerContent
	@State var dragIndicator: CGFloat = .zero
	
	init(isActive: Binding<Bool>,
		 config: FullScreenModalConfig = .init(isDraggable: false, showCloseIndicator: true),
		 @ViewBuilder innerContent: @escaping () -> InnerContent)
	{
		self._isActive = isActive
		self.config = config
		self.innerContent = innerContent()
	}
	
	var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				guard value.translation.height > 0 && value.translation.height <= 20  else { return }
				asyncMainAnimation {
					self.dragIndicator = value.translation.height
				}
			}
			.onEnded { value in
				asyncMainAnimation {
					guard value.translation.height > 20 else {
						self.dragIndicator = .zero
						return
					}
					
					self.dragIndicator = .zero
					self.isActive.toggle()
				}
			}
	}
	
	@ViewBuilder var closeIndicators: some View {
		if config.isDraggable {
			HStack(alignment: .center, spacing: 10) {
				"Close".styled(font: .systemFont(ofSize: 12, weight: .semibold), color: .white).text
				CustomButton(config: .init(imageName: .close, size: .init(squared: 10), padding: 0, foregroundColor: .white, backgroundColor: .clear))
			}
			.padding(.horizontal,7.5)
			.padding(.vertical, 10)
			.background(Color.black)
			.clipShape(Capsule())
			.padding(.top, .safeAreaInsets.top)
			.offset(y: dragIndicator)
			.gesture(dragGesture)
			.transitionFrom(.top)
		} else {
			CustomButton(config: .init(imageName: .close, size: .init(squared: 15), foregroundColor: .black, backgroundColor: .white)) {
				self.isActive.toggle()
			}
			.padding(.horizontal)
			.padding(.top, .safeAreaInsets.top)
			.fillWidth(alignment: .trailing)
		}
	}
	
	var destinationView: some View {
		ZStack(alignment: .top) {
			innerContent
			if config.showCloseIndicator {
				closeIndicators
			}
		}
		.fillFrame(alignment: .top)
	}
	
	func body(content: Content) -> some View {
		content
			.fullScreenCover(isPresented: $isActive) {
				destinationView
			}
	}
	
}

public extension View {
	
	func fullScreenModal<InnerContent: View>(isActive: Binding<Bool>,
											 config: FullScreenModalConfig =  .init(isDraggable: false, showCloseIndicator: true),
											 @ViewBuilder innerContent: @escaping () -> InnerContent) -> some View {
		modifier(FullScreenModal(isActive: isActive, config: config, innerContent: { innerContent() }))
	}
}

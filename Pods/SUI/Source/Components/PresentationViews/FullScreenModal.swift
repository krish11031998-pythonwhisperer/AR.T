//
//  FullScreenModal.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 09/09/2022.
//

import Foundation
import SwiftUI

public extension CustomButtonConfig {
	
	static var `default`: Self {
		.init(imageName: .close,
			  text: "Close".systemHeading1(color: .white),
			  size: .init(squared: 7.5),
			  foregroundColor: .white,
			  backgroundColor: .black,
			  buttonStyle: .button)
	}
}

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
	let innerContent: InnerContent
	let modalButtonConfig: CustomButtonConfig
	@Binding var isActive: Bool
	@State var dragIndicator: CGFloat = .zero
	
	init(isActive: Binding<Bool>,
		 config: FullScreenModalConfig = .init(isDraggable: false, showCloseIndicator: true),
		 modalButtonConfig: CustomButtonConfig = .default,
		 @ViewBuilder innerContent: @escaping () -> InnerContent)
	{
		self._isActive = isActive
		self.config = config
		self.modalButtonConfig = modalButtonConfig
		self.innerContent = innerContent()
	}
	
	var dragGesture: some Gesture {
		DragGesture()
			.onChanged { value in
				guard value.translation.height > 0 && value.translation.height <= 20  else { return }
				asyncMainAnimation {
					self.dragIndicator = value.translation.height * 1.5
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
			CustomButton(config: modalButtonConfig)
			.padding(.top, .safeAreaInsets.top)
			.offset(y: dragIndicator)
			.gesture(dragGesture)
			.transitionFrom(.top)
		} else if config.showCloseIndicator {
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
		.edgesIgnoringSafeArea(.all)
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
											 buttonConfig: CustomButtonConfig = .default,
											 @ViewBuilder innerContent: @escaping () -> InnerContent) -> some View {
		modifier(FullScreenModal(isActive: isActive, config: config, modalButtonConfig: buttonConfig, innerContent: { innerContent() }))
	}
}

//
//  Button.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI


//MARK: = Image Extension

public extension Image {
	
	enum SystemCatalogue: String {
		case back = "arrow.left"
		case next = "arrow.right"
		case close = "xmark"
	}
}

public extension Image.SystemCatalogue {
	var image: Image { .init(systemName: rawValue) }
	
	func systemNamed(_ name: String) -> Image { .init(systemName: name) }
}


// MARK: - CustomButton

public struct CustomButtonConfig {
	let imageName: Image.SystemCatalogue
	let text: String?
	let size: CGSize
	let padding: CGFloat
	let foregroundColor: Color
	let backgroundColor: Color
	
	public init(imageName: Image.SystemCatalogue,
		 text: String? = nil,
		 size: CGSize = .init(squared: 10),
		 padding: CGFloat = 10,
		 foregroundColor: Color = .white,
		 backgroundColor: Color = .black)
	{
		self.imageName = imageName
		self.text = text
		self.size = size
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.padding = padding
	}
}

public struct CustomButton: View {
	
	let config: CustomButtonConfig
	let action: Callback?
	
	public init(config: CustomButtonConfig, action: Callback? = nil) {
		self.config = config
		self.action = action
	}
	
	public var body: some View {
		HStack(alignment: .center, spacing: 5) {
			config.imageName.image
				.resizable()
				.scaledToFit()
				.foregroundColor(config.foregroundColor)
				.frame(size: config.size)
				.padding(config.padding)
				.background(config.backgroundColor)
				.clipShape(Circle())
			if let validText = config.text {
				validText.text
			}
		}
		.buttonify {
			action?()
		}
	}
}

// MARK: - CustomButtonModifier

fileprivate struct CustomButtonStyle: ButtonStyle {
	
	func makeBody(configuration: Configuration) -> some View {
		configuration.label
			.scaleEffect(configuration.isPressed ? 0.9 : 1)
	}	
}


//MARK: - ButtonViewModifier

fileprivate struct ButtonViewModifier: ViewModifier {
	
	let handler: () -> Void
	let animation: Animation
	
	init(animation: Animation, handler: @escaping () -> Void) {
		self.handler = handler
		self.animation = animation
	}
	
	
	func body(content: Content) -> some View {
		Button {
			asyncMainAnimation(animation: animation, completion: handler)
		} label: {
			content
		}.buttonStyle(CustomButtonStyle())
	}
}

public extension View {
	
	func buttonify(animation: Animation = .default ,action: @escaping () -> Void) -> some View {
		modifier(ButtonViewModifier(animation: animation, handler: action))
	}
}

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

public enum CustomButtonStyleType {
	case image
	case button
}

public struct CustomButtonConfig {
	let imageName: Image.SystemCatalogue?
	let image: UIImage?
	let text: RenderableText?
	let size: CGSize
	let padding: EdgeInsets
	let foregroundColor: Color
	let backgroundColor: Color
	let buttonStyle: CustomButtonStyleType
	
	public init(imageName: Image.SystemCatalogue? = nil,
				img: UIImage? = nil,
				text: RenderableText? = nil,
				size: CGSize = .init(squared: 10),
				padding: EdgeInsets = .init(vertical: 7.5, horizontal: 10),
				foregroundColor: Color = .white,
				backgroundColor: Color = .black,
				buttonStyle: CustomButtonStyleType = .image)
	{
		self.imageName = imageName
		self.image = img
		self.text = text
		self.size = size
		self.foregroundColor = foregroundColor
		self.backgroundColor = backgroundColor
		self.padding = padding
		self.buttonStyle = buttonStyle
	}
}

public struct CustomButton: View {
	
	let config: CustomButtonConfig
	let action: Callback?
	
	public init(config: CustomButtonConfig, action: Callback? = nil) {
		self.config = config
		self.action = action
	}
	
	@ViewBuilder private var imageView: some View {
		if let validImgName = config.imageName {
			validImgName.image
				.scaleToFit()
		} else if let validImg = config.image{
			Image(uiImage: validImg)
				.scaleToFit()
		} else {
			Color.clear.frame(size: .zero)
		}
	}
	
	@ViewBuilder var buttonBody: some View {
		if config.buttonStyle == .image {
			HStack(alignment: .center, spacing: 5) {
				imageView
					.foregroundColor(config.foregroundColor)
					.frame(size: config.size)
					.padding(config.padding)
					.background(config.backgroundColor)
					.clipShape(Circle())
				if let validText = config.text {
					validText.text
				}
			}
		} else {
			HStack(alignment: .center, spacing: 5) {
				imageView
					.foregroundColor(config.foregroundColor)
					.frame(size: config.size)
				
				if let validText = config.text {
					validText.text
				}
			}
			.padding(config.padding)
			.background(config.backgroundColor)
			.clipShape(Capsule())
		}
	}
	
	public var body: some View {
		if let action = action {
			buttonBody
				.buttonify(action: action)
		} else {
			buttonBody
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

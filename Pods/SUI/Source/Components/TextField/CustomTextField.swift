//
//  CustomTextField.swift
//  Pods-SUI_Example
//
//  Created by Krishna Venkatramani on 16/09/2022.
//

import SwiftUI

//MARK: - CustomTextFieldStyle
private struct CustomTextFieldStyle: TextFieldStyle {

	@State var size: CGSize = .zero
	@Binding var isEditting: Bool
	let config: CustomTextFieldConfig
	init(config: CustomTextFieldConfig, isEditting: Binding<Bool>) {
		self._isEditting = isEditting
		self.config = config
	}
	
	var offset: CGSize {
		isEditting ? .init(width: 0, height: -(size.height + config.insets.top)) : .zero
	}
	
	var placeHolder: some View {
		config.placeHolder.text
			.allowsHitTesting(false)
			.offset(offset)
			.scaleEffect(isEditting ? 0.9 : 1)
			.background(
				GeometryReader { g -> AnyView in
					DispatchQueue.main.async {
						self.size = g.size
					}
					return Color.clear.anyView
				}
			)
			.padding(.leading,config.insets.leading)
			.fillWidth(alignment: .leading)
	}
	
	func _body(configuration: TextField<_Label>) -> some View {
		configuration
		  .textFieldStyle(PlainTextFieldStyle())
		  .multilineTextAlignment(.leading)
		  .accentColor(config.accentColor)
		  .foregroundColor(config.foregroundColor)
		  .font(config.font)
		  .padding(config.insets)
		  .overlay {
			  ZStack(alignment: .center) {
				placeHolder
				  CustomizableBorder(size: size,
									 cornerRadius: config.cornerRadius,
									 inset: config.insets.leading,
									 isEditting: isEditting)
					  .stroke(lineWidth: config.borderWidth)
					  .foregroundColor(config.borderColor)
					  //.animation(.easeInOut)
			  }
		  }
	}
}

//MARK: - CustomTextFieldConfig

public struct CustomTextFieldConfig {
	let accentColor: Color
	let foregroundColor: Color
	let font: Font
	let insets: EdgeInsets
	let placeHolder: RenderableText
	let borderColor: Color
	let borderWidth: CGFloat
	let cornerRadius: CGFloat
	
	public init(
		accentColor: Color,
		foregroundColor: Color,
		font: Font,
		insets: EdgeInsets,
		placeHolder: RenderableText,
		borderColor: Color,
		borderWidth: CGFloat,
		cornerRadius: CGFloat = 20
	) {
		self.accentColor = accentColor
		self.foregroundColor = foregroundColor
		self.font = font
		self.insets = insets
		self.placeHolder = placeHolder
		self.borderColor = borderColor
		self.borderWidth = borderWidth
		self.cornerRadius = cornerRadius
	}
}

fileprivate extension CustomTextFieldConfig {
	
	static var `default`: CustomTextFieldConfig = .init(accentColor: .red,
														foregroundColor: .blue,
														font: .system(size: 15, weight: .regular, design: .default),
														insets: .init(vertical: 12, horizontal: 16),
														placeHolder: "Placeholder".systemBody(), borderColor: .green, borderWidth: 2,cornerRadius: 8)
}

//MARK: - CustomTextField
public struct CustomTextField: View {
	@State var text: String = ""
	@State var isEditting: Bool = false
	let config: CustomTextFieldConfig
	
	public init(config: CustomTextFieldConfig) {
		self.config = config
	}
	
	func onEditting(_ editting: Bool) {
		if text == "" {
			withAnimation(.default) {
				isEditting = editting
			}
		}
	}
	
	private func onCommit() {
		if text == "" {
			withAnimation(.default) {
				isEditting = false
			}
		}
	}
	
    public var body: some View {
		TextField("", text: $text, onEditingChanged: onEditting(_:), onCommit: onCommit)
			.textFieldStyle(CustomTextFieldStyle(config: config, isEditting: $isEditting))
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
		CustomTextField(config: .default)
    }
}

//
//  BlobButton.swift
//  SUI
//
//  Created by Krishna Venkatramani on 13/09/2022.
//

import SwiftUI

//MARK: - BlobButtonConfig

public struct BlobButtonConfig {
	
	public struct BlobBorderConfig {
		let color: Color
		let borderWidth: CGFloat
		
		public init(color: Color, borderWidth: CGFloat) {
			self.color = color
			self.borderWidth = borderWidth
		}
	}
	
	let color: Color
	let cornerRadius: CGFloat
	let border: BlobBorderConfig
	
	public init(color: Color, cornerRadius: CGFloat, border: BlobBorderConfig) {
		self.color = color
		self.cornerRadius = cornerRadius
		self.border = border
	}
}

//MARK: - BlobButton
public struct BlobButton: View {
	let text: RenderableText
	let config: BlobButtonConfig
	let action: Callback?
	
	public init(text: RenderableText, config: BlobButtonConfig, action: Callback? = nil) {
		self.text = text
		self.config = config
		self.action = action
	}
	
    public var body: some View {
		text.text
			.padding(.horizontal,10)
			.padding(.vertical,7.5)
			.background(config.color)
			.clipContent(radius: config.cornerRadius)
			.borderCard(borderColor: config.border.color, radius: config.cornerRadius, borderWidth: config.border.borderWidth)
			.buttonify {
				action?()
			}
    }
}

struct BlobButton_Previews: PreviewProvider {
    static var previews: some View {
		BlobButton(text: "Japanese".styled(font: .systemFont(ofSize: 15, weight: .regular), color: .purple),
				   config: .init(color: .purple.opacity(0.25), cornerRadius: 13, border: .init(color: .purple, borderWidth: 2))) {
			print("(DEBUG) clicked on data!")
		}
    }
}

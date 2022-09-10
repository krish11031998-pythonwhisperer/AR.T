//
//  String.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

public protocol RenderableText {
	var text: Text { get }
}

extension AttributedString: RenderableText {
	
	public var text: Text { .init(self) }
	
	public func styled(font: UIFont, color: Color) -> RenderableText {
		var attributedString = self
		attributedString.font = font
		attributedString.foregroundColor = color
		
		return attributedString
	}
}

extension String: RenderableText {
	
	public var text: Text {
		.init(self)
	}
	
	public func styled(font: UIFont, color: Color) -> RenderableText {
		var attributedString = AttributedString(self)
		attributedString.font = font
		attributedString.foregroundColor = color
		
		return attributedString
	}
}

public extension String {
	
	func systemHeading1(color: Color = .black) -> RenderableText {
		styled(font: .systemFont(ofSize: 15, weight: .semibold), color: color)
	}
	
	func systemSubHeading(color: Color = .black) -> RenderableText {
		styled(font: .systemFont(ofSize: 13, weight: .medium),color: color)
	}
	
	func systemBody(color: Color = .black) -> RenderableText {
		styled(font: .systemFont(ofSize: 12, weight: .regular),color: color)
	}
}

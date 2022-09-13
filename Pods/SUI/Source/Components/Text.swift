//
//  Text.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI

//MARK: - Heading Type
public enum HeadingType {
	case headSubhead
	case headCaption
}

//MARK: - Head SubHead View

public struct HeaderSubHeadView: View {
	
	let title: RenderableText
	let subTitle: RenderableText?
	let spacing: CGFloat
	let alignment: HorizontalAlignment
	
	public init(title: RenderableText, subTitle: RenderableText?, spacing: CGFloat = 10, alignment: HorizontalAlignment = .leading) {
		self.title = title
		self.subTitle = subTitle
		self.spacing = spacing
		self.alignment = alignment
	}
	
	public var body: some View {
		VStack(alignment: alignment, spacing: spacing) {
			title.text
			if let validSubtitle = subTitle {
				validSubtitle.text
			}
		}
	}
}


//MARK: -  Head Caption View

public struct HeaderCaptionView: View {
	
	let title: RenderableText
	let subTitle: RenderableText?
	let spacing: CGFloat
	let alignment: VerticalAlignment
	
	public init(title: RenderableText, subTitle: RenderableText? = nil, spacing: CGFloat = 10, alignment: VerticalAlignment = .center) {
		self.title = title
		self.subTitle = subTitle
		self.spacing = spacing
		self.alignment = alignment
	}
	
	public var body: some View {
		HStack(alignment: alignment, spacing: spacing) {
			title.text
			Spacer()
			if let validSubTitle = subTitle {
				validSubTitle.text
			}
			
		}
	}
}

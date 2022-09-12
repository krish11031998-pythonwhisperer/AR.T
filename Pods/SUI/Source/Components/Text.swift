//
//  Text.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI

//MARK: - Head SubHead View

public struct HeaderSubHeadView: View {
	
	let title: RenderableText
	let subTitle: RenderableText?
	let spacing: CGFloat
	let alignment: Alignment
	
	public init(title: RenderableText, subTitle: RenderableText?, spacing: CGFloat = 10, alignment: Alignment = .leading) {
		self.title = title
		self.subTitle = subTitle
		self.spacing = spacing
		self.alignment = alignment
	}
	
	public var body: some View {
		VStack(alignment: alignment.horizontal, spacing: spacing) {
			title.text
			if let validSubtitle = subTitle {
				validSubtitle.text
			}
		}
	}
}


//MARK: -  Head Caption View

public struct HeaderCaptionView: View {
	
	let title: String
	let subTitle: String
	let spacing: CGFloat
	let alignment: Alignment
	
	public init(title: String, subTitle: String, spacing: CGFloat = 10, alignment: Alignment = .leading) {
		self.title = title
		self.subTitle = subTitle
		self.spacing = spacing
		self.alignment = alignment
	}
	
	public var body: some View {
		HStack(alignment: alignment.vertical, spacing: spacing) {
			title.styled(font: .boldSystemFont(ofSize: 15), color: .black).text
			Spacer()
			subTitle.styled(font: .systemFont(ofSize: 12, weight: .regular), color: .black).text
		}
	}
}

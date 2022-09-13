//
//  CommonComponents.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 06/09/2022.
//

import Foundation
import SwiftUI

//MARK: - EmptyView
public struct EmptyView: View {
	
	public init() {}
	
	public var body: some View {
		Color.clear
			.frame(size: .zero)
	}
}

//MARK: - ContainerViewModifier
private struct ContainerViewModifier:ViewModifier {
	
	var header: AnyView
	var footer: AnyView
	
	init(header: AnyView, footer: AnyView) {
		self.header = header
		self.footer = footer
	}
	
	func body(content: Content) -> some View {
		Section {
			content
		} header: { header } footer: { footer }
	}
}

//MARK: - View Extension
public extension View {
	
	func containerize(header: AnyView = EmptyView().anyView, footer: AnyView = EmptyView().anyView) -> some View {
		modifier(ContainerViewModifier(header: header, footer: footer))
	}
	
	@ViewBuilder func containerize(title: RenderableText,
								   subTitle: RenderableText? = nil,
								   vPadding: CGFloat = 15,
								   hPadding: CGFloat = 10,
								   spacing: CGFloat = 8,
								   alignment: Alignment = .leading,
								   style: HeadingType = .headSubhead) -> some View {
		
		if style == .headSubhead {
			containerize(header: HeaderSubHeadView(title: title, subTitle: subTitle, spacing: spacing, alignment: alignment.horizontal)
													.padding(.vertical, vPadding)
													.padding(.horizontal, hPadding)
													.fillWidth(alignment: alignment)
													.anyView, footer: EmptyView().anyView)
		} else if style == .headCaption {
			containerize(header: HeaderCaptionView(title: title, subTitle: subTitle, spacing: spacing, alignment: alignment.vertical)
													.padding(.vertical, vPadding)
													.padding(.horizontal, hPadding)
													.fillWidth(alignment: alignment)
													.anyView, footer: EmptyView().anyView)
		}
	}
}


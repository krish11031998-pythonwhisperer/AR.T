//
//  Navigation.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import Foundation
import SwiftUI

//MARK: - Navigation Modifier

fileprivate struct NavigationModifier: ViewModifier {
	
	@Binding var isActive: Bool
	
	init(isActive: Binding<Bool>) {
		self._isActive = isActive
	}
	
	func body(content: Content) -> some View {
		NavigationLink(isActive: $isActive) {
			content
		} label: {
			Color.clear
				.frame(size: .zero)
		}
	}
}

public extension View {
	
	func navigationLink(isActive: Binding<Bool>) -> some View {
		modifier(NavigationModifier(isActive: isActive))
	}
}

// MARK: - NavLink
public struct NavLink<Content: View>: View {
	
	@Binding var isActive: Bool
	let content: Content
	let leadingBarItem: AnyView?
	let trailingBarItem: AnyView?
	let titleView: AnyView?
	
	public init(isActive: Binding<Bool>,
		 leadingBarItem: (() -> AnyView)? = nil,
		 trailingBarItem: (() -> AnyView)? = nil,
		 titleView: (() -> AnyView)? = nil,
		 @ViewBuilder _ view: @escaping () -> Content)
	{
		self._isActive = isActive
		self.content = view()
		self.leadingBarItem = leadingBarItem?()
		self.trailingBarItem = trailingBarItem?()
		self.titleView = titleView?()
	}
	
	private var mainBody: some View {
		content
			.navigationBarItems(leading: leadingBarItem ?? defaultBackButton, trailing: trailingBarItem)
			.navigationBarBackButtonHidden(true)
			.navigationBarTitleDisplayMode(.inline)
	}
	
	public var body: some View {
		NavigationLink(isActive: $isActive) {
			if let customTitleView = titleView {
				mainBody
					.toolbar { ToolbarItem(placement: .principal) { customTitleView } }
			} else {
				mainBody
			}
		} label: {
			Color.clear.frame(size: .zero)
		}

	}
	
}

fileprivate extension NavLink {
	
	var defaultBackButton: AnyView {
		let config: CustomButtonConfig = .init(imageName: .back, size: .init(squared: 15), foregroundColor: .white, backgroundColor: .black)
		let button = CustomButton(config: config) {
			isActive.toggle()
		}
		return button.anyView
	}
}

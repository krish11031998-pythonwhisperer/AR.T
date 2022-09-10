//
//  Transition.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 07/09/2022.
//

import SwiftUI

//MARK: - CustomNavBar Style

public struct CustomNavBarStyling {
	var color: Color
	var style: CustomNavbarStyle
	
	public init(color: Color, style: CustomNavbarStyle) {
		self.color = color
		self.style = style
	}
}

public enum CustomNavbarStyle {
	case rounded(CGFloat)
}

extension CustomNavbarStyle  {
	
	var cornerRadius: CGFloat {
		switch self {
		case .rounded(let radius):
			return radius
		}
	}
	
}

//MARK: - CustomNavbarStylingModifier

private struct CustomNavbarStylingModifier: ViewModifier {
	let styling: CustomNavBarStyling
	
	init(styling: CustomNavBarStyling) {
		self.styling = styling
	}
	
	func body(content: Content) -> some View {
		switch styling.style {
		case .rounded(let radius):
			content
				.background(styling.color)
				.clipShape(RoundedRectangle(cornerRadius: radius))
		}
			
	}
}

public extension View {
	
	func customNavBarStyling(styling: CustomNavBarStyling) ->  some View {
		modifier(CustomNavbarStylingModifier(styling: styling))
	}
}

//MARK: - CustomNavBar

public  struct CustomNavBar<LeftBarItems: View, Title: View, RightBarItems: View>: View {
	let leftBarItems: () -> LeftBarItems
	let rightBarItems: () -> RightBarItems
	let titleView: () -> Title
	let navBarStyling: CustomNavBarStyling
	@State var size: CGSize = .zero
	
	public init(
		navBarStyling: CustomNavBarStyling = .init(color: .purple, style: .rounded(8)),
		@ViewBuilder leftBarItems:@escaping () -> LeftBarItems = { EmptyView() as! LeftBarItems },
		@ViewBuilder title: @escaping () -> Title,
		@ViewBuilder rightBarItems: @escaping () -> RightBarItems = { EmptyView() as! RightBarItems })
	{
		self.navBarStyling = navBarStyling
		self.leftBarItems = leftBarItems
		self.rightBarItems = rightBarItems
		self.titleView = title
	}
	
	var sizeCal: some View {
		GeometryReader { g -> AnyView in
			print("(DEBUG) g.size : ",g.size)
			return Color.clear.preference(key: SizePreferenceKey.self, value: g.size).anyView
		}
	}
	
	public var body: some View {
			HStack(alignment: .center, spacing: 10) {
				leftBarItems()
				Spacer()
				titleView()
				Spacer()
				rightBarItems()
			}
			.padding(.init(top: .safeAreaInsets.top, leading: 15, bottom: 15, trailing: 15))
			.frame(width: .totalWidth, alignment: .top)
			.background(
				GeometryReader { g -> AnyView in
					DispatchQueue.main.async {
						self.size = g.size
					}
					return Color.clear.anyView
				}
			)
			.customNavBarStyling(styling: navBarStyling)
			.preference(key: SizePreferenceKey.self, value: size)
	}
}



private struct CustomNavBar_Previews: PreviewProvider {
	
	@State static var paddingHeight: CGFloat = .zero
	
	 static var leftBar: some View {
		HStack(alignment: .center, spacing: 5) {
			CustomButton(config: .init(imageName: .back)) {
				print("(DEBUG) clicked on backButton")
			}
		}
	}
	
	static var rightBar: some View {
		HStack(alignment: .center, spacing: 5) {
			CustomButton(config: .init(imageName: .next)) {
				print("(DEBUG) clicked on nextButton")
			}
		}
	}

	static var titleView: some View {
		HStack(alignment: .center, spacing: 10) {
			ImageView(url: UIImage.testImage)
				.framed(size: .init(squared: 35), cornerRadius: 5, alignment: .center)
			HeaderSubHeadView(title: "Header", subTitle: "SubTitle", spacing: 10, alignment: .center).padding(.vertical,0)
		}
	}

	static var previews: some View {
		ZStack(alignment: .top) {
			ScrollView(.vertical, showsIndicators: false) {
				ForEach(0..<10) {
					"\($0)".text
				}
			}
			CustomNavBar {
				Self.leftBar
			} title: {
				Self.titleView
			} rightBarItems: {
				Self.rightBar
			}
			.background(Color.purple)
		}
		.edgesIgnoringSafeArea(.all)
	}
}

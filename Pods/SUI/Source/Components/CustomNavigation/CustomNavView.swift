//
//  CustomNavView.swift
//  StyleUI
//
//  Created by Krishna Venkatramani on 08/09/2022.
//

import SwiftUI

public struct CustomNavView<TitleView: View, LeftItem: View, RightItem: View, Content: View>: View {
	
	let titleView: TitleView
	let leftItem: LeftItem
	let rightItem: RightItem
	let content: Content
	let navBarStyling: CustomNavBarStyling
	@State var paddingHeight: CGFloat = .zero
	
	public init(navBarStyling: CustomNavBarStyling,
		 @ViewBuilder titleView: @escaping () -> TitleView = { EmptyView() as! TitleView },
		 @ViewBuilder leftItem: @escaping () -> LeftItem = { EmptyView() as! LeftItem},
		 @ViewBuilder rightItem: @escaping () -> RightItem = { EmptyView() as! RightItem },
		 @ViewBuilder content: @escaping () -> Content)
	{
		self.navBarStyling = navBarStyling
		self.titleView = titleView()
		self.leftItem = leftItem()
		self.rightItem = rightItem()
		self.content = content()
	}
	
	public var body: some View {
		ZStack(alignment: .top) {
			content
				.padding(.top, paddingHeight)
			CustomNavBar(navBarStyling: navBarStyling) {
				leftItem
			} title: {
				titleView
			} rightBarItems: {
				rightItem
			}
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarHidden(true)
		.onPreferenceChange(SizePreferenceKey.self) { newValue in
			paddingHeight = newValue.height
		}
    }
}

//struct CustomNavView_Previews: PreviewProvider {
//    static var previews: some View {
//        CustomNavView()
//    }
//}

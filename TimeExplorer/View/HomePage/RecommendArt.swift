//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI
import Combine
import SUI

//struct AVSData{
//    var img:String?
//    var title:String?
//    var subtitle:String?
//    var data:Any?
//}

struct RecommendArt: View {
	@EnvironmentObject var homePage: HomeViewModel
    var data:[CAData] = []
	init(attractions attr:[CAData]){
		self.data = attr
	}
    
    let cardSize:CGSize = .init(width: 235, height: 350)
	
    var body: some View{
		SlideCardView(data: data, itemSize: cardSize, leading: false, action: homePage.setArt(_:)) { data, selected in
			ZStack(alignment: .bottom) {
				SUI.ImageView(url: data.thumbnail)
					.framed(size: cardSize, cornerRadius: 0, alignment: .center)
				if selected {
					lightbottomShadow.fillFrame()
                    VStack {
                        (data.title ?? "No Heading")
                            .body1Bold()
                            .text
                            .lineLimit(3)
                            .multilineTextAlignment(.center)
                        CustomDivider()
                        (data.artistName ?? "No Heading")
                            .styled(font: .mediumItalic, color: .white, size: 15)
                            .text
                    }
                    .padding()
                    .transitionFrom(.bottom)
				}
			}
			.framed(size: cardSize, cornerRadius: 12, alignment: .bottomLeading)
		}

    }
}

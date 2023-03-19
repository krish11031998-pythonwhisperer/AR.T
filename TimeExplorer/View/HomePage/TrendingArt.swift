//
//  SideScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI
import SUI

struct TrendingArt: View {
	@EnvironmentObject var homePage: HomeViewModel
	var cardSize:CGSize = .init(width: .totalWidth.half.boundedTo(lower: 200, higher: 350), height: 350)
    var data:[CAData] = []
    
    init(data:[CAData]){
        self.data = data
    }
	
    var body: some View {
		CascadingCardStack(data: data, offFactor: .totalWidth * 0.25,pivotFactor: 5, action: homePage.setArt(_:)) { data, isSelected in
			ZStack(alignment: .bottomLeading) {
				SUI.ImageView(url: data.thumbnail)
					.framed(size: cardSize)
				if !isSelected {
					BlurView(style: .light)
				} else {
                    VStack(spacing: 8) {
                        (data.title ?? "No title").body1Bold(color: .white)
                            .text
                            .multilineTextAlignment(.center)
                        CustomDivider()
                        (data.artistName ?? "No Artist").styled(font: .mediumItalic, color: .white, size: 10)
                            .text
                            .multilineTextAlignment(.center)
                    }
                    .padding(10)
                    .fillWidth(alignment: .leading)
                    .transitionFrom(.bottom)
				}
			}.framed(size: cardSize, cornerRadius: 14, alignment: .center)
		}
    }
}

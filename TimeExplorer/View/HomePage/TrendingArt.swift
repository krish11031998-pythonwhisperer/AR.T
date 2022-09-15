//
//  SideScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI
import SUI

struct TrendingArt: View {
	var cardSize:CGSize = .init(width: .totalWidth.half.boundedTo(lower: 200, higher: 350), height: 350)
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
    
    var body: some View {
		CascadingCardStack(data: data, offFactor: .totalWidth * 0.25,pivotFactor: 5) { data, isSelected in
			if let data = data as? AVSData {
				ZStack(alignment: .bottomLeading) {
					SUI.ImageView(url: data.img)
						.framed(size: cardSize)
					if !isSelected {
						BlurView(style: .light)
					} else {
						(data.title ?? "No title").normal(size: 13, color: .white)
							.text
							.padding(10)
							.fillWidth(alignment: .leading)
					}
				}.framed(size: cardSize, cornerRadius: 14, alignment: .center)
			} else {
				Color.clear.frame(size: .zero)
			}
		}
    }
}

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
		CascadingCardStack(data: data, offFactor: .totalWidth * 0.25,pivotFactor: 5) { data in
			if let data = data as? AVSData {
				SUI.ImageView(url: data.img)
					.framed(size: cardSize, cornerRadius: 14, alignment: .center)
			} else {
				Color.clear.frame(size: .zero)
			}
		}
		.background(Color.red)
    }
}

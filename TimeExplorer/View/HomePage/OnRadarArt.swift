//
//  RecommendArt.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/06/2021.
//

import SwiftUI
import SUI

struct OnRadarArt: View {
    var data:[CAData] = []
    var tabSize:CGSize = .init(width: totalWidth * 0.7, height: totalHeight * 0.3)
    
    init(data:[CAData]){
        self.data = data
    }
	
	var cardSize: CGSize {
		.init(width: tabSize.width, height: tabSize.height.half - 10)
	}
    
    @ViewBuilder func card(idx: Int) -> some View {
		if idx >= 0 && idx < data.count {
			HStack(alignment: .top, spacing: 8) {
				SUI.ImageView(url: data[idx].thumbnail)
					.framed(size: .init(width: tabSize.width * 0.4, height: cardSize.height), cornerRadius: 10, alignment: .center)
				VStack(alignment: .leading, spacing: 10) {
					(data[idx].title ?? "XXX").body2Bold().text.lineLimit(2)
//					"BiddingPrice".normal(size: 12.5, color: .gray).text
                    (data[idx].artistName ?? "XXX").styled(font: .mediumItalic, color: .gray, size: 12).text
				}
				.padding(.vertical,8)
				.fillFrame(alignment: .topLeading)
			}
			.framed(size: cardSize)
		} else {
			Color.clear.frame(size: .zero)
		}
		
    }
    
    
    var grid:some View{
		let row = [GridItem(.fixed(tabSize.height.half), spacing: 0),GridItem(.fixed(tabSize.height.half), spacing: 0)]
        return LazyHGrid(rows: row, alignment: .center, spacing: 10) {
            ForEach(Array(self.data.enumerated()),id:\.offset) { data in
                card(idx: data.offset)
            }
        }
		.padding(.horizontal, 5)
		.fixedHeight(height: tabSize.height)
    }
    
    
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			self.grid
                .padding(.horizontal, 16)
		}
	}
}

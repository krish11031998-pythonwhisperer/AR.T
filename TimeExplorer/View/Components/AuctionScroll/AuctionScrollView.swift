//
//  AuctionScrollView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI
import SUI

struct AuctionArtView: View {
	var data:[AVSData] = []
	@Namespace var animation
	init(data:[AVSData]){
		self.data = data
	}
	
	var body: some View {
		ScrollView(.vertical, showsIndicators: false){
			Spacer().frame(height: .safeAreaInsets.top, alignment: .center)
			self.auctionCardView
			self.recentAdditions
			Spacer().frame(height: 150)
		}
		.background(Color.black)
		.edgesIgnoringSafeArea(.all)
		.frame(size: .init(width: .totalWidth, height: .totalHeight))
	}
}


extension AuctionArtView{
	
    var auctionCardView:some View{
        let data = self.data.count > 5 ? Array(self.data[10..<25] ): self.data
        return VStack(alignment: .center, spacing: 0) {
            ForEach(Array(data.enumerated()),id:\.offset) { _data in
                let data = _data.element
				AuctionCard(data: data,
							cardConfig: .init(bids: .init(bids: .random(in: 0...100), price: .random(in: 0...100), currency: "BTC"),
											  showBar: false,
											  cardStyling: .rounded(14),
											  cardSize:  .init(width: totalWidth, height: totalHeight * 0.75)))
            }
		}
		.containerize(header: "Recent Bids".normal(size: 25).text.padding().fillWidth(alignment: .leading).anyView)
    }
    
    var recentAdditions:some View{
        VStack(alignment: .center, spacing: 0) {
            MainText(content: "Recent Additions", fontSize: 25, color: .white, fontWeight: .semibold)
                .padding()
                .frame(width: totalWidth, alignment: .leading)
            PinterestScroll(data: Array(self.data[25...]), equalSize: true)
        }.padding(.vertical)
    }
}

struct AuctionArtView_Previews: PreviewProvider {

    static var previews: some View {
        AuctionArtView(data: Array(repeating: .init(img: test.thumbnail, title: test.title, data: test), count: 5))
    }
}

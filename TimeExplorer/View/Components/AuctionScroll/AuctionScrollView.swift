//
//  AuctionScrollView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI

struct AuctionArtView: View {
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
    var TrendingView:some View{
        VStack(alignment: .leading){
            MainText(content: "Top Trending", fontSize: 25, color: .white, fontWeight: .semibold)
                .padding()
//            TopArtScroll(data: self.data)
            AVScrollView(attractions: self.data)
        }
        .padding()
        .aspectRatio(contentMode: .fill)
    }
    
//    var post:[AVSData]{
//        return self.data
//    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            Spacer().frame(height: 50, alignment: .center)
            PersonalBidView(data: .init(repeating: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test), count: 4))
            self.TrendingView
            self.auctionCardView
            Spacer().frame(height: 150)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
}
}


extension AuctionArtView{
    var auctionCardView:some View{
        let data = self.data.count > 5 ? Array(self.data[0...5] ): self.data
        return VStack(alignment: .center, spacing: 0) {
            MainText(content: "Recent Additions", fontSize: 25, color: .white, fontWeight: .semibold)
                .padding()
                .frame(width: totalWidth, alignment: .leading)
            ForEach(Array(data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                AuctionCard(idx:_data.offset,data: data)
            }
        }.padding(.vertical)
    }
}

struct AuctionArtView_Previews: PreviewProvider {

    static var previews: some View {
        AuctionArtView(data: Array(repeating: .init(img: test.thumbnail, title: test.title, data: test), count: 5))
    }
}

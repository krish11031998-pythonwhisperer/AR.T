//
//  AuctionScrollView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI

struct AuctionArtView: View {
    var data:[AVSData] = []
    @Namespace var animation
    init(data:[AVSData]){
        self.data = data
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            Spacer().frame(height: 50, alignment: .center)
//            PersonalBidView(data: .init(repeating: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test), count: 4))
            self.QuickBidSection
//            self.TrendingView
            self.auctionCardView
            self.recentAdditions
            Spacer().frame(height: 150)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
}
}


extension AuctionArtView{
    
    
    var QuickBidSection:some View{
        VStack(alignment: .leading, spacing: 15){
            MainText(content: "Top Bids", fontSize: 25, color: .white, fontWeight: .semibold)
//                .padding(.vertical)
            HStack{
                Spacer()
                TopPostView(posts: Array(self.data[0..<10]), animation: self.animation){
                    print("Pressed View More")
                }
                Spacer()
            }
        }.padding(.horizontal).frame(width: totalWidth, alignment: .leading)
    }
    
    var TrendingView:some View{
        VStack(alignment: .leading){
            MainText(content: "Top Trending", fontSize: 25, color: .white, fontWeight: .semibold)
                .padding()
//            TopArtScroll(data: self.data)
            AVScrollView(attractions: Array(self.data[15..<25]))
        }
        .padding()
        .aspectRatio(contentMode: .fill)
    }
    
    var auctionCardView:some View{
        let data = self.data.count > 5 ? Array(self.data[10..<25] ): self.data
        return VStack(alignment: .center, spacing: 0) {
            MainText(content: "Recent Bids", fontSize: 25, color: .white, fontWeight: .semibold)
                .padding()
                .frame(width: totalWidth, alignment: .leading)
            ForEach(Array(data.enumerated()),id:\.offset) { _data in
                let data = _data.element
                AuctionCard(idx:_data.offset,data: data,size: .init(width: totalWidth, height: totalHeight * 0.75))
            }
        }.padding(.vertical)
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

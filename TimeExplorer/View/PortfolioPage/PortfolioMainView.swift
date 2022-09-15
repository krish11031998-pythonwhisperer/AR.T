//
//  PortfolioMainView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 16/07/2021.
//

import SwiftUI
import SUI

struct PortfolioMainView: View {
    
    @State var paintings:[CAData] = []
    @EnvironmentObject var mainStates:AppStates
	@StateObject var artAPI:ArtAPI = .init()
    @State var loadingText:String = "Loading..."
    @StateObject var SP:swipeParams = .init(100)
    
    func onAppear(){
        if let data = self.mainStates.getArt(limit: 50,skip: 400){
            self.parseData(data)
        }
    }
    
    func parseData(_ data:[CAData]){
        if !data.isEmpty{
            DispatchQueue.main.async {
                self.paintings = self.mainStates.CAAPI.artDatas
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
            self.onReceive(data: data)
        }
       
    }

    func onReceive(data : [CAData]){
        if !data.isEmpty{
            DispatchQueue.main.async {
                self.loadingText = "Received..."
                
            }
            let paintings = data
            DispatchQueue.main.async {
                self.paintings = paintings
                self.loadingText = "Assigned!"
                if self.mainStates.loading{
                    self.mainStates.loading = false
                }
                
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            if !self.paintings.isEmpty{
				artScrollView
					.containerize(title: "On View".normal(size: 35), alignment: .leading)
				PinterestScroll(data: Array(self.paintings[5...15]), equalSize: false)
					.containerize(header: "Items".normal(size: 25).text.padding(.horizontal,10).fillWidth(alignment: .leading).anyView)
            }else{
                MainText(content: self.loadingText, fontSize: 25)
            }
        }
		.padding(.top, .safeAreaInsets.top)
        .frame(width: totalWidth, alignment: .leading)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
		.navigationBarHidden(true)
    }
}


extension PortfolioMainView{
	
	var cardSize: CGSize { .init(width: 200, height: 300) }
	
    var artScrollView:some View{
		SlideCardView(data: Array(paintings[0..<5]), itemSize: .init(width: 200, height: 300), leading: true) { data, isSelected in
			AuctionCard(data: data,
						cardConfig: .init(bids: nil,
										  showBar: false,
										  cardStyling: .rounded(14),
										  cardSize:  cardSize))
		}
    }
    
    var chartView:some View{
        HStack(alignment: .center,spacing:10){
            WeekBarChart(header: "Views", values: [25,76,100,80,12,54,32])
            CircleChart(percent: 45, header: "Likes")
        }.padding(.horizontal)
        
    }
    
}


struct PortfolioMainView_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioMainView()
    }
}

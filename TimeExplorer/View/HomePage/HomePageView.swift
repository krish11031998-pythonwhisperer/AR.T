//
//  HomePage.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI
import SUI

private enum HomeSection: String {
	case highlight = "Hightlight of the Day"
	case trending = "Trending"
	case onRadar = "On Your Radar"
	case recommended = "Recommended Bids"
	case recent = "Recent"
	case genre = "Genre"
	case artists = "Artists"
}

struct HomePageView: View {
    @EnvironmentObject var mainStates:AppStates
    @StateObject var CAPI:CAAPI = .init()
    @Namespace var animation
    @State var chosenSection:String = ""
    @State var showSection:Bool = false
    @State var showArt:Bool = false
    @State var posts:[AVSData] = []
    let target_limit:Int = 100
//    @State var loading:Bool = true
    
    func header(dim:CGSize) -> some View{
            HStack(alignment: .center, spacing: 10) {
                VStack(alignment: .leading, spacing: 10, content: {
                    MainText(content: "Hi,", fontSize: 30, color: .white, fontWeight: .semibold, style: .normal)
                    MainText(content: "Krishna", fontSize: 45, color: .white, fontWeight: .semibold, style: .normal)
                })
                Spacer()
                ImageView(img: nil, width: totalWidth * 0.2, height: totalWidth * 0.2, contentMode: .fill, alignment: .center)
                    .clipShape(Circle())
            }.padding().frame(height: dim.height * 0.75, alignment: .center)
    }
    
    func topPostAction(){
        withAnimation(.easeInOut) {
            self.showArt = true
        }
        
    }

    
    func onAppear(){
        if let data = self.mainStates.getArt(limit: target_limit){
            self.parseData(data)
        }
    }
    
    func parseData(_ data:[CAData]?){
        guard let data = data else {return}
        if !data.isEmpty{
            let _data = data.compactMap({$0.images?.web?.url != nil ? AVSData(img: $0.images?.web?.url, title: $0.title, data: $0) : nil})
            DispatchQueue.main.async {
                self.posts = _data
                print("home page data : ",data.count)
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
    }
    
    @ViewBuilder private func subView(section: HomeSection) -> some View {
		switch section {
		case .highlight:
			HighlightView(data: Array(self.posts[45..<50]))
		case .trending:
			TrendingArt(data: Array(self.posts[1..<10]))
		case .onRadar:
			OnRadarArt(data: Array(self.posts[20..<30]))
		case .recommended:
			RecommendArt(attractions: Array(self.posts[30..<40]))
		case .recent:
			BidArt(data: Array(self.posts[30..<40]))
		case .genre:
			GenreView(genreData: Array(self.posts[40..<45]))
		case .artists:
			artistArtView(data: Array(self.posts[60...]))
		}
    }

	private var sections: [HomeSection] = [.highlight, .trending, .onRadar, .recommended, .recent, .genre]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
			VStack(alignment: .center, spacing: 10) {
				self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
				if !self.posts.isEmpty {
					ForEach(sections, id:\.rawValue) { section in
						subView(section: section)
							.containerize(header: section.rawValue.normal(size: 24).text.padding(5).fillWidth(alignment: .leading).anyView)
					}
				}
			}
			.fixedWidth(width: .totalWidth)
			.padding(.bottom, .safeAreaInsets.bottom + 100)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
    }
}

extension HomePageView{
    
    func BidArt(data: [AVSData])-> some View{
		let h: CGFloat = 250
		let w: CGFloat = 150
		let cardSize: CGSize = .init(width: w, height: h - 10)
		let rows = [GridItem.init(.adaptive(minimum: h - 10, maximum: h - 10), spacing: 10, alignment: .center)]
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                ForEach(Array(data.enumerated()),id:\.offset) { elData in
					ArtViewCard(data: elData.element, cardSize: cardSize)
                }
            }
			.padding(.horizontal, 5)
            .frame(height:h * 2,alignment:.leading)
        }
    }
    
    func artistArtView(data:[AVSData]) -> some View{
        let f = Int(floor(Double(data.count/3)))
        let view = VStack(alignment: .center, spacing: 20) {
            ForEach(Array(0..<f),id: \.self) { i in
                let start = Int(i) * 3
                let end = Int(i + 1) * 3
                let arr_data = i == f ? Array(data[start...]) : Array(data[start..<end])

                ArtistArtView(data: arr_data)
                Divider().frame(width: totalWidth * 0.8, height: 5, alignment: .center)
            }
        }
        
        return view
    }
    
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

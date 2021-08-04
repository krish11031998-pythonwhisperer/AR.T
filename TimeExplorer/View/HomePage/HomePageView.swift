import SwiftUI

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
            }.padding().frame(width: dim.width, height: dim.height * 0.75, alignment: .center)
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

    func subSectionHeader(title:String) -> some View{
        return MainText(content: title, fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
            .padding(.horizontal)
            .frame(width: totalWidth, alignment: .leading)
    }
    
    func subView(title:String) -> AnyView{
        var view:AnyView = AnyView(Color.clear)
        switch title{
            case "Featured Art": view = AnyView(FeaturedArt(art: posts.first ?? asm).padding(.bottom,10))
            case "Trending": view = AnyView(TopArtScroll(data: Array(self.posts[1..<10])))
            case "On Your Radar": view = AnyView(RecommendArt(data: Array(self.posts[20..<30])))
            case "Recent" : view = AnyView(AVScrollView(attractions: Array(self.posts[30..<40]),haveTimer: true))
            case "Genre": view = AnyView(AllArtView(genreData: Array(self.posts[40..<45])))
            case "Hightlight of the Day": view = AnyView(HighlightView(data: Array(self.posts[45..<50])))
            case "Recommended Bids" : view = AnyView(self.BidArt(data: Array(self.posts[50..<60])))
            case "Artists": view = AnyView(self.artistArtView(data: Array(self.posts[60...])))
            default: break
        }
        return view
    }
//    var sections:[String] = ["Featured Art","Trending","Hightlight of the Day","On Your Radar","Recommended Bids","Recent","Genre","Artists"]
    var sections:[String] = ["Hightlight of the Day","Trending","On Your Radar","Recommended Bids","Recent","Genre","Artists"]
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
            if !self.mainStates.loading && !self.posts.isEmpty && self.posts.count == self.target_limit{
                ForEach(self.sections, id:\.self) { title in
                    self.subSectionHeader(title: title).padding(.top,5)
                    self.subView(title: title)
                        .padding(.bottom,5)
                }
            }
            Spacer().frame(height: 200)
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
    }
}

extension HomePageView{
    
    func RecentArtView(data:[AVSData]) ->some View{
        let w = totalWidth * 0.5 - 10
        
        return LazyVGrid(columns: [GridItem(.adaptive(minimum: w, maximum: w), spacing: 10, alignment: .center)], alignment: .center, spacing: 10) {
            ForEach(Array(data.enumerated()),id: \.offset) { _data in
                let d = _data.element
                ImageView(url: d.img, heading: d.title, width: w, height: totalHeight * 0.35, contentMode: .fill, alignment: .center, isPost: true, headingSize: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
        }.padding(.bottom)
    }
    
    
    func BidArt(data:[AVSData])-> some View{
        let h = totalHeight * 0.65
        let w = totalWidth * 0.5
        let cardSize = CGSize(width:(w * 0.85 - 20),height: (h * 0.5 - 20))
        let rows = [GridItem.init(.adaptive(minimum: h * 0.5 - 20, maximum: h * 0.5 - 20), spacing: 10, alignment: .center)]
        let containerW = (cardSize.width + 20) * CGFloat(data.count) * 0.5
        return ScrollView(.horizontal, showsIndicators: false) {
            LazyHGrid(rows: rows, alignment: .center, spacing: 10) {
                ForEach(Array(data.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    ImageView(url: data.img, heading: data.title, width: cardSize.width, height: cardSize.height, contentMode: .fill,alignment: .center, headingSize: 10, quality: .lowest)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .padding(.leading,idx == 0 ? 10 : 0)
                }
            }
            .frame(width:containerW,height:h,alignment:.leading)
        }
    }
    
    func artistArtView(data:[AVSData]) -> some View{
        let f = Int(floor(Double(data.count/3)))
        let view = VStack(alignment: .center, spacing: 10) {
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

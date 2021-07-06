import SwiftUI

struct HomePageView: View {
    @EnvironmentObject var mainStates:AppStates
//    @StateObject var IMD:ImageDownloader = .init(mode: "multiple")
    @StateObject var CAPI:CAAPI = .init()
    @Namespace var animation
    @State var chosenSection:String = ""
    @State var showSection:Bool = false
    @State var showArt:Bool = false
    @State var posts:[AVSData] = []
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
        if !self.mainStates.CAAPI.artDatas.isEmpty{
            self.parseData(self.mainStates.CAAPI.artDatas)
        }else{
            self.mainStates.CAAPI.getBatchArt()
        }
    }
    
    func parseData(_ data:[CAData]){
        if !data.isEmpty{
            let _data = data.compactMap({$0.images?.web?.url != nil ? AVSData(img: $0.images?.web?.url, title: $0.title, data: $0) : nil})
            DispatchQueue.main.async {
                self.posts = _data
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    
    
    func subView(title:String) -> some View{
        var view = AnyView(Color.clear.frame(width: 0, height: 0, alignment: .center))
        let posts = self.posts.count < 10 ? self.posts : Array(self.posts[0...9])
        switch (title) {
            case "Trending Art": view = AnyView(TopArtScroll(data: Array(self.posts[1..<10])))
//            case "Trending Art": view = AnyView(AVScrollView(attractions: Array(self.posts[1..<10])))
            case "Featured Art": view = AnyView(FeaturedArt(art: posts.first ?? asm))
            case "Highlights" : view = AnyView(AllArtView(genreData:  Array(self.posts[10..<20])))
            case "Recent" : view = AnyView(PinterestScroll(data: Array(self.posts[20..<30]),equalSize: true))
//            case "Recent" : view = AnyView(TopArtScroll(data: Array(self.posts[20..<30])))
            case "Recommended", "Ones to Check Out" : view = AnyView(RecommendArt(data: Array(self.posts[30..<40])))
            case "Artists" : view = AnyView(ArtistView(data: posts))
            default: break;
        }
        return
            Group{
                MainText(content: title, fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                    .padding(.horizontal)
                    .frame(width: totalWidth, alignment: .leading)
//                }
                view
            }
        
    }
    
    
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            LazyVStack(spacing: 10){
                self.header(dim: .init(width: totalWidth, height: totalHeight * 0.35))
                if !self.mainStates.loading && !self.posts.isEmpty{
                    self.subView(title: "Featured Art")
                    self.subView(title: "Recommended")
                    self.subView(title: "Trending Art")
                    self.subView(title: "Highlights")
                    //                    self.subView(title: "Recent")
                    self.subView(title: "Ones to Check Out")
                    self.subView(title: "Artists")
                    self.subView(title: "Recent")
                }
                Spacer().frame(height: 200)
                
            }
        }
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.CAAPI.$artDatas, perform: self.parseData)
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
    
}



struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}

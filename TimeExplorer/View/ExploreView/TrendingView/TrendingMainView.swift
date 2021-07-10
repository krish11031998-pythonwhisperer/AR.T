//
//  TourViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/01/2021.
//
import SwiftUI
import FirebaseFirestoreSwift
enum Swipe{
    case up
    case down
}

enum CardType:String{
    case tour = "Tour"
    case post = "Post"
    case blog = "Blog"
    case art = "Art"
}
struct TrendingCardData:Identifiable{
    var id:Int?
    var image:String?
    var vid_url:String?
    var username:String?
    var userImg:String?
    var mainText:String?
    var type:CardType
    var data:Any?
    var location:String?
    var date:Date
    var mainImage:UIImage?
}

struct TrendingData{
    var type:CardType
    var data:Any

    func parseVisualData() -> TrendingCardData?{
        var res:TrendingCardData? = nil
        let _data = self
        switch(self.type){
            case .tour:
                guard let data = _data.data as? TourData else {return res}
                res = .init(image: data.mainImage, username: data.user, mainText: data.mainTitle, type: .tour,data:data,location:data.location,date:data.date ?? Date())
            case .blog:
                guard let data = _data.data as? BlogData else {return res}
                res = .init(image: data.image?.first, username: data.user, mainText: data.headline, type: .blog,data:data,date:data.date ?? Date())
            case .post:
                guard let data = _data.data as? PostData else {return res}
                res = .init(image: data.image?.first, vid_url: data.video?.first, username: data.user, mainText: data.caption, type: .post,data:data,date:data.date ?? Date())
            case .art:
                guard let data = _data.data as? ArtData else {return res}
                res = .init(image: data.thumbnail, vid_url:data.main_vid_url, mainText: data.title, type: .art, data: data,date: data.date)
        }
        return res
    }
}
struct TrendingMainView: View {
    @Binding var changeTab:String
    @State var data:[TrendingCardData] = []
    @Binding var showTrending:Bool
    @EnvironmentObject var mainStates:AppStates
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    @State var oneCall:Bool = false
    @State var showTour:Bool = false
    @State var showPost:Bool = false
    @State var showBlog:Bool = false
    @State var showArt:Bool = false

    @State var selectedcard:TrendingCardData = .init(type: .post, date: .init())
    var type:String = ""
    var types:[String] = []
    var dispatchGroup:DispatchGroup = .init()
    @Binding var loadTours:Bool


    init(tab:Binding<String>,tabstate:Binding<Bool>,showTrending:Binding<Bool>?, type:String = "all"){
        self._changeTab = tab
        self._loadTours = tabstate
        self._showTrending = showTrending != nil ? showTrending! : Binding.constant(false)
        self.type = type
    }

    init(tab:Binding<String>,tabstate:Binding<Bool>,showTrending:Binding<Bool>?, types:[String] = []){
        self._changeTab = tab
        self._loadTours = tabstate
        self._showTrending = showTrending != nil ? showTrending! : Binding.constant(false)
        self.types = types
    }

    var currentCard:TrendingCardData{
        get{
            if self.swiped >= 0 && self.swiped < self.data.count{
                return self.data[self.swiped]
            }
            return self.selectedcard
        }
    }
   
    
    func onChanged(value:DragGesture.Value){
        let height = value.translation.height
        let val = value.location.y - value.startLocation.y
        self.offset = val
    }
    
    func onEnded(value:DragGesture.Value){
//        let height = value.translation.height
        let height = self.offset
        var val:Int = 0
        if abs(height) > 100{
            val = height > 0 ? -1 : 1
            if self.swiped + val <= self.data.count - 1 && self.swiped + val >= 0{
                self.swiped += val
            }
        }
        self.offset = 0
    }
    
    var swipedOffset:CGFloat{
        return -CGFloat(self.swiped > 0 ? 1 : 0) * totalHeight
    }

    func onAppear(){
        self.mainStates.loading = true
        if !self.mainStates.showTab{
            self.mainStates.showTab = true
        }
        self.downloadArtPainting()
    }
    
    func getCAAPIData(){
        if !self.mainStates.CAAPI.artDatas.isEmpty{
            self.parseData(self.mainStates.CAAPI.artDatas)
        }else{
            self.mainStates.CAAPI.getBatchArt()
        }
    }
    
    func downloadArtPainting(){
        FirebaseAPI.firebase_shared.getTopItems(limit: 5, collectionName: "paintings") { qs, err in
            guard let qs = qs else {print(err?.localizedDescription ?? "Error");return}
            if let arts = ArtAPI.shared.parseQueryDocuments(q: qs)?.compactMap({$0.parseVisualData()})
            {
                if arts.isEmpty {return}
                DispatchQueue.main.async {
                    self.data = arts
                }
                self.getCAAPIData()
            }
        }
    }
    
    
    func parseData(_ data:[CAData]){
        
        if !data.isEmpty{
            let _data = data.compactMap({ TrendingCardData(image: $0.thumbnail, username: $0.artistName, mainText: $0.title, type: .art, data: ArtData(date: Date(), title:$0.title ?? "No Title", introduction: $0.wall_description ?? "Description",infoSnippets: $0.PaintingInfo, painterName: $0.artistName, thumbnail: $0.thumbnail,model_img: $0.original), date: Date())})
            DispatchQueue.main.async {
                self.data.append(contentsOf: _data)
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    
    var navigationLinktoTour:some View{
        get{
            let data = self.currentCard.data as? TourData
            return NavigationLink(destination: TourVerticalCardView(data ?? .init(), self.$showTour), isActive: $showTour) {
                MainText(content: "", fontSize: 10)
            }.hidden()

        }
    }


    func updateViewState(){
        switch(self.currentCard.type){
            case .tour:
                self.showTour.toggle()
                break
            case .blog:
                self.showBlog.toggle()
                break
            case .post:
                self.showPost.toggle()
                break
            case .art:
                self.showArt.toggle()
                break
            default:
                print("Nothing to see here folks")
                break
        }
    }


    func ContentScroll(w:CGFloat,h:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.data.enumerated()),id:\.offset){_data in
                let idx = _data.offset
                let data = _data.element
                if idx >= self.swiped - 1 && idx <= self.swiped + 1{
                    TrendingMainCard(idx, data, w, h,handler: self.updateViewState)
                        .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
                }
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .animation(.easeInOut)
        .offset(y: self.swipedOffset + self.offset)
    }
    

    var body: some View {
        ZStack(alignment:.top){
            Color.black
            if !self.data.isEmpty && !self.mainStates.loading{
                self.ContentScroll(w: totalWidth, h: totalHeight)
                if self.showTour{
                    TourVerticalCardView(self.currentCard.data as? TourData ?? .init(), self.$showTour)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                if let data = self.currentCard.data as? ArtData,self.showArt{
                    ArtScrollMainView(data: data,showArt: $showArt)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .environmentObject(self.mainStates)
                }
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .onAppear(perform: self.onAppear)
//        .onReceive(self.mainStates.CAAPI.$artDatas, perform: self.parseData)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

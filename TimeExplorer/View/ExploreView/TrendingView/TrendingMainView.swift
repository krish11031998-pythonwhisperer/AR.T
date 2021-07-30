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
    @StateObject var SP:swipeParams = .init(0, 0, 100, type: .Stack)
    @State var showArt:Bool = false

    @State var selectedcard:TrendingCardData = .init(type: .post, date: .init())
    var dispatchGroup:DispatchGroup = .init()
    @Binding var loadTours:Bool


    init(tab:Binding<String>,tabstate:Binding<Bool>,showTrending:Binding<Bool>?){
        self._changeTab = tab
        self._loadTours = tabstate
        self._showTrending = showTrending != nil ? showTrending! : Binding.constant(false)
    }

    var currentCard:TrendingCardData{
        get{
            if self.SP.swiped >= 0 && self.SP.swiped < self.data.count{
                return self.data[self.SP.swiped]
            }
            return self.selectedcard
        }
    }
   
    var swipedOffset:CGFloat{
        return -CGFloat(self.SP.swiped > 0 ? 1 : 0) * totalHeight
    }

    func onAppear(){
        self.mainStates.loading = true
        if !self.mainStates.showTab{
            self.mainStates.showTab = true
        }
        self.downloadArtPainting()
    }
    
    func getCAAPIData(){
        if let data = self.mainStates.getArt(limit: 50,skip: 50){
            self.parseData(data)
        }
    }
    
    func downloadArtPainting(){
        if self.mainStates.AAPI.arts.isEmpty{
            self.mainStates.AAPI.getArts(_name: self.mainStates.userAcc.username)
        }else{
            self.receiveArt(arts: self.mainStates.AAPI.arts)
        }
        self.getCAAPIData()
    }

    func receiveArt(arts:[ArtData]){
        if !arts.isEmpty{
            let _art = arts.compactMap({$0.parseVisualData()})
            DispatchQueue.main.async {
                self.data = _art
            }
        }
    }
    
    
    
    func parseData(_ data:[CAData]){
        
        if !data.isEmpty{
            let _data = data.compactMap({ TrendingCardData(image: $0.thumbnail, username: $0.artistName, mainText: $0.title, type: .art, data: ArtData(date: Date(), title:$0.title ?? "No Title", introduction: $0.wall_description ?? "Description",infoSnippets: $0.PaintingInfo, painterName: $0.artistName, thumbnail: $0.thumbnail,model_img: $0.original), date: Date())})
            DispatchQueue.main.async {
                self.data.append(contentsOf: _data)
                self.SP.end = self.data.count - 1
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    

    func updateViewState(){
        self.showArt.toggle()
    }


    func ContentScroll(w:CGFloat,h:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.data.enumerated()),id:\.offset){_data in
                let idx = _data.offset
                let data = _data.element
                if idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1{
                    TrendingMainCard(idx, data, w, h,handler: self.updateViewState)
                        .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
                }
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .animation(.easeInOut)
        .offset(y: self.swipedOffset + self.SP.extraOffset)
    }
    

    var body: some View {
        ZStack(alignment:.top){
            Color.black
            if !self.data.isEmpty && !self.mainStates.loading{
                self.ContentScroll(w: totalWidth, h: totalHeight)
                if let data = self.currentCard.data as? ArtData,self.showArt{
                    ArtScrollMainView(data: data,showArt: $showArt)
                        .environmentObject(self.mainStates)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.AAPI.$arts, perform: self.receiveArt(arts:))
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
        .onChange(of: self.SP.swiped, perform: { swiped in
            print("swiped : \(swiped)")
        })
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

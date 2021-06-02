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
    @StateObject var ToAPI:TourAPI = .init()
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
            let swiped = self.swiped ?? 0
            if swiped >= 0 && swiped < self.data.count{
                return self.data[swiped]
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

    func getTrendingItems(){
        dispatchGroup.enter()
        let targetCollection = self.types.isEmpty ? ["posts","tours","blogs","paintings"].filter({self.type == "all" ? true : $0 == self.type}) : self.types
        for collection in targetCollection{
            FirebaseAPI.firebase_shared.getTopItems(limit: 5, collectionName: collection) { (qs, err) in
                guard let qs = qs else {return}
                print("qs (\(collection)) : ",qs.documents.count)
                switch(collection){
                case "posts":
                    if let posts = PostAPI.shared.parseQueryDocuments(q: qs)?.compactMap({$0.parseVisualData()}){
                        DispatchQueue.main.async {
                            self.data.append(contentsOf: posts)
                        }
                    }
                case "tours":
                    let tours = TourAPI.shared.parseTours(qs: qs).compactMap({$0.parseVisualData()})
                    DispatchQueue.main.async {
                        self.data.append(contentsOf: tours)
                    }

                case "blogs":
                    if let blogs = BlogAPI.shared.parseQueryDocuments(q: qs)?.compactMap({$0.parseVisualData()}){
                        DispatchQueue.main.async {
                            self.data.append(contentsOf: blogs)
                        }
                    }
                case "paintings":
                    if let arts = ArtAPI.shared.parseQueryDocuments(q: qs)?.compactMap({$0.parseVisualData()})
                    {
                        DispatchQueue.main.async {
                            self.data.append(contentsOf: arts)
                        }
                    }
                default:
                    break
                }
            }
        }
        dispatchGroup.leave()

    }

    var navigationLinktoTour:some View{
        get{
            let data = self.currentCard.data as? TourData
            return NavigationLink(destination: TourVerticalCardView(data ?? .init(), self.$showTour), isActive: $showTour) {
                MainText(content: "", fontSize: 10)
            }.hidden()

        }
    }

    var navigationLinkToPost:some View{
        get{
            let data = self.currentCard.data as? PostData ?? .init(caption: "")
            let image:UIImage = UIImage.loadImageFromCache(data.image?.first)
            return UVDetail(profilePic: .stockImage, userName: data.user ?? "", post: data, showPost: $showPost,postImg: image)
        }
    }

    var navigationLinkToBlog:some View{
        get{
            let data = self.currentCard.data as? BlogData ?? .init()
            let image:UIImage = UIImage.loadImageFromCache(data.image?.first)
            let blogViewContainer = LargeBlogCard(blog: data, firstImage: image, showBlogPost: $showBlog)
            return blogViewContainer
        }
    }

    func onAppear(){
        if self.data.isEmpty && !self.loadTours && !self.oneCall{
            self.getTrendingItems()
            self.oneCall.toggle()
            dispatchGroup.notify(queue: .main) {
                print("self.data.count : ",self.data.count)
                if self.mainStates.loading{
                    self.mainStates.loading.toggle()
                }
            }
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
//                if idx >= self.swiped - 1 && idx <= self.swiped + 1{
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
            self.ContentScroll(w: totalWidth, h: totalHeight)
            if self.showTour{
                TourVerticalCardView(self.currentCard.data as? TourData ?? .init(), self.$showTour)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            if self.showPost{
                self.navigationLinkToPost
            }
            if self.showBlog{
                self.navigationLinkToBlog
            }
            if self.showArt{
//                ArtView(data: self.currentCard.data as? ArtData ?? test, showArt: $showArt)
                ArtScrollMainView(data: self.currentCard.data as? ArtData ?? test,showArt: $showArt)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .environmentObject(self.mainStates)
            }
            
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .onAppear(perform: self.onAppear)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

//
//  TourMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/03/2021.
//

import SwiftUI

struct TourMainView: View {
    @Binding var changeTab:String
    @StateObject var ToAPI:TourAPI = .init()
    @State var data:[TrendingCardData] = []
    @State var SP:swipeParams = .init()
    @Binding var showTrending:Bool
    @EnvironmentObject var mainStates:AppStates
    @State var showTourSummary:Bool = false
    @State var clipCorners:Bool = false
    @StateObject var VSP:VCarouselParams = .init()
    @State var swipe:Swipe = .up
    @State var oneCall:Bool = false
    @State var showTour:Bool = false
    @State var showPost:Bool = false
    @State var showBlog:Bool = false
    
    @State var selectedcard:TrendingCardData = .init(type: .post, date: .init())
    var type:String
    var dispatchGroup:DispatchGroup = .init()
    @Binding var loadTours:Bool
    
    
    init(tab:Binding<String>,tabstate:Binding<Bool>,showTrending:Binding<Bool>?, type:String = "all"){
        self._changeTab = tab
        self._loadTours = tabstate
        self._showTrending = showTrending != nil ? showTrending! : Binding.constant(false)
        self.type = type
    }
    
//    func resetStates(){
//        self.VSP.detail_one_opacity = 1.0
//        self.VSP.detail_two_opacity = 0
//        self.VSP.card_one_Height = totalHeight
//        self.VSP.card_two_Height = 0
//        self.clipCorners = false
//        self.VSP.blur_one_Radius = 0
//        self.VSP.blur_two_Radius = 0
//        self.VSP.scale_two = 1.0
//        self.VSP.scale_one = 1.0
//    }
    
    var countCheck:Bool{
        get{
            return self.SP.swiped < self.data.count - 1 && self.SP.swiped >= 0
        }
    }
    
    var currentCard:TrendingCardData{
        get{
            if self.SP.swiped >= 0 && self.SP.swiped < self.data.count{
                return self.data[self.SP.swiped]
            }
            return self.selectedcard
        }
    }
    
//    func onEnded(_ value:CGFloat){
//        var val:Int = 0
//        var halfHeight = totalHeight * 0.05
//        if value < 0 && abs(value) >= halfHeight && self.countCheck{
//            val += 1
//        }else if value > 0 && abs(value) >= halfHeight && self.SP.swiped > 0{
//            val -= 1
//        }
//        withAnimation(.easeInOut) {
//            self.SP.swiped += val
//            self.SP.extraOffset = 0
//        }
//    }
    
    func onEnded(_ value:CGSize){
        if self.showTourSummary{
            return
        }
        var width = value.width
        var height = value.height
        if(abs(width) > abs(height)){
            self.SP.extraOffset = 0
            self.changeTab = "posts"
        }else{
            var val:Int = 0
            var halfHeight = totalHeight * 0.05
            if height < 0 && abs(height) >= halfHeight && self.countCheck{
                val += 1
            }else if height > 0 && abs(height) >= halfHeight && self.SP.swiped > 0{
                val -= 1
            }
            withAnimation(.easeInOut) {
                self.SP.swiped += val
                self.SP.extraOffset = 0
            }
        }
    }

    func onChanged(_ value:CGSize){
        if self.showTourSummary{
            return
        }
        var width = value.width
        var height = value.height
        if abs(width) > abs(height){
            self.SP.extraOffset = width
        }else{
            self.swipe = height < 0 ? .up : .down
//            if !countCheck && self.swipe == .up || self.SP.swiped < 0 && self.swipe == .down{
//                return
//            }
            self.SP.extraOffset = height
        }
        
    }
    
    func getTrendingItems(){
        dispatchGroup.enter()
        var res:[TrendingCardData] = []
        for collection in ["posts","tours","blogs"].filter({self.type == "all" ? true : $0 == self.type}){
            FirebaseAPI.firebase_shared.getTopItems(limit: -1, collectionName: collection) { (qs, err) in
                guard let qs = qs else {return}
                switch(collection){
                case "posts":
                    if let posts = PostAPI.shared.parseQueryDocuments(q: qs)?.compactMap({TrendingData(type: .post, data: $0 as Any)}).compactMap({$0.parseVisualData()}){
                        DispatchQueue.main.async {
                            self.data.append(contentsOf: posts)
                        }
                    }
                case "tours":
                    let tours = TourAPI.shared.parseTours(qs: qs).compactMap({TrendingData(type: .tour, data: $0 as Any)}).compactMap({$0.parseVisualData()})
                    DispatchQueue.main.async {
                        self.data.append(contentsOf: tours)
                    }
//                    self.data.append(contentsOf: tours)
                    
                case "blogs":
                    if let blogs = BlogAPI.shared.parseQueryDocuments(q: qs)?.compactMap({TrendingData(type: .blog, data: $0 as Any)}).compactMap({$0.parseVisualData()}){
                        print("blogs : \(blogs.count)")
                        DispatchQueue.main.async {
                            self.data.append(contentsOf: blogs)
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
    
    func VCardStack(width:CGFloat,height:CGFloat) -> some View{
        let current = self.SP.swiped
        let next = current + 1
        let prev = current - 1
        
        return VStack(alignment:.center,spacing:10){
            ForEach(Array(self.data.enumerated()),id: \.offset){ _data in
                let idx = _data.offset
                let data = _data.element
//                let cardOffset = CGFloat(idx - current) * totalHeight
                if idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1{
                    TrendingMainCard(data, width, height, showSummary: self.$showTourSummary, showTour: self.$showTour, showBlog: self.$showBlog, showPost: self.$showPost)
                        .offset(y: self.SP.extraOffset)
                }
            }
        }.onChange(of: self.SP.extraOffset) { (value) in
            print("ExtraOffset Value  : \(value)")
        }
    }
    
    var body: some View {
        GeometryReader{g in
            let width:CGFloat = g.frame(in: .local).width
            let height:CGFloat = g.frame(in:.local).height
            let current = self.SP.swiped
            let next = current + 1
            let prev = current - 1
            ZStack(alignment:.top){
                if !self.showBlog && !self.showPost && !self.showTour{
                    self.VCardStack(width: width, height: height)
                }
                VStack(alignment: .leading){
                    Spacer()
                    HStack{
                        Spacer()
                        Button {
                            print("Clicked Viewing : \(self.currentCard.type)")
                            switch(self.currentCard.type){
                            case .tour:
                                if !self.showTourSummary{
                                    self.showTourSummary.toggle()
                                }else{
                                    self.showTour.toggle()
                                }
                                break
                            case .blog:
                                self.showBlog.toggle()
                                break
                            case .post:
                                self.showPost.toggle()
                                break
                            default:
                                print("Nothing to see here folks")
                                break
                            }
                        } label: {
                            let label = self.currentCard.type == .tour ? !self.showTourSummary ? "Tour Summary" : "Start Tour" : "View"
    //                        let label = "View"
                            MainText(content: label, fontSize: 15, color: .black,fontWeight: .semibold,style: .normal)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
                        }

                    }.padding(20)
                }.padding(.vertical,height * 0.05)
                if self.showTour{
                    TourVerticalCardView(self.currentCard.data as? TourData ?? .init(), self.$showTour)
                }
                if self.showPost{
                    self.navigationLinkToPost
                }
                if self.showBlog{
                    self.navigationLinkToBlog
                }

            }.frame(width: width, height: height, alignment: .top).edgesIgnoringSafeArea(.all)
            .gesture(DragGesture()
                        .onChanged({ (value) in
                            self.onChanged(value.translation)
                        })
                        .onEnded({ (value) in
                            self.onEnded(value.translation)
                        })
            )
        }.frame(width: totalWidth, height: totalHeight)
        .onAppear {
            if(self.mainStates.showTab){
                self.mainStates.showTab = false
            }
            if self.data.isEmpty && !self.loadTours{
                self.getTrendingItems()
                self.oneCall.toggle()
                dispatchGroup.notify(queue: .main) {
                    if self.mainStates.loading{
                        self.mainStates.loading.toggle()
                    }
                }
            }
        }
        .onDisappear(perform: {
            if !self.mainStates.showTab{
                self.mainStates.showTab = true
            }
        })
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}

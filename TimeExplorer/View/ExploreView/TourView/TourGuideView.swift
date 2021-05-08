//
//  TourGuideView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/01/2021.
//

import SwiftUI

struct TourGuideView: View {
    var landmarks:[LandMarkGuide] = []
    @State var idx:Int = 0
    @StateObject var IMD:ImageDownloader = .init()
    var timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @State var time:Double = 0
    let timeLimit:Double = 0.75
    @State var showCards:Bool = false
    @StateObject var SP:swipeParams = .init()
    @StateObject var SP2:swipeParams = .init()
    @State var startTour:Bool = false
    let availableElements:[String] = ["Video","Audio","AR"]
    @Binding var showTourGuide:Bool
    @Namespace private var animation
    @State var selectedTab:String = "introduction"
    @State var selectedChapter:HistoryChapters? = nil
    @State var viewChapter:Bool = false
    @State var selectedLandmark:LandMarkGuide = .init()
    @StateObject var playerState:YouTubeControlState = .init()
    @State var showVideoControl:Bool = false
    @State var videoState:ViewFrameType = .play
//    var player:YouTubeView? = nil

    func updateTimer(){
        self.time += 0.1
    }
    
    var landmark:LandMarkGuide{
        get{
            return  self.idx < self.landmarks.count ? self.landmarks[idx] : .init()
        }
    }
    
    func landmarkImage(_ landmark:LandMarkGuide) -> UIImage?{
        var res:UIImage? = nil
        guard let mainImg = landmark.image else {return res}
        self.IMD.getImage(url: mainImg)
        return res
    }
    
    func infoCard(_ landmark:LandMarkGuide,width:CGFloat,height:CGFloat? = nil) -> some View{
        VStack{
            ScrollView(.vertical,showsIndicators:false){
                MainText(content: landmark.description ?? "", fontSize: 17.5, color: .white, fontWeight: .regular, style: .normal)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.vertical,10)
        }.padding()
        .frame(width: width, alignment: .center)
        .frame(maxHeight: height != nil ? height! : .infinity)
        .aspectRatio(contentMode: .fit)
        .background(
            BlurView(style: .regular)
        .clipShape(
            RoundedRectangle(cornerRadius: 30)
        ).shadow(radius: 5)
        )
    }
    
    func historyChapterCard(idx:Int, chapter: HistoryChapters, image img:String, width w:CGFloat, height h:CGFloat) -> some View{
        return VStack{
            ImageView(url:img,width: w - 10,height: h * 0.9 - 10,contentMode:.fill)
                .clipShape(ArcCorners(corner: .topRight, curveFactor: 0.15, cornerRadius: 30, roundedCorner: .allCorners))
                
                .overlay(
                    ZStack(alignment:.bottom){
                        bottomShadow.clipShape(ArcCorners(corner: .topRight, curveFactor: 0.15, cornerRadius: 30, roundedCorner: .allCorners))
                        VStack{
                            HStack{
                                Spacer()
                                Button {
                                    withAnimation(.spring()) {
                                        self.selectedChapter = chapter
                                        self.viewChapter = true
                                        self.playerState.pauseVideo()
                                    }
                                    
                                } label: {
                                    Image(systemName: "arrow.right")
                                        .resizable()
                                        .frame(width: 15, height: 15, alignment: .center)
                                        .padding()
                                        .background(BlurView(style: .systemThinMaterialDark).clipShape(Circle()))
                                }.buttonStyle(PlainButtonStyle())
                                
                            }
                            Spacer()
                            MainText(content: chapter.title ?? "", fontSize: 15, color: .white, fontWeight: .regular, style: .normal)
                                .padding()
                        }.padding().padding(.bottom,25)
                    }
                )
            
        }.padding(5)
        .frame(width: w, height: h, alignment: .center)
    }
    
    func onChangedStack(_ value:CGFloat, _ chapters:[HistoryChapters]){
        if self.SP2.swiped < chapters.count - 1 && self.SP.swiped > 0{
            withAnimation(.easeInOut) {
                self.SP2.extraOffset = value
            }
        }
    }
    
    func onEndedStack(_ value:CGFloat, _ chapters:[HistoryChapters]){
        if value < 0 && abs(value) > 50 && self.SP.swiped < chapters.count - 1{
            self.SP2.swiped += 1
        }else if value > 0 && abs(value) > 50 && self.SP.swiped < 0{
            self.SP2.swiped -= 1
        }
        withAnimation(.easeInOut) {
            self.SP2.extraOffset = 0
        }
    }
    
    func historyChapters(_ landmark:LandMarkGuide,width:CGFloat,height:CGFloat = totalHeight * 0.8) -> some View{
        var chapters = landmark.chapters?.History?.chapters ?? []
        var view = TabView{
            if chapters.isEmpty{
                VStack{
                    MainText(content: "No History available", fontSize: 25, color: .white, fontWeight: .regular, style: .normal)
                }
            }else{
                ForEach(Array(chapters.enumerated()), id: \.offset){ _chapter in
                    var chapter = _chapter.element
                    var tag = _chapter.offset
                    var img:String = chapter.images?.first ?? chapter.image ?? ""
                    var image:UIImage = UIImage.loadImageFromCache(img) ?? self.IMD.images[img] ?? .stockImage
                    var viewing = self.SP2.swiped == idx
                    GeometryReader{g in
                        var w = g.frame(in: .local).width
                        var h = g.frame(in: .local).height
                        self.historyChapterCard(idx:tag,chapter: chapter, image: img, width: w, height: h)
                            .tag(tag)
                    }.padding(5).frame(width: width, height: height, alignment: .center)
                }
            }
        }.frame(width: width, height: height)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        return VStack(alignment:.leading){
            view
            
        }
        

    }
    
    func onChanged(_ value:CGFloat){
        if (value < 0 && self.SP.swiped < self.landmarks.count) || (value > 0 && self.SP.swiped > 0){
            self.SP.extraOffset = value
        }
    }
    
    
    func onEnded(_ value:CGFloat){
        var abs_value = abs(value)
        if value < 0 && abs_value > 100 && self.SP.swiped < self.landmarks.count - 1{
            self.SP.swiped += 1
        }else if value > 0 && abs_value > 100 && self.SP.swiped > 0{
            self.SP.swiped -= 1
        }
        
        withAnimation(.easeInOut) {
            self.SP.extraOffset = 0
        }
    }
    
    func getHeight(_ idx:Int) -> CGFloat{
        var diff = idx - self.SP.swiped
        var factor:Double = 1
        factor -=  diff < 2 ? Double(diff) * 0.3 : 0.3
        return CGFloat(factor)
    }
    
    var tabView:some View{
        var tabNames = ["introduction","history"]
        return HStack{
            ForEach(tabNames,id: \.self){tab in
                var selected = self.selectedTab == tab
                Button {
                    self.selectedTab = tab
                } label: {
                    MainText(content: tab.capitalized, fontSize: 12, color: selected ? .black : .white, fontWeight: .regular, style: .normal)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 30).fill(selected ? Color.white : Color.black))
                }
            }
            Spacer()
        }.padding()
    }
    
    
    func mainLandmarkCard(_ landmark:LandMarkGuide, width w:CGFloat, height h: CGFloat, viewing:Bool) -> some View{
        var details = VStack(alignment:.leading,spacing: 15){
            MainText(content: landmark.title ?? "", fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
            
            HStack{
                ForEach(self.availableElements, id:\.self){elements in
                    MainText(content: elements, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.green))
                }
                Spacer()
            }
            if !self.startTour{
                HStack{
                    Spacer()
                    Button {
                        self.selectedLandmark = landmark
                        self.startTour = true
                    } label: {
                        MainText(content: "View", fontSize: 15, color: .black, fontWeight: .bold, style: .normal)
                            .padding()
                            .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                    }
                }.padding(.vertical)
            }
        }
        var imgView = ImageView(url:landmark.image ?? "" ,width: w, height:h * (self.startTour ? 0.35 : 1), contentMode: .fill)
        return ZStack(alignment:.bottom){
            VStack(spacing:15){
                imgView
                    .clipShape(ArcCorners(corner: .bottomRight, curveFactor: self.startTour ? 0.1 : 0, cornerRadius: self.startTour ? 30 : 0, roundedCorner: .allCorners))
                    .overlay(
                        ZStack{
                            if !self.startTour{
                                bottomShadow
                                VStack(alignment: .center, spacing: 10) {
                                    Spacer()
                                    details.padding(.horizontal,20).frame(width:w)
                                }.frame(height:h)
                            }
                            if !viewing{
                                BlurView(style: .regular)
                                    .aspectRatio(contentMode: .fill)
                            }else{
                                if self.startTour && self.showTourGuide{
                                    VStack{
                                        YouTubeView(playerState: self.playerState)
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: w, height: h * 0.35, alignment: .center)
                                            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: self.startTour ? 0.1 : 0, cornerRadius: self.startTour ? 30 : 0, roundedCorner: .allCorners))
                                            .gesture(DragGesture()
                                                        .onEnded({ (value) in
                                                            var width = value.translation.width
                                                            var abs_width = abs(width)
                                                            if abs_width > 50{
                                                                if width > 0{
                                                                    print("Seeking backwards!")
                                                                    self.playerState.backward()
                                                                    self.videoState = .backward
                                                                }else if width < 0{
                                                                    print("Seeking forwards")
                                                                    self.playerState.forward()
                                                                    self.videoState = .forward
                                                                }
                                                                self.showVideoControl.toggle()
                                                            }
                                                        
                                                            
                                                        }))
                                            .gesture(TapGesture(count: 1)
                                                        .onEnded({
                                                            self.playerState.playPauseButtonTapped()
                                                            self.videoState = self.videoState == .play ? .pause : .play
                                                            self.showVideoControl.toggle()
                                                        }))
                                            .overlay(
                                                ZStack{
                                                    if self.showVideoControl{
                                                        LikeView($showVideoControl, self.$videoState)
                                                    }
                                                }
                                                
                                            )
                                    }.frame(width: w, height: h * 0.35, alignment: .center)
                                    
                                }
                                VStack{
                                    HStack{
                                        TabBarButtons(bindingState: self.startTour ? self.$startTour : self.$showTourGuide)
                                        Spacer()
                                    }.padding()
                                    Spacer()
                                }.padding().padding(.top,10)
                            }
                        }
                    )
                if self.startTour && viewing{
                    details.padding(.horizontal,20).frame(width:w)
                    self.tabView
                    if self.selectedTab == "introduction"{
                        self.infoCard(landmark, width: w - 50, height: h * 0.35)
                    }
                    if self.selectedTab == "history"{
                        self.historyChapters(landmark,width:w - 50, height: h * 0.35)
                    }
                    Spacer(minLength:0)
                }
                
            }
            .frame(width:w,height:h)
            .edgesIgnoringSafeArea(.bottom)
            .background(
                ZStack{
                    if self.startTour && viewing{
                        ImageView(url:landmark.image ?? "" ,width: w, height:h, contentMode:.fill)
                        BlurView(style: .systemThinMaterialDark)
                            .aspectRatio(contentMode: .fill)
                    }
                }
            )
            
            
        }
    }
    
    func offsetHeight() -> CGFloat{
        var height_factor = CGFloat(0.3/100)
        var offset = self.SP.extraOffset
        return abs(offset) <= 100 ? height_factor * -offset : 0.3
        
    }
    
    var body: some View {
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            ZStack(alignment: .center) {
                ForEach(self.landmarks.enumerated().reversed(), id:\.offset){ _landmark in
                    var idx = _landmark.offset
                    var landmark = _landmark.element
                    let image =  self.landmarkImage(landmark) ?? self.IMD.image
                    var ar = UIImage.aspectRatio(img:image)
                    var viewing = idx == self.SP.swiped
                    var imageView = Image(uiImage:image)
                        .resizable()
                        .aspectRatio(ar,contentMode: .fill)
                    var historyAvailable = landmark.chapters?.History?.chapters != nil
                    var details = VStack(alignment:.leading,spacing: 15){
                        MainText(content: landmark.title ?? "", fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                        
                        HStack{
                            ForEach(self.availableElements, id:\.self){elements in
                                MainText(content: elements, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                                    .padding()
                                    .background(RoundedRectangle(cornerRadius: 30).fill(Color.green))
                            }
                            Spacer()
                        }
                        if !self.startTour{
                            HStack{
                                Spacer()
                                Button {
                                    self.selectedLandmark = landmark
                                    self.startTour = true
                                } label: {
                                    MainText(content: "View", fontSize: 15, color: .black, fontWeight: .bold, style: .normal)
                                        .padding()
                                        .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                                }
                            }.padding(.vertical)
                        }
                    }
                    var cardHeight = (viewing ? self.getHeight(idx) : self.getHeight(idx) + self.offsetHeight()) * h
                    if idx >= self.SP.swiped && idx <= self.SP.swiped + 1{
                        self.mainLandmarkCard(landmark, width: w, height: cardHeight, viewing: viewing)
                        .frame(width: w, height: cardHeight)
                        .animation(.easeInOut)
                        .offset(x: viewing ? self.SP.extraOffset : 0)
                        .gesture(DragGesture()
                                    .onChanged({ (value) in
                                        withAnimation(.default) {
                                            if self.startTour{
                                                return
                                            }
                                            self.onChanged(value.translation.width)
                                        }
                                    })
                                    .onEnded({ (value) in
                                        withAnimation(.default) {
                                            if self.startTour{
                                                return
                                            }
                                            self.onEnded(value.translation.width)
                                        }
                                    })
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                    }
                }
//                
//                if self.viewChapter{
//                    TourChaptersView(self.selectedChapter!,self.animation,self.$viewChapter).animation(.spring())
//                }
            }.edgesIgnoringSafeArea(.all).frame(width: w, height: h, alignment: .center)
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .navigationTitle("")
        .navigationBarHidden(true)
        .onChange(of: self.startTour) { (start) in
            if start{
                self.playerState.videoID = "BnWh2hDF6XI"
                print("\(self.playerState.executeCommand)")
            }
        }
//        .onChange(of: self.showVideoControl) { (value) in
//            if value{
//                self.videoState = self.convertViewType()
//                print("videoState : \(self.videoState)")
//            }
//        }
        
    }
}


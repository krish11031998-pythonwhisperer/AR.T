//
//  TrendingCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/03/2021.
//

import SwiftUI
import AVKit


struct TrendingMainCard:View{
    var idx:Int?
    var data:TrendingCardData
    var width:CGFloat
    var height:CGFloat
    @StateObject var IMD:ImageDownloader = .init()
    @StateObject var playerObj:AVPlayerObj = .init()
    var onTap:(() -> Void)?
    var scale:CGFloat
    var detailOpacity:Double
    var blurRadius:CGFloat
    @Binding var clipCorners:Bool
    @State var tabNum:Int = 0
    @State var showVideo:Bool = false
    var isViewing:Bool = false
    
    init(_ idx:Int? = nil,_ data:TrendingCardData,_ width:CGFloat,_ height:CGFloat,opacity:Double? = nil ,blurRadius: CGFloat? = nil,clipCorners:Binding<Bool>? = nil, scale:Double? = nil,handler: (() -> Void)? = nil){
        self.idx = idx
        self.data = data
        self.width = width
        self.height = height
        self.detailOpacity = opacity ?? 1
        self.blurRadius = blurRadius ?? 0
        self._clipCorners = clipCorners ?? .constant(true)
        self.scale = CGFloat(scale ?? 1.0)
        self.onTap = handler
    }
    
    func onAppear(){
//        if self.playerObj.player != nil{
            if let vid_url = self.data.vid_url,self.playerObj.video_id != vid_url{
                self.playerObj.video_id = vid_url
            }
//        }
        
    }
    
    func playPause(){
        DispatchQueue.main.async {
            self.playerObj.videoState = self.playerObj.videoState == .play ? .pause : .play
        }
    }
    
    func showPlayVideo(){
        if self.playerObj.player != nil{
            DispatchQueue.main.async {
                withAnimation(.easeInOut) {
                    if !self.showVideo{
                        self.showVideo = true
                    }
                    if self.playerObj.videoState != .play{
                        self.playerObj.videoState = .play
                    }
                }
            }
        }
    }
    
    func onReceiveVidURL(player:AVPlayer?){
        if player != nil{
            print("Got the Video !")
        }
    }
    
    var LandmarkTabs:some View{
        let data = self.data.data as? TourData ?? nil
        let view = GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let landmarks = data?.landmarks ?? []
            let data = landmarks.compactMap { (lmg) -> CarouselData? in
                return .init(mainTitle: lmg.title, mainImage: lmg.image)
            }
            TabView{
                ForEach(Array(data.enumerated()),id:\.offset) { (_landmark) in
                    let idx = _landmark.offset
                    let landmark = _landmark.element
                    CarouselSliderCard(idx, landmark, w - 10, h, nil, true, .cutRight).padding(10)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(width:self.width * 0.8,height:self.height * 0.2,alignment:.center)
        
        return view
    }
    
        
    var color:Color{
        get{
            var color:Color = .clear
            switch(self.data.type){
                case .post:
                    color = .red
                case .blog:
                    color = .blue
                case .tour:
                    color = .green
                default:
                    break
            }
            return color
        }
    }
    
    func imageView(minY:CGFloat) -> some View{
        if minY == 0 && !self.showVideo{
            self.showPlayVideo()
        }else if self.showVideo && minY > 0{
            if self.playerObj.videoState == .play{
                DispatchQueue.main.async {
                    self.playerObj.videoState = .pause
                }
            }
        }
        return ImageView(url: self.data.image, width: self.width, height: self.height, contentMode: .fill)
    }
    
    func dummyFunction(){
        print("This is a dummy function !: you clicked the view button")
    }
    
    func videoPlayerButton() -> some View{
        return HStack(alignment: .center, spacing: 10) {
            SystemButton(b_name: "gobackward.10", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                DispatchQueue.main.async {
                    self.playerObj.videoState = .seekBack
                }
            }
            SystemButton(b_name: self.playerObj.videoState == .play ? "pause.fill" : "play.fill", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                DispatchQueue.main.async {
                    self.playerObj.videoState = self.playerObj.videoState == .play ? .pause : .play
                }
            }
            SystemButton(b_name: "goforward.10", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                DispatchQueue.main.async {
                    self.playerObj.videoState = .seekForward
                }
            }
        }
    }
    
    func infoView() -> some View{
        return VStack(alignment:.leading){
            HStack{
                MainText(content: "Tours", fontSize: 40, color: .white, fontWeight: .black, style: .heading)
                Spacer()
            }.padding(.top,50)
            
            Spacer()
            if self.data.type == .tour{
                HStack{
                    Image(systemName: "globe")
                        .resizable()
                        .frame(width: 15, height: 15, alignment: .center)
                        .foregroundColor(.white)
                    MainText(content: self.data.location ?? "", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
                }.padding().background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
            }
            MainText(content: self.data.mainText ?? "", fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                .multilineTextAlignment(.leading)
            
            if self.playerObj.player != nil && self.showVideo{
                self.videoPlayerButton()
            }

            MainText(content: "View", fontSize: 17.5, color: .black, fontWeight: .semibold, addBG: true)
                .onTapGesture(perform: self.onTap ?? self.dummyFunction)
                .frame(alignment: .trailing)
            
            Spacer().frame(height: 50)
        }

    }
    
    var body: some View{
        GeometryReader {g in
            let minY = g.frame(in: .global).minY
            ZStack{
                self.imageView(minY: minY)
                if self.showVideo && self.playerObj.player != nil{
                    SimpleVideoPlayer(player: self.playerObj.player!, videoState: $playerObj.videoState, frame: .init(x: 0, y: 0, width: totalWidth, height: totalHeight))
                }
                bottomShadow.opacity(detailOpacity)
                self.infoView()
                .padding(.horizontal,25).padding(.bottom,100).opacity(self.detailOpacity)

            }
        }.frame(width: self.width, height: self.height)
        .blur(radius: self.blurRadius)
//        .clipShape(Corners(rect: .allCorners,size: .init(width: self.clipCorners ? 30 : 0, height: self.clipCorners ? 30 : 0)))
        .animation(.easeIn)
        .scaleEffect(self.scale)
        .onAppear(perform: self.onAppear)
        .onReceive(self.playerObj.$player, perform: self.onReceiveVidURL(player:))
//        .onChange(of: self.showSummary) { showTour in
//            if let data = self.data.data as? TourData,let imgURL = data.landmarks?.compactMap({$0.image}),showTour{
//                self.IMD.getImages(urls: imgURL)
//            }
//        }
//        
        .navigationTitle("")
        .navigationBarHidden(true)
    }

}


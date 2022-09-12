//
//  LandMarkMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 30/01/2021.
//

import SwiftUI

struct LandMarkMainView: View {
    @Namespace var animation
    @Environment (\.modalTransitionPercent) var pct:CGFloat
    var landmark:LandMarkGuide
    var idx:Int
    @StateObject var IMD:ImageDownloader = .init()
//    @StateObject var playerState:YouTubeControlState = .init()
    @State var showVideoControl:Bool = false
//    @State var videoState:ViewFrameType = .play
    @Binding var show:Bool
//    @State var selectedChapter: HistoryChapters = .init()
    @State var selectedChapter: HistoryChapters? = nil
    @State var showHistory:Bool = false
    @State var selectedIdx:Int = -1
    let thresHeight:CGFloat = totalHeight * 0.9
    let targetHeight:CGFloat = totalHeight * 0.7
    let height:CGFloat = totalHeight * 0.3
    let imgHeight:CGFloat =  totalHeight * 0.3 * 0.9 * 0.6
    let captionHeight:CGFloat = totalHeight * 0.3 * 0.9 * 0.4
    
    init(idx:Int,landmark:LandMarkGuide,show:Binding<Bool>){
        self.idx = idx
        self.landmark = landmark
        self._show = show
    }
    
    var viewSize:CGSize{
        var size:CGSize = . init()
        let diff_h = totalHeight - VCardConstraints.default.height
        size.height = VCardConstraints.default.height + diff_h * pct
        
        let diff_w = totalWidth - VCardConstraints.default.targetWidth
        size.width = VCardConstraints.default.targetWidth + diff_w * pct
        
        return size
    }
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            guard let _ = self.landmark.image, let chaptImages = self.landmark.chapters?.History?.chapters else {return}
            let urls = chaptImages.compactMap({$0.image})
            self.IMD.getImages(urls: urls)
        }
    }
    
    
    func imgView(w:CGFloat = totalWidth,h:CGFloat) -> some View{
//        _ = self.landmark.image ?? "image"
//        return StickyHeaderImage(w: w, h: h, url:self.landmark.image ?? "",namespace: .none, aid: .none, curvedCorner: true)
//        .overlay(
//            ZStack(alignment: .top){
//                VStack(alignment: .leading) {
//                    Spacer()
//                        .frame(height:50)
//                    HStack{
//                        TabBarButtons(bindingState: self.$show)
//                        Spacer()
//                    }
//                    Spacer()
//                }.padding()
//            }
//        )
		Color.clear
		

    }
        
    var AudioHistory:some View{
        let data = Array((self.landmark.chapters?.History?.chapters ?? []).enumerated())
        return
            VStack(alignment:.leading,spacing: 10){
                ForEach(data, id: \.offset) { ldm in
                    let landmark = ldm.element
                    let idx = ldm.offset
                    FancyCard(data: landmark.parseToFancyCardData(headline: "Chapters \(idx)"), constraints: .chapterCard) { (data) in
                        withAnimation(.hero, {
                            if let landmark = data as? HistoryChapters{
                                self.selectedChapter = landmark
                                self.selectedIdx = idx
                                self.showHistory.toggle()
                            }
                        })
                        
                    }.matchedGeometryEffect(id: "chapters-\(landmark.title?.snakeCase() ?? "")", in: self.animation,properties: .size,anchor: .bottomTrailing,isSource:true)
                    .transition(.invisible)
                    
                }
            }
    }
        
    var startCard:some View{
        let infoTabsValues:[String:String] = ["Duration":"2 hrs","Reviews":"4.0/5"]
        let infoTabs:[String] = ["Duration","Reviews"]
        
        
        let view = GeometryReader{g in
            let w = g.frame(in: .local).width
//            var h = g.frame(in: .local).height

            VStack(alignment: .leading, spacing: 5){
                MainText(content: self.landmark.title ?? "title", fontSize: 35, color: .white, fontWeight: .bold, style: .normal)
                    .frame(width: w, alignment: .leading)
                HStack(spacing: 10){
                    ForEach(infoTabs,id:\.self) { info in
                        VStack(alignment:.center,spacing:5){
                            MainText(content: info, fontSize: 12, color: .white, fontWeight: .regular)
                            MainText(content: infoTabsValues[info] ?? "", fontSize: 15, color: .gray, fontWeight: .semibold)
                        }
                    }
                }.frame(width: w, alignment: .leading)
            }

        }.padding(20).frame(width: totalWidth, height: totalHeight * 0.15, alignment: .center).clipShape(Corners(rect: [.bottomLeft,.bottomRight], size: .init(width: 30, height: 30)))
        return view
    }
    
    
    var infoCard:some View{
        VStack(alignment:.center){
            MainText(content: self.landmark.description ?? "", fontSize: 15, color: .white, fontWeight: .regular, style: .normal)
        }.padding()
        .frame(width: totalWidth, alignment: .center)
        .frame(maxHeight: totalHeight * 0.5)        
    }
    
    var mainBody:some View{
        let size = self.viewSize
        return ZStack{
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 10) {
                    self.imgView(h: totalHeight * 0.4)
                    self.startCard
                    if self.landmark.description != nil{
                        self.infoCard
                    }
                    
                    self.AudioHistory.padding(.top,50)
                    Spacer(minLength: 75)
                }
            }
            .frame(width: size.width,height: size.height, alignment: .center)
            if self.showHistory && self.selectedChapter != nil{
                Color.clear.overlay(
                    ChapterView(tour:self.selectedChapter!, view:self.$showHistory)
                        .matchedGeometryEffect(id: "chapters-\(self.selectedChapter!.title!.snakeCase())", in: self.animation,properties: .size,anchor: .bottomTrailing,isSource: false)
                ).transition(.modal)
            }
        }
//        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.5))
    }
    
    var body: some View {
        let size = self.viewSize
        return ZStack(alignment: .top) {
            
            Image(uiImage: self.IMD.image ?? .stockImage)
                .resizable()
            
            BlurView(style: .dark)
            
            self.mainBody
        }
//        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .frame(width: size.width, height: size.height, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .animation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.5))
        .onAppear(perform: self.onAppear)
        .navigationBarHidden(true)
        
    }
}


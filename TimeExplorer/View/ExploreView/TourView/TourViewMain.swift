//
//  TourViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/01/2021.
//

import SwiftUI

enum Swipe{
    case up
    case down
}

struct TourViewMain: View {
    @StateObject var ToAPI:TourAPI = .init()
    @State var tours:[TourData] = []
    @State var SP:swipeParams = .init()
    @Binding var showTour:Bool
    @EnvironmentObject var mainStates:AppStates
    @State var showTourSummary:Bool = false
    @State var showTourGuide:Bool = false
    @State var detail_one_opacity:Double = 1.0
    @State var detail_two_opacity:Double = 1.0
    @State var card_one_Height:CGFloat = totalHeight
    @State var card_two_Height:CGFloat = 0
    @State var clipCorners:Bool = false
    @State var blur_one_Radius:CGFloat = 0
    @State var blur_two_Radius:CGFloat = 0
    @State var swipe:Swipe = .up
    
    
    func resetStates(){
        self.detail_one_opacity = 1.0
        self.detail_two_opacity = 0
        self.card_one_Height = totalHeight
        self.card_two_Height = 0
        self.clipCorners = false
        self.blur_one_Radius = 0
        self.blur_two_Radius = 0
    }
    
    var currentTour:TourData?{
        get{
            var res:TourData? = nil
            if self.SP.swiped < self.tours.count && !self.tours.isEmpty{
                res = self.tours[self.SP.swiped]
            }
            return res
        }
    }
    
    var countCheck:Bool{
        get{
            return self.SP.swiped < self.tours.count - 1
        }
    }
    
    func onEnded(_ value:CGFloat){
        var val:Int = 0
        var halfHeight = totalHeight * 0.05
        if value < 0 && abs(value) >= halfHeight && self.countCheck{
            val += 1
        }else if value > 0 && abs(value) >= halfHeight && self.SP.swiped > 0{
            val -= 1
        }
        withAnimation(.easeInOut) {
            self.SP.swiped += val
            self.resetStates()
        }
    }

    func onChanged(_ value:CGFloat){
        
        self.swipe = value < 0 ? .up : .down
        if !countCheck && self.swipe == .up || self.SP.swiped < 0 && self.swipe == .down{
            return
        }
        var targetHeight = totalHeight * 0.01
        var halfHeight = totalHeight * 0.05
        var abs_val = abs(value)
        if abs_val <= targetHeight{
            self.detail_one_opacity = 1 - Double(abs_val/targetHeight)
        }else if abs_val > targetHeight{
            if self.detail_one_opacity > 0{
                self.detail_one_opacity = 0
                
            }
            if abs_val >= halfHeight{
                var factor = abs(Double(abs_val/halfHeight - 1))
                if !self.clipCorners{
                    self.clipCorners = true
                }
                self.card_one_Height = totalHeight - abs_val
                self.card_two_Height = abs_val
                self.blur_one_Radius = CGFloat(factor * 10)
                self.blur_two_Radius = CGFloat((1 - factor) * 10)
                self.detail_two_opacity = factor > 0.75 ? 1 : factor
            }
        }
    }
    
    
    
    
    var body: some View {
        GeometryReader{g in
            let width:CGFloat = g.frame(in: .local).width
            let height:CGFloat = g.frame(in:.local).height
            let current = self.SP.swiped
            let next = current + 1
            let prev = current - 1
            ZStack{
                VStack(spacing:0){
                    ForEach(Array(self.tours.enumerated()),id: \.offset){ _tour in
                        var idx = _tour.offset
                        var tour = _tour.element
                        var not_current = idx == next && self.swipe == .up || idx == prev && self.swipe == .down
                        var h = idx == current ? self.card_one_Height : not_current ? self.card_two_Height : 0
                        var opacity = idx == current ? self.detail_one_opacity : not_current ? self.detail_two_opacity : 0
                        var blur = idx == current ? self.blur_one_Radius : not_current ? self.blur_two_Radius : 0
                        MainTourCard(tour, width, h, self.$showTourSummary, self.$showTourGuide, opacity, blur, self.$clipCorners)
                    }
                }
                VStack(alignment: .leading){
                    HStack{
                        TabBarButtons(bindingState: self.$showTour)
                        MainText(content: "Tours", fontSize: 30, color: .white, fontWeight: .black, style: .heading)
                        Spacer()
                    }.padding(20)
                    Spacer()
                }.padding(.vertical,height * 0.05)
            }.frame(width: width, height: height, alignment: .top).edgesIgnoringSafeArea(.all)
            .gesture(DragGesture()
                        .onChanged({ (value) in
                            if self.showTourSummary{
                                return
                            }
                            withAnimation(.easeInOut) {
                                self.onChanged(value.translation.height)
                            }
                        })
                        .onEnded({ (value) in
                            if self.showTourSummary{
                                return
                            }
                            self.onEnded(value.translation.height)
                        })
            )
        }.frame(width: totalWidth, height: totalHeight)
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            if self.mainStates.ToAPI.tours.isEmpty{
                self.mainStates.ToAPI.getTours()
            }
        }
        .onReceive(self.mainStates.ToAPI.$tours) { (tours) in
            if !tours.isEmpty{
                self.tours = tours
                self.tours.append(contentsOf: tours)
                self.mainStates.loading = false
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
}


struct MainTourCard:View{
    var tour:TourData
    var width:CGFloat
    var height:CGFloat
    @StateObject var IMD:ImageDownloader = .init()
    @Binding var showSummary:Bool
    @Binding var showTour:Bool
    var detailOpacity:Double
    var blurRadius:CGFloat
    @Binding var clipCorners:Bool
    @State var tabNum:Int = 0
    init(_ tour:TourData,_ width:CGFloat,_ height:CGFloat, _ showGuide: Binding<Bool>, _ showTour: Binding<Bool>, _ opacity:Double ,_ blurRadius: CGFloat, _ clipCorners:Binding<Bool>){
        self.tour = tour
        self.width = width
        self.height = height
        self._showSummary = showGuide
        self.detailOpacity = opacity
        self.blurRadius = blurRadius
        self._clipCorners = clipCorners
        self._showTour = showTour
    }
    
    var LandmarkTabs:some View{
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            var landmarks = self.tour.landmarks ?? []
            var data = landmarks.compactMap { (lmg) -> CarouselData? in
                return .init(mainTitle: lmg.title, mainImage: lmg.image)
            }
            TabView{
                ForEach(Array(data.enumerated()),id:\.offset) { (_landmark) in
                    var idx = _landmark.offset
                    var landmark = _landmark.element
                    CarouselSliderCard(idx, landmark, w - 10, h, nil, true, .cutRight).padding(10)
                }
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        }
        .frame(width:self.width * 0.8,height:self.height * 0.2,alignment:.center)
    }
    
    
    var body: some View{
        ZStack{
            Image(uiImage: self.IMD.image)
                .resizable()
                .aspectRatio(UIImage.aspectRatio(img:self.IMD.image),contentMode: .fill)
                .frame(width: self.width, height: self.height, alignment: .center)
            
            
            bottomShadow.opacity(detailOpacity)
//            ScrollView{
                VStack(alignment:.leading){
                    
                    Spacer()
                    HStack{
                        Image(systemName: "globe")
                            .resizable()
                            .frame(width: 15, height: 15, alignment: .center)
                            .foregroundColor(.white)
                        MainText(content: self.tour.location ?? "", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
                    }.padding().background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
                    
                    MainText(content: self.tour.mainTitle ?? "", fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                        .multilineTextAlignment(.leading)
                    if self.showSummary{
                        VStack{
                            MainText(content: "Landmarks", fontSize: 15, color: .black, fontWeight: .bold, style: .normal)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 30).fill(Color.white))
                                .padding(.vertical,10)
                            self.LandmarkTabs
                        }.animation(.easeInOut)
                        
                    }
                    
                    HStack{
                        Spacer()
                        Button {
                            if !self.showSummary{
                                self.showSummary.toggle()
                            }else{
                                self.showTour.toggle()
                            }
                        } label: {
                            MainText(content: !self.showSummary ? "Tour Summary" : "Start Tour", fontSize: 15, color: .black,fontWeight: .semibold,style: .normal)
                                .padding()
                                .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
                        }
                    }.padding(.top,15)
//                    
//                    NavigationLink(destination: TourGuideView(landmarks: self.tour.landmarks ?? [],showTourGuide: $showTour), isActive: $showTour) {
//                        MainText(content: "", fontSize: 10)
//                    }.hidden().navigationTitle("")
//                    .navigationBarHidden(true)
//                    
//
//                    NavigationLink(destination: TourVerticalCardView(self.tour, self.$showTour), isActive: $showTour) {
//                        MainText(content: "", fontSize: 10)
//                    }.hidden().navigationTitle("")
//                    .navigationBarHidden(true)
            }
            .padding(.horizontal,25).padding(.bottom,50).opacity(self.detailOpacity)
            
        }.frame(width: self.width, height: self.height).blur(radius: self.blurRadius).clipShape(Corners(rect: .allCorners,size: .init(width: self.clipCorners ? 30 : 0, height: self.clipCorners ? 30 : 0)))
        .animation(.easeInOut)
        
        .onAppear {
            if let url = self.tour.mainImage, self.IMD.url != url{
                self.IMD.getImage(url: url)
            }
        }
        .onChange(of: self.showSummary) { showTour in
            if let imgURL = self.tour.landmarks?.compactMap({$0.image}),showTour{
                self.IMD.getImages(urls: imgURL)
            }
        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
}


struct SlidingCarousel:View{
    var landmarks:[LandMarkGuide] = []
    var width:CGFloat
    var height:CGFloat
    @State var clickAction:Bool = false

    var body: some View{
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            VStack{
                HorizontalCarousel(data: self.landmarks.compactMap({CarouselData(mainTitle: $0.title, mainImage: $0.image)}), clickAction: $clickAction, height: h, width: w, numbered: true)
            }



        }.padding(20).frame(width: self.width, height: self.height, alignment: .center)
    }
}


//struct TourViewMain_Previews: PreviewProvider {
//    static var previews: some View {
//        TourViewMain()
//    }
//}

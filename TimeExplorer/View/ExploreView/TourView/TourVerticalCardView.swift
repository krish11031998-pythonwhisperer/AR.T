//
//  TourVerticalCardView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 29/01/2021.
//

import SwiftUI
import SceneKit
struct TourVerticalCardView: View {
    var tour:TourData
    @State var mainImage:UIImage = .stockImage
    @State var landmarkImage:UIImage = .stockImage
    @State var img:UIImage = .stockImage
    @Binding var showTour:Bool
    @State var showLandmark:Bool = false
    @State var selectedLandmark:LandMarkGuide? = nil
    @State var selectedIdx:Int = -1
    @Namespace var animation
    @EnvironmentObject var mainStates:AppStates
    
    init(_ tour:TourData, _ showTour:Binding<Bool>){
        self.tour = tour;
        self._showTour = showTour
    }
    
    var landmarks:[LandMarkGuide]{
        get{
            return self.tour.landmarks ?? []
        }
    }
    
    var mainImgView:some View{
        let w = totalWidth
        let h = totalHeight * 0.5
        return StickyHeaderImage(w: w, h: h, url: self.tour.mainImage, namespace: self.animation, aid: "main-image")
        .overlay(
            GeometryReader{g in
                let width = g.frame(in: .local).width
                let height = g.frame(in: .local).height
                ZStack(alignment: .top){
                    lightbottomShadow
                    VStack(alignment: .leading){
                        HStack{
                            TabBarButtons(bindingState: self.$showTour)
                            Spacer()
                        }
                        .padding(.leading)
                        .padding(.top,100)
                        Spacer()
                        MainText(content: self.tour.mainTitle ?? "", fontSize: 30, color: .white, fontWeight: .bold, style: .normal)
                            .aspectRatio(contentMode: .fill)
                            .frame(width: w, alignment: .center)
                    }.padding(20)
                }.frame(width: width, height: height, alignment: .center).clipShape(Corners(rect: [.bottomRight,.bottomLeft], size: .init(width: 50, height: 50)))
            }.frame(width: w, height: h, alignment: .center).offset(y:-20)
        )
    }
    
    var mainIntro:some View{
        VStack(alignment: .leading, spacing: 10) {
            MainText(content: self.tour.mainDescription ?? "", fontSize: 15, color: .white, fontWeight: .regular, style: .normal)
            Spacer()
        }.padding()
        .frame(width: totalWidth, alignment: .center)
        
    }
    
    
    var IntroView: some View{
        VStack(alignment:.center ,spacing: 20){
            self.mainImgView
            self.mainIntro
        }.padding(.horizontal)
        .padding(.bottom)
        .frame(width: totalWidth, alignment: .center)
    }
    
    func parseLandmarktoFancyCard(data: LandMarkGuide) -> FancyCardData{
        return .init(headline: data.title ?? "Title", mainImg: data.image, subheadline: data.description, rowInfo:["Duration":"2 hrs","Reviews":"4.0/5"] , data: data as Any)
    }
    
    var ContentScroll:some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center,spacing: 50){
                self.IntroView
                    
                ForEach(Array(self.landmarks.enumerated()),id: \.offset) { (obj) in
                    let landmark = obj.element
                    let idx = obj.offset
                        FancyCard(data: landmark.parseToFancyCardData(), constraints: .default) { (data) in
                            withAnimation(.easeInOut) {
                                if let landmark = data as? LandMarkGuide{
                                    self.selectedLandmark = landmark
                                    self.selectedIdx = idx
                                    self.showLandmark = true
                                }
                            }
                        }.matchedGeometryEffect(id: "card-\(idx)", in: self.animation,properties:.frame, anchor: .topLeading)
                        .transition(.invisible)
                }
                Spacer(minLength: totalHeight * 0.4)
            }
        }.frame(width: totalWidth)
    }
    
    var body: some View {
        ZStack(alignment: .top){
            ImageView(url: self.tour.mainImage, width: totalWidth, height: totalHeight, contentMode: .fill)
            
            BlurView(style: .dark)
                .aspectRatio(contentMode: .fill)
            
            self.ContentScroll
            
            if self.showLandmark && self.selectedLandmark != nil{
                Color.clear.overlay(
                    LandMarkMainView(idx: self.selectedIdx, landmark: self.selectedLandmark!, show: self.$showLandmark)
                        .onDisappear {
                            self.selectedLandmark = nil
                        }
                        .matchedGeometryEffect(id: "card-\(self.selectedIdx)", in: self.animation, anchor: .topLeading)
                ).transition(.modal)
            }
        }
        .frame(width: totalWidth, height: totalHeight)
        .animation(.easeInOut)
        .onAppear(perform: self.mainStates.toggleTab)
        .onDisappear(perform: self.mainStates.toggleTab)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

}

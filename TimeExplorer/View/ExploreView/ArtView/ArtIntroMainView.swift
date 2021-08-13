//
//  ArtIntroMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/05/2021.
//

import SwiftUI

struct ScrollInfoCard:View{
    var data:ArtData
    @Binding var minY:CGFloat
    @Binding var showArt:Bool
    @State var showMore:Bool = false
    @Namespace var animation
    var onChanged:((DragGesture.Value) -> Void)? = nil
    var onEnded:((DragGesture.Value) -> Void)? = nil
    init(data:ArtData,minY:Binding<CGFloat>? = nil,showArt:Binding<Bool>? = nil,onChanged:((DragGesture.Value) -> Void)? = nil,onEnded:((DragGesture.Value) -> Void)? = nil){
        self.data = data
        self._minY = minY ?? .constant(0)
        self._showArt = showArt ?? .constant(false)
        self.onChanged = onChanged
        self.onEnded = onEnded
    }
    
    
    func infoOverlay(w:CGFloat,h:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
//            TabBarButtons(bindingState: $showArt)
            Spacer()
            ScrollView(.vertical, showsIndicators: false) {
                HeadingInfoText(heading: self.data.title, subhead: "1503 - 1506", headingSize: 35, headingColor: .white, headingDesign: .serif, subheadSize: 20, subheadColor: .white, subheadDesign: .rounded)
                    .frame(width: w * 0.5, alignment: .leading)
            }.frame(height: h * 0.35, alignment: .center)
            
        }.padding()
        .padding(.leading)
        .frame(width: w, height: h, alignment: .bottomLeading)
    }
    
    
    
    
    var body: some View{
        return GeometryReader {g -> AnyView in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).minY
            DispatchQueue.main.async {
                self.minY = minY
            }
            return AnyView(
                ZStack(alignment:.top){
                    Color.black
                    VStack(alignment: .leading, spacing: 20){
                        ImageView(url: self.data.thumbnail, width: w, height: h * 0.45, contentMode: .fill,alignment:.topLeading)
                            .clipShape(Rectangle())
                            .overlay(self.infoOverlay(w: w, h: h * 0.45))
                        self.introInfoSection(w: w, h: h * 0.25)
                        self.infoBody(w: w)
                        Spacer()
                        
                    }.frame(width: w, height: h, alignment: .leading)
                    if self.showMore{
                        self.extraIntroView(size: .init(width: w, height: h))
                    }
                }.frame(width: w, height: h, alignment: .leading))
            
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        .gesture(DragGesture()
                    .onChanged(!self.showMore ? self.onChanged ?? { _ in} : { _ in})
                    .onEnded(!self.showMore ? self.onEnded ?? { _ in} : { _ in})
                 
        )
    }
    
}

extension ScrollInfoCard{
    func extraIntroView (size:CGSize) -> some View{
        let w = size.width
        let h = size.height
        return Group{
            BlurView(style: .dark)
            VStack{
                ScrollView(.vertical, showsIndicators: false) {
                    MainText(content: self.data.introduction, fontSize: 25, color: .white, fontWeight: .semibold)
                        .lineLimit(Int.max)
                        .matchedGeometryEffect(id: "intro", in: self.animation)
                }
                .padding(.top,50)
                .frame(width: w - 20, height: h - 120, alignment: .leading)
                SystemButton(b_name: "arrow.up", b_content: "", color: .white, haveBG: false, size: .init(width: 25, height: 25), alignment: .horizontal) {
                    self.showMore.toggle()
                }
                .padding(.bottom)
                .frame(width: w - 20,height:100, alignment: .leading)
            }.edgesIgnoringSafeArea(.all)
            .padding()
            .frame(width: w, height: h, alignment: .leading)
            
        }
    }

    func infoBody(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: self.data.introduction, fontSize: 15, color: .white, fontWeight: .regular)
                .opacity(self.showMore ? 0 : 1)
                .lineLimit(5)
                .matchedGeometryEffect(id: "intro", in: self.animation, isSource: true)
            SystemButton(b_name: "arrow.down", b_content: "", color: .white, haveBG: false, size: .init(width: 15, height: 15), alignment: .horizontal) {
                self.showMore.toggle()
            }
        }.padding()
        .frame(width: w,alignment: .topLeading)
    }
    
    func introInfoSection(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .center, spacing: 10){
                ImageView(url: self.data.painterImg, width: w * 0.45, height: h * 0.9, contentMode: .fill,alignment: .top)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
//                Text(self.data.painterName ?? "Artisan")
//                    .font(.system(size: 20, weight: .bold, design: .serif))
//                    .foregroundColor(.white)
//                    .fixedSize(horizontal: false, vertical: true)
                BasicText(content: self.data.painterName ?? "Artisan", fontDesign: .serif, size: 20, weight: .bold)
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(height: h * 0.1, alignment: .center)
            }.padding(.leading, 20)
            Spacer()
            if self.data.infoSnippets != nil{
                VStack(alignment: .leading, spacing: 10){
                    ForEach(Array(self.data.infoSnippets!.keys),id:\.self) { key in
                        let value = self.data.infoSnippets![key] ?? "No Info"
                        HeadingInfoText(heading: key, subhead: value, headingSize: 15, headingColor: .gray, headingDesign: .default, subheadSize: 18, subheadColor: .white, subheadDesign: .serif)
                    }
                }
                Spacer()
            }
        }.frame(width: w, height: h, alignment: .leading)
    }
}



struct ScrollInfoCard_Preview:PreviewProvider{
    static var previews: some View{
        ScrollInfoCard(data: test)
            .edgesIgnoringSafeArea(.all)
    }
}

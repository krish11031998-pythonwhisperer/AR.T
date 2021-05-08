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
            HeadingInfoText(heading: self.data.title, subhead: "1503 - 1506", headingSize: 35, headingColor: .white, headingDesign: .serif, subheadSize: 20, subheadColor: .white, subheadDesign: .rounded)
            Spacer()
                .frame(height: h * 0.2)
        }.padding()
        .padding(.leading)
        .frame(width: w, height: h, alignment: .bottomLeading)
    }
    
    
    func introInfoSection(w:CGFloat,h:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10) {
            VStack(alignment: .center, spacing: 10){
                ImageView(url: self.data.painterImg, width: w * 0.45, height: h, contentMode: .fill)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                Text(self.data.painterName ?? "Artisan")
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }.padding(.leading, 20).offset(y: -75)
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
    
    
    
    func infoBody(w:CGFloat) -> some View{
        VStack(alignment: .leading, spacing: 10){
            Text(self.data.introduction)
                .font(.system(size: 15, weight: .regular, design: .serif))
                .foregroundColor(.white)
        }.padding()
        .frame(width: w,alignment: .topLeading)
    }
    var body: some View{
    
        return GeometryReader {g -> AnyView in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).minY
            DispatchQueue.main.async {
//                if minY == totalHeight{
                    self.minY = minY
//                }
            }
            return AnyView(
                VStack(alignment: .leading, spacing: 20){
                    ImageView(url: self.data.thumbnail, width: w, height: h * 0.45, contentMode: .fill,alignment:.topLeading)
                        .clipShape(Rectangle())
                        .overlay(self.infoOverlay(w: w, h: h * 0.45))
                    self.introInfoSection(w: w, h: h * 0.25)
                    self.infoBody(w: w)
                    Spacer()
                    
                }.frame(width: w, height: h, alignment: .leading).background(Color.black))
            
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        .gesture(DragGesture()
                    .onChanged(self.onChanged ?? { _ in})
                    .onEnded(self.onEnded ?? { _ in})
                 
        )
    }
    
}

struct ScrollInfoCard_Preview:PreviewProvider{
    static var previews: some View{
        ScrollInfoCard(data: test)
            .edgesIgnoringSafeArea(.all)
    }
}

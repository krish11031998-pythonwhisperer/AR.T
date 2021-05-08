//
//  FancyCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/04/2021.
//

import SwiftUI

struct FancyCardData{
    var headline:String
    var mainImg:String?
    var subheadline:String? = nil
    var rowInfo:[String:String]? = nil
    var data:Any
}

struct VCardConstraints:Equatable{
    var height:CGFloat
    var targetHeight:CGFloat
    var thresHeight:CGFloat
    var targetWidth:CGFloat
    var imgTargetHeight:CGFloat{
        get{
            return self.height * 0.6
        }
    }
    
    var captionHeight:CGFloat{
        get{
            return self.height * 0.4
        }
    }
    static var `default`:VCardConstraints = .init()
    static var chapterCard:VCardConstraints = .init(totalHeight * 0.3, totalHeight * 0.7, totalHeight * 0.9, AppWidth - 20)
    
    init(_ h:CGFloat = totalHeight * 0.45, _ th:CGFloat = totalHeight * 0.4, _ thrh:CGFloat = totalHeight * 0.6, _ tw:CGFloat = totalWidth * 0.85){
        self.height = h
        self.targetHeight = th
        self.targetWidth = tw
        self.thresHeight = thrh
    }
    
    func cardWidth(minY:CGFloat,_ percent:CGFloat) -> CGFloat{
        var width:CGFloat = totalWidth
        if(minY <= self.thresHeight){
            let factor = 1 - (0.15 * (1 - percent))
            let f_w = width * factor
            width =  f_w < self.targetWidth ? self.targetWidth : f_w
        }
        return width
    }
    
    
    func subSectionHeight(minY:CGFloat,_ percent:CGFloat,_ section:String) -> CGFloat{
        var final_height:CGFloat = section == "img" ? self.height : 0
        if minY <= self.thresHeight && minY >= self.targetHeight{
            switch(section){
            case "img":
                let factor = 1 -  (0.4 * (1 - percent))
                let h = self.height * factor
                final_height = h < self.imgTargetHeight ? self.imgTargetHeight : h
            case "caption":
                let factor = 0.4 * (1 - percent)
                let h = self.height * factor
                final_height = h < self.captionHeight ? self.height * factor : h
            default:
                break
            }
        }else if minY <= self.targetHeight{
            final_height = section == "img" ? self.imgTargetHeight : self.captionHeight
        }
        return final_height
    }
    
}

struct FancyCard: View {
    var data:FancyCardData
    var constraints:VCardConstraints
    @StateObject var IMD:ImageDownloader = .init()
    var onView : (Any) -> Void
    var showImgOverlay:Bool
    init(data:FancyCardData,constraints:VCardConstraints = .default,showImgOverlay:Bool = true,view: @escaping (Any) -> Void){
        self.data = data
        self.onView = view
        self.constraints = constraints
        self.showImgOverlay = showImgOverlay
    }
    
    func imgView(_ minY:CGFloat,_ percent:Double,_ width:CGFloat,_ height:CGFloat) -> some View{
        return GeometryReader{ g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            ImageView(url: self.data.mainImg, width: w, height: h, contentMode: .fill)
                .overlay(
                    HStack{
                        Spacer()
                        ForEach(["Audio","AR","Video"], id: \.self) { tab in
                            MainText(content: tab, fontSize: 12, color: .white, fontWeight: .regular, style: .normal)
                                .padding()
                                .background(BlurView(style: .systemThinMaterialDark)
                                .clipShape(Capsule()))
                        }
                    }.padding().frame(width:w).opacity(self.showImgOverlay ? 1 : 0),
                    alignment:.topTrailing
                )
        }.frame(width: width, height: height, alignment: .center)
    }
    
    func contentRowInfoView(_ data:[String:String], _ w:CGFloat) -> some View{
        return HStack(spacing: 10){
            ForEach(Array(data.keys),id:\.self) { key in
                let info = data[key] ?? ""
                VStack(alignment:.center,spacing:5){
                    MainText(content: key, fontSize: 12, color: .white, fontWeight: .regular)
                    MainText(content: info, fontSize: 15, color: .white, fontWeight: .semibold)
                }
            }
            Spacer()
            Button {
                withAnimation(.easeInOut) {
                    print("View button is clicked")
                    self.onView(self.data.data)
                }
            } label: {
                MainText(content: "View", fontSize: 10, color: .white, fontWeight: .medium, style: .normal)
                    .padding()
                    .background(BlurView(style: .systemThinMaterialDark).clipShape(Capsule()))
            }
        }.padding(10)
        .frame(width:w)
    }
    
    func contentView(_ minY:CGFloat, _ percent:Double, _ width:CGFloat, _ height:CGFloat) -> some View{
        var view = VStack(alignment: .leading, spacing: 2.5) {
            Spacer()
            VStack(alignment: .leading, spacing: 10){
                MainText(content: self.data.headline, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                MainText(content: self.data.subheadline ?? "", fontSize: 15, color: .white, fontWeight: .regular, style: .normal)
            }.padding(.leading,10)
            .frame(width:width,alignment:.leading)
            
            if self.data.rowInfo != nil{
                self.contentRowInfoView(self.data.rowInfo!, width)
            }
            Spacer()
        }.opacity(minY <= self.constraints.thresHeight ? percent * 1 : 0)
        .padding()
        .background(BlurView(style: .dark))
        .frame(width: width, height: height, alignment: .center)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            self.onView(self.data.data)
        }
        return view
    }
    
    func computeParams(minY:CGFloat) -> (CGFloat,CGFloat,CGFloat,CGFloat,CGFloat,Bool){
        let percent = (minY - constraints.targetHeight)/constraints.targetHeight
        let _cardWidth:CGFloat = self.constraints == .default ? self.constraints.cardWidth(minY: minY, percent) : self.constraints.targetWidth
        let imgHeight:CGFloat = self.constraints.subSectionHeight(minY: minY, percent, "img")
        let contentHeight:CGFloat = self.constraints.subSectionHeight(minY: minY, percent, "caption")
        let cR = 30 * (1 - percent)
        let thresReached = minY <= self.constraints.thresHeight
        
        return (percent,_cardWidth,imgHeight,contentHeight,cR,thresReached)
    }
    
    var body: some View{
        GeometryReader { g in
            let local = g.frame(in: .local)
            let global = g.frame(in: .global)
//            let width = local.width
            let height = local.height * 0.95
            let minY = global.minY
            let (percent,_cardWidth,imgHeight,contentHeight,cR,thresReached) = self.computeParams(minY: minY)
            
            
            HStack{
                Spacer(minLength: 0)
                VStack(alignment: .leading,spacing:0){
                    self.imgView(minY,1 - Double(percent),_cardWidth,imgHeight)
                    self.contentView(minY,1 - Double(percent),_cardWidth,contentHeight)
                }.frame(width:_cardWidth,height:height,alignment:.center)
                .clipShape(RoundedRectangle(cornerRadius: cR > 30 ? 30 : cR))
                Spacer(minLength: 0)
            }
        }
        .animation(.default)
        .frame(width:totalWidth,height: self.constraints.height)
    }
}


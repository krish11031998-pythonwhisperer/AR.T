//
//  AuctionCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 19/06/2021.
//

import SwiftUI

struct AuctionCard: View {
    var data:AVSData = .init()
    var idx:Int
    var cardSize:CGSize = .init()
    @State var opacity:Double = 1.0
    @State var showInfo:Bool = false
    
    init(idx:Int,data:AVSData,size:CGSize = .init(width: totalWidth, height: totalHeight * 0.4)){
        self.idx = idx
        self.data = data
        self.cardSize = size
    }
    
    
    var imgView:AnyView{
        return AnyView(
            self.data.img == nil ?
                ImageView(img: .init(named: self.data.img ?? "monaLisa"), width: self.cardSize.width, height: self.cardSize.height, contentMode: .fill, alignment: .bottomLeading).clipped()
            :
                ImageView(url: self.data.img!, width: self.cardSize.width, height: self.cardSize.height, contentMode: .fill, alignment: .bottomLeading).clipped()
        )
    }
    
    var overlayCaptionView:some View{
        GeometryReader{g -> AnyView in
            let w = g.frame(in: .local).width
        
            let line_h:CGFloat = 10
            
            let view = VStack(alignment: .leading, spacing: 25){
                self.ownerInfo(w: w)
                Spacer()
                MainText(content: self.data.title ?? "Title", fontSize: 30, color: .white, fontWeight: .regular)
                self.lineChart(w: w, h: line_h)
                self.cardInfo(w: w)
            }
            
            return AnyView(view)
            
        }.padding()
        .frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .leading)
    }
    
    var body: some View {
        GeometryReader {g -> AnyView in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minY = g.frame(in: .global).midY
            
            DispatchQueue.main.async {
                if minY < totalHeight && minY > 0 && !self.showInfo{
                    print("Show - true")
                    withAnimation(.easeInOut(duration: 0.7)) {
                        self.showInfo = true
                    }
                }
            }
            
            let view = ZStack(alignment: .center){
                self.imgView
                lightbottomShadow
                    .frame(width: w, height: h, alignment: .center)
                if self.showInfo{
                    self.overlayCaptionView
                        .transition(.move(edge: .bottom))
                }else{
                    MainText(content: "\(self.showInfo)", fontSize: 30, color: .white, fontWeight: .medium)
                }
                
            }
            
            return AnyView(view)
        }.frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .center)
    }
}

extension AuctionCard{
    
    func lineChart(w:CGFloat,h line_h:CGFloat) -> some View{
        return ZStack(alignment: .leading){
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.gray.opacity(0.2))
                .frame(width: w, height: line_h, alignment: .center)
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white)
                .frame(width: w * 0.65, height: line_h, alignment: .center)
        }.frame(width: w, height: line_h, alignment: .center)
    }
    
    func cardInfo(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10){
            BasicText(content: "\(5999) BTC", fontDesign: .monospaced, size: 20, weight: .bold)
                .foregroundColor(.white)
            Spacer()
            MainText(content: "30 bids", fontSize: 20, color: .white, fontWeight: .regular)
        }.frame(width: w, alignment: .leading)
    }
    
    func ownerInfo(w:CGFloat) -> some View{
        HStack(alignment: .center, spacing: 10){
            ImageView(width: w * 0.1, height: w * 0.1, contentMode: .fill, alignment: .center)
                .clipShape(Circle())
            MainText(content: self.data.subtitle ?? "Krishna", fontSize: 15, color: .white, fontWeight: .semibold)
            Spacer()
        }.frame(width: w, alignment: .center)
    }
    
}

struct AuctionCard_Previews: PreviewProvider {
    static var previews: some View {
        AuctionCard(idx:0,data: .init(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test))
    }
}

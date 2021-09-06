//
//  ChartCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 13/06/2021.
//

import SwiftUI

struct ChartCard: View {
    var header:String
    var size:CGSize
    var insideView:((CGFloat,CGFloat) -> AnyView)? = nil
    var aR:ContentMode
    var bg:AnyView
    var fontColor:Color
    
    init(header:String = "Header",size:CGSize  = .init(width: totalWidth * 0.5, height: totalHeight * 0.5),insideView:((CGFloat,CGFloat) -> AnyView)? = nil,aR:ContentMode = .fill,bg:AnyView = AnyView(Color.white),fontColor:Color = .white){
        self.header = header
        self.size = size
        if let safeView = insideView{
            self.insideView = safeView
        }
        self.aR = aR
        self.bg = bg
        self.fontColor = fontColor
    }

    func infoView(w:CGFloat,h:CGFloat) -> some View{
        return ZStack(alignment: .center){
            Color.gray.opacity(0.5)
            
        }.frame(width: w, height: h, alignment: .center)
    }
    
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            VStack(alignment: .center, spacing: 10){
                MainText(content: self.header, fontSize: 20, color: self.fontColor, fontWeight: .regular)
                    .padding(5)
                    .frame(width: w,alignment: .leading)
                if let safeIS = self.insideView{
                    safeIS(w,h * 0.95)
                }
            }
        }
        .padding(self.aR == .fill ? 10 : 0)
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
        .background(self.bg)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .white.opacity(0.15), radius: 10, x: 0, y: 2)
    }
}

struct ChartCard_Previews: PreviewProvider {
    static var previews: some View {
        ChartCard()
    }
}

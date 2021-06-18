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
    
    
    init(header:String = "Header",size:CGSize  = .init(width: totalWidth * 0.5, height: totalHeight * 0.5),insideView:((CGFloat,CGFloat) -> AnyView)? = nil){
        self.header = header
        self.size = size
        if let safeView = insideView{
            self.insideView = safeView
        }
    }

    
    var body: some View {
        GeometryReader{g in
            let local = g.frame(in: .local)
            let w = local.width
            let h = local.height
            
            
            VStack(alignment: .center, spacing: 10){
                BasicText(content: self.header, fontDesign: .serif, size: 20, weight: .semibold)
                    .frame(width: w,alignment: .leading)
//                VStack(spacing: 10){
//                    BasicText(content: "Total Views", fontDesign: .serif, size: 10, weight: .thin)
//                    BasicText(content: "\(self.total)k", fontDesign: .serif, size: 35, weight: .bold)
//                }.padding(.vertical,10)
//                self.barChart(w: w, h: h * 0.45)
                if let safeIS = self.insideView{
                    safeIS(w,h)
                }
                
            }
            
            
        }.padding()
        .frame(width: self.size.width, height: self.size.height, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 2)
    }
}

struct ChartCard_Previews: PreviewProvider {
    static var previews: some View {
        ChartCard()
    }
}

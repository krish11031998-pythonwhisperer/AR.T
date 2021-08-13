//
//  ChartsMainView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 03/07/2021.
//

import SwiftUI

struct ChartMainView: View{
    var body:some View{
        GeometryReader {g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            VStack(alignment: .leading, spacing: 10){
                MainText(content: "Statistics", fontSize: 25, color: .white, fontWeight: .regular)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: w,height: h * 0.05, alignment: .leading)
                SummaryView(header: "Summary",size: .init(width: w, height: h * 0.3))
                HStack(alignment: .center){
                    WeekBarChart(header: "Views",values: [25,45,60,10,30,79,91],size: .init(width: w * 0.475, height: h*0.3))
                    CircleChart(percent: 35, header: "Likes",size: .init(width: w * 0.475, height: h*0.3))
                }
                CurveChart(data: [45,25,10,60,30,79],interactions: true,size: .init(width: w * 0.85, height: h * 0.3), header: "Price",bg: .black, lineColor: .white)
            
                Spacer().frame(minHeight:0,maxHeight: h * 0.4)
            }.frame(width: w, height: h, alignment: .leading)
        }.padding(10).frame(width: totalWidth, height: totalHeight * 1.2, alignment: .center)
    }
    
}
struct ChartsMainView_Previews: PreviewProvider {
    static var previews: some View {
        ChartMainView()
    }
}

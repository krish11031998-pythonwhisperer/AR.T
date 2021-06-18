//
//  CircleChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 07/06/2021.
//

import SwiftUI

struct CircleChart: View {
    var percent:Float
    var header:String
    var size:CGSize
    var increase:Bool
    
    init(percent:Float,header:String,size:CGSize = .init(width: totalWidth * 0.45, height: 300)){
        self.percent = percent
        self.header = header
        self.size = size
        self.increase = true
    }
    
    
    func CircleChart(w:CGFloat,h:CGFloat) -> AnyView{
        let chartW = w * 0.8
        return AnyView(
            ZStack(alignment: .center) {
                Circle()
                    .trim(from: 0, to: 1)
                    .stroke(Color.gray.opacity(0.125), lineWidth: w * 0.045)
                    .frame(width: chartW, height: chartW, alignment: .center)
                Circle()
                    .trim(from: 0, to: CGFloat(self.percent/100))
                    .stroke(Color.green.opacity(0.75), lineWidth: w * 0.045)
                    .frame(width: chartW , height: chartW , alignment: .center)
                    .rotationEffect(.init(degrees: -90), anchor: .center)
                VStack(spacing: 2.5){
//                    BasicText(content: "\(String(format: "%.0f" ,self.percent))%", fontDesign: .serif, size: 25, weight: .semibold, color: .black)
                    MainText(content: "\(String(format: "%.0f" ,self.percent))%", fontSize: 25, color: .black, fontWeight: .semibold)
//                    BasicText(content: "of the Viewers", fontDesign: .serif, size: 12.5, weight: .semibold, color: .black)
                    MainText(content: "of the Viewers", fontSize: 12.5, color: .black, fontWeight: .semibold)
                }
            }.frame(width: w, height: h, alignment: .center)
            
        
        )
    }
    
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        return AnyView(
            Group{
                self.CircleChart(w: w , h: w )
                HStack{
                    VStack(alignment: .leading, spacing: 10){
                        MainText(content: "45k", fontSize: 30, color: .black, fontWeight: .semibold)
//                        BasicText(content: "45k", fontDesign: .serif, size: 30, weight: .semibold, color: .black)
                        MainText(content: "Likes", fontSize: 20, color: .black, fontWeight: .regular)
//                        BasicText(content: "Likes", fontDesign: .serif, size: 20, weight: .regular, color: .black)
                    }
                    Spacer()
                    VStack(alignment: .leading, spacing: 10){
                        //                        BasicText(content: "\(self.increase ? "↑" : "↓") 30%", fontDesign: .serif, size: 17.5, weight: .semibold, color: .black.opacity(0.85))
                        MainText(content: "\(self.increase ? "↑" : "↓") 30%", fontSize: 17.5, color: .black, fontWeight: .semibold)
                        //                        BasicText(content: "Since Last Week", fontDesign: .serif, size: 12.5, weight: .regular, color: .black.opacity(0.85))
                        MainText(content: "Since Last Week", fontSize: 12.5, color: .black, fontWeight: .regular)
                    }
                }
            }
        
        )
    }
    
    var body: some View {
        ChartCard(header: self.header, size: self.size, insideView: self.mainBody)
    }
}

struct CircleChart_Previews: PreviewProvider {
    static var previews: some View {
        CircleChart(percent: 35, header: "Likes")
    }
}

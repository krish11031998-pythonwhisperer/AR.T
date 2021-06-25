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
    @State var firstView:Bool = false
    @State var load:Bool = false
    
    init(percent:Float,header:String,size:CGSize = .init(width: totalWidth * 0.45, height: 300)){
        self.percent = percent
        self.header = header
        self.size = size
        self.increase = true
    }

    func CircleChart(w:CGFloat,h:CGFloat) -> some View{
        return GeometryReader{g -> AnyView in
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if minY <= totalHeight * 0.7{
                    self.onAppear()
                }
            }
            
            return AnyView(ZStack(alignment: .center) {
                self.drawCircle(w: w)
                self.drawCircle(w: w, animatable: true)
                    .rotationEffect(.init(degrees: -90), anchor: .center)
                VStack(spacing: 2.5){
                    MainText(content: "\(String(format: "%.0f" ,self.percent))%", fontSize: 25, color: .black, fontWeight: .semibold)
                    MainText(content: "of the Viewers", fontSize: 12.5, color: .black, fontWeight: .semibold)
                }
            }.frame(width: w, height: h, alignment: .center))
        }
//        )
    }
    
    func onAppear(){
        if !self.firstView{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                withAnimation(.easeInOut) {
                    self.load = true
                }
            }
        }
    }
    
    
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        return AnyView(
            Group{
                self.CircleChart(w: w , h: w )
                HStack{
                    self.leftInfo
                    Spacer()
                    self.rightInfo
                }
            }
        
        )
    }
    
    var body: some View {
        ChartCard(header: self.header, size: self.size, insideView: self.mainBody)
    }
}


extension CircleChart{
    
    var leftInfo:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "45k", fontSize: 30, color: .black, fontWeight: .semibold)
            MainText(content: "Likes", fontSize: 20, color: .black, fontWeight: .regular)
        }
    }
    
    var rightInfo:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "\(self.increase ? "↑" : "↓") 30%", fontSize: 17.5, color: .black, fontWeight: .semibold)
            MainText(content: "Since Last Week", fontSize: 12.5, color: .black, fontWeight: .regular)
        }
    }
    
    func drawCircle(w:CGFloat, animatable:Bool = false) -> some View{
        let chartW = w * 0.8
        let color = animatable ? Color.green.opacity(0.75) : Color.gray.opacity(0.25)
        return Circle()
            .trim(from: 0, to: animatable ? self.load ? CGFloat(self.percent/100) : 0 : 1)
            .stroke(color, lineWidth: w * 0.045)
            .frame(width: chartW , height: chartW , alignment: .center)
    }
}

struct CircleChart_Previews: PreviewProvider {
    static var previews: some View {
        CircleChart(percent: 35, header: "Likes")
    }
}

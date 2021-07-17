//
//  LineChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 16/06/2021.
//

import SwiftUI

struct LineChart: View {
    var data:[Float]
    var size:CGSize = .init(width: totalWidth, height: 250)
    @State private var loading:Bool = false
    init(data:[Float],size:CGSize? = nil){
        self.data = data
        if let safeSize = size{
            self.size = safeSize
        }
    }

    
    var body: some View {
        ZStack(alignment: .bottom){
            self.chartView
        }.frame(width: self.size.width, height: self.size.height * 1.5, alignment: .bottom)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 0)
        .onAppear(perform: {
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                withAnimation(.linear(duration: 0.85)) {
                    self.loading.toggle()
                }
            }
        })
    }
}


extension LineChart{
    
    private func xFactor(w:CGFloat) -> CGFloat{
        return w/CGFloat(self.data.count)
    }
    
    private func yCal(val:Float,h:CGFloat) -> CGFloat{
        guard let max = self.data.max(), let min = self.data.min() else{return 0}
        return CGFloat(1 - (val - min)/(max-min)) * h
    }
    
    private var chartView:some View{
        GeometryReader{g in
            let w = g.size.width
            let h = g.size.height
            
            Path{p in
                
                Array(self.data.enumerated()).forEach { _data in
                    let data = _data.element
                    let idx = _data.offset
                    
                    let xPoint = self.xFactor(w: w) * CGFloat(idx + 1)
                    let yPoint = self.yCal(val: data, h: h)
                    if idx == 0{
                        p.move(to: .init(x: 0, y: h))
                    }
                    p.addLine(to: .init(x: xPoint, y: yPoint))
                }
            }
            .trim(from: 0, to: self.loading ? 1 : 0.5)
            .stroke(Color.blue, style: .init(lineWidth: 1.75,lineCap: .round,lineJoin: .round))
            .shadow(color: .blue.opacity(1), radius: 2, x: 0, y: 0)
            .shadow(color: .blue.opacity(0.9), radius: 2, x: 0, y: 2.5)
            .shadow(color: .blue.opacity(0.8), radius: 3, x: 0, y: 5)
            .shadow(color: .blue.opacity(0.7), radius: 4, x: 0, y: 7.5)
            .shadow(color: .blue.opacity(0.6), radius: 5, x: 0, y: 10)
            .shadow(color: .blue.opacity(0.5), radius: 6, x: 0, y: 12.5)
            .shadow(color: .blue.opacity(0.1), radius: 7, x: 0, y: 15)
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
    }
    
}

struct LineChart_Previews: PreviewProvider {
    static var previews: some View {
        LineChart(data: [45,25,10,60,30,79,91,25,45,25,10,60,30,79,91,25,45,25,10,60,30,79,91,25,45,25,10,60,30,79,91].shuffled())
    }
}

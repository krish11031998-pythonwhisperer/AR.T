//
//  PriceTimeChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 06/06/2021.
//

import SwiftUI

struct PriceTimeChart: View {
    var header:String
    var data:[Float]
    var size:CGSize
    @State var cardOff:CGSize = .zero
    @State var selected:Int = -1
    @State var location:CGPoint = .zero
    
    let annotationCardSize:CGSize
    
    init(header:String,data:[Float] = Array(repeating: Float.random(in: 20..<150), count: 10),size:CGSize = .init(width: totalWidth * 0.9, height: totalHeight * 0.45)){
        self.header = header
        self.data = data
        self.size = size
        self.annotationCardSize = .init(width: size.width * 0.4, height: size.height * 0.35)
    }
    
    var diff_vals:[Float]{
        var newData:[Float] = []
        for idx in 1..<self.data.count{
            let diff = self.data[idx] - self.data[idx - 1]
            newData.append(diff)
        }
        return newData
}
    
    func findMax() -> Float{
        var total:Float = 0
        let res = self.diff_vals.map { val -> Float in
            total += val
            return abs(val)
        }
        return res.max() ?? 50
}

    func chartElement(size:CGSize,y_off:CGFloat,color:Color,idx:Int) -> AnyView{
        let w = size.width
        let h = size.height
        if idx == 0 || color == .black{
            return AnyView(Circle().fill(Color.black).frame(width: 7.5, height: 7.5, alignment: .center).offset(x: idx == 0 ? -3.75 : 0, y: 3.75).opacity(color == .black ? 0.25 : 1))
        }
        let view = AnyView(
            AnyView(RoundedRectangle(cornerRadius: 12.5)
                        .foregroundColor(color))
                .padding(.horizontal,3)
                .frame(width: w, height: h, alignment: .center)
                .shadow(color: color.opacity(0.4), radius: 10, x: 2.5, y: 5)
                .offset(y: y_off)
                .opacity(self.selected == -1 || self.selected == idx ? 1 : 0.5)
            
        )
        return view
}

    func onChanged(w_unit:CGFloat,value:DragGesture.Value){
        var location = value.location
        let x = location.x
        let y = location.y
        let w_factor = x + self.annotationCardSize.width > self.size.width * 0.9 ? x - self.annotationCardSize.width - 20 : x + self.annotationCardSize.width < self.size.width * 0.15 ? self.size.width * 0.15 : x + 20
        let h_factor = y + self.annotationCardSize.height > self.size.height * 0.7 ? y - self.annotationCardSize.height :  y + self.annotationCardSize.height < self.size.height * 0.15 ? self.annotationCardSize.height : y - self.annotationCardSize.height * 0.5
        let num = Int(x/w_unit) + 1
        
        if y + self.annotationCardSize.height < self.size.height * 0.2{
            print(location.y)
        }
        
        withAnimation(.easeInOut) {
            location.x = w_factor < 0 ? 0 : w_factor > self.size.width * 0.9 ? self.size.width * 0.9 - self.annotationCardSize.width : w_factor
            location.y = h_factor < 0 ? self.size.height * 0.15 : h_factor > self.size.height * 0.9 ? self.size.height * 0.9 - self.annotationCardSize.height : h_factor
            
            self.location = location
            self.selected = num > 0 && num < self.data.count - 1 ? num : -1
        }
}
    
    func onEnded(value:DragGesture.Value){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            withAnimation(.linear) {
                self.selected = -1
            }
        }
}
    
    func chartParams(val:Float,max:Float,idx:Int,h:CGFloat,g_off:CGFloat) -> (Color,CGFloat,CGFloat){
        let color:Color = val < 0 ? .red : val > 0 ? .green : .black
        let bar_h = CGFloat(abs(val)/max) * h
        let off = idx == 0 ? 0 : g_off + (val < 0 ? bar_h : -bar_h)
        return (color,bar_h,off)
    }
    
    
    func TimelineChart(w:CGFloat,h:CGFloat) -> AnyView{
        var view = AnyView(Circle().fill(Color.black))
        var max = self.findMax()
        max += max * 0.1
        let bar_w = (w/CGFloat(self.diff_vals.count))
        
        view = AnyView(
            ZStack(alignment: .center){
                Divider()
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .bottom, spacing: 0){
                        var g_off:CGFloat = 0
                        ForEach(0..<self.diff_vals.count,id: \.self) { idx -> AnyView  in
                            let val = self.diff_vals[idx]
                            let (color,bar_h,off) = self.chartParams(val: val, max: max, idx: idx, h: h * 0.5, g_off: g_off)
                            
                            let view = self.chartElement(size: .init(width: bar_w, height: bar_h), y_off: idx == 1 ? val < 0 ? bar_h : 0 : g_off + (val < 0 ? bar_h : 0), color: color, idx: idx)
                            g_off = off
                            return AnyView(view)
                        }
                        Spacer()
                    }.frame(width: w, height: h * 0.5, alignment: .bottom)
                    Spacer()
                }.frame(width: w, height: h, alignment: .center)
            }.gesture(DragGesture()
                        .onChanged({ value in
                            self.onChanged(w_unit: bar_w, value: value)
                        })
                        .onEnded(self.onEnded(value:))
            )
        )
        
        return view
    }
    
    func sectionInfo(heading:String,main:String,percent:Float? = nil,w:CGFloat,h:CGFloat,bg:Color = .clear) -> AnyView{
        let fontColor:Color = bg == .clear ? .black : .white
        return AnyView(
            VStack(alignment: .leading, spacing: 10){
                MainText(content: heading, fontSize: 10.5, color: .black, fontWeight: .regular)
                HStack(alignment: .center, spacing: 10){
                    MainText(content: main, fontSize: 17.5, color: .black, fontWeight: .semibold)
                    Spacer()
                    if let safePercent = percent{
                        MainText(content: "\(safePercent > 0 ? "+" : "-") \(abs(safePercent))", fontSize: 10.5, color: .black, fontWeight: .semibold)
                            .padding(7.5)
                            .aspectRatio(contentMode: .fill)
                            .background(bg)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 0)
                    }
                }
            }
            .padding()
            .frame(width: w, height: h * 0.5, alignment: .leading)
            .background(bg, alignment: .center)
        )
    }
    
    var infoCard:some View{

        return GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let val = String(format:"%.1f",self.data[self.selected + 1])
            let prev = String(format:"%.1f",self.data[self.selected])
            let diff = String(format:"%.1f",self.diff_vals[self.selected])
            let bg = self.diff_vals[selected] < 0 ? Color.red : Color.green
            
            
            VStack(alignment: .leading, spacing: 0){
                self.sectionInfo(heading: "Now", main: val, w: w, h: h, bg: .clear)
                self.sectionInfo(heading: "Difference", main: prev,percent: self.diff_vals[self.selected], w: w, h: h, bg: bg)
                
            }
        }
        .frame(width: self.annotationCardSize.width, height: self.annotationCardSize.height, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.3), radius: 10, x: 0.0, y: 0.0)
    }
    
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        return AnyView(
            Group{
                self.TimelineChart(w: w, h: h * 0.8)
            }
        )
    }
    
    var body: some View {
        ZStack(alignment: .leading){
            ChartCard(header: self.header, size: self.size, insideView: self.mainBody)
            if self.selected != -1{
                self.infoCard.offset(.init(width: self.location.x, height: self.location.y))
            }
        }
    }
}

struct PriceTimeChart_Previews: PreviewProvider {
    static var previews: some View {
        PriceTimeChart(header: "Price Timeline",data:[45,25,10,60,30,79,91,25,45,25,10,60,30,79,91,25,45,25,10,60,30,79,91,25].shuffled())
    }
}

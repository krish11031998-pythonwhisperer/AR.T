//
//  WeekBarChart.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 06/06/2021.
//

import SwiftUI




struct WeekBarChart: View {
    var header:String
    var weekData:[Int]
    var size:CGSize
    var week_h:[CGFloat] = []
    let fontColor:Color
//    let days:[String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    let days:[String] = ["S","M","T","W","T","F","S"]
    init(header:String,values:[Int],size:CGSize = .init(width: totalWidth * 0.45, height: 300),color:Color = .black){
        self.header = header
        self.weekData = values
        self.size = size
        self.fontColor = color
        self.normalizeWeekData()
        
    }
    
    mutating func normalizeWeekData(){
        guard let min = self.weekData.min() , let max = self.weekData.max() else {return}
        self.week_h = self.weekData.map({normalize(min: min, max: max, val: $0)})
    }
    
    var total:Int{
        return self.weekData.reduce(0, {$0 + $1})
    }
    
    func normalize(min:Int,max:Int,val:Int) -> CGFloat{
        let num = Float(val - min)
        let denom = Float(max - min)
        return CGFloat(num/denom)
    }

    func bar_op(x:Int,y:Int) -> Double{
        return Double(y > x  ? 1 : Float(y)/Float(x))
    }
    
    func barForBarChart(w:CGFloat,h:CGFloat,color:Color = .green,val:String? = nil) -> AnyView{
        let view = VStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundColor(color)
                .frame(width: w, height: h, alignment: .center)
                .padding(.all,0.5)
                .background(Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(color: color.opacity(0.5), radius: 3, x: 2.5, y: 5)
            if let v = val{
                MainText(content: v, fontSize: 9.5, color: fontColor, fontWeight: .regular)
                    .frame(width: w, alignment: .center)
            }
        }
        return AnyView(view)
    }
    
    func barChart(w:CGFloat,h:CGFloat) -> some View{
        let view = HStack(alignment: .bottom, spacing: 2.5) {
            ForEach(0..<self.week_h.count,id: \.self) { i in
                let data = self.week_h[i]
                let bar_h = data * h * 0.9
                let color = Color.green.opacity(1)
                let bar_w = (w/7) - 5
                
                self.barForBarChart(w:bar_w, h: bar_h,color: color,val: self.days[i])
//                self.barForBarChart(w:bar_w, h: bar_h,color: color,val: "\(opacity)")
            }
        }.frame(width: w, height: h, alignment: .center)
        
        return view
        
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        return AnyView(VStack(spacing: 10){
//                Group{
                    MainText(content: "Total Views", fontSize: 10, color: fontColor, fontWeight: .thin)
                    MainText(content: "\(self.total)k", fontSize: 35, color: fontColor, fontWeight: .bold)
//                        .padding(.vertical,10)
                    self.barChart(w: w, h: h * 0.45)
            })
    }
    
    var body: some View {
        ChartCard(header: self.header, size: self.size, insideView: self.mainBody)
    }
}

struct WeekBarChart_Previews: PreviewProvider {
    static var previews: some View {
        WeekBarChart(header: "Views",values: [25,45,60,10,30,79,91].shuffled())
            .previewLayout(.sizeThatFits)
    }
}

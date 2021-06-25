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
    @State var firstView:Bool = false
    @State var load:Bool = false
//    let days:[String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    let days:[String] = ["S","M","T","W","T","F","S"]
    init(header:String,values:[Int],size:CGSize = .init(width: totalWidth * 0.45, height: 300)){
        self.header = header
        self.weekData = values
        self.size = size
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
    
    func onAppear(){
        if !self.firstView{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                withAnimation(.easeInOut) {
                    self.load = true
                }
            }
        }
    }
    
    func barForBarChart(w:CGFloat,h:CGFloat,og_h:CGFloat,color:Color = .green,val:String? = nil) -> some View{
        let view = GeometryReader {g -> AnyView in
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if minY <= totalHeight * 0.7{
                    self.onAppear()
                }
                
            }
            
            return AnyView(VStack {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(color)
                    .frame(width: w, height: self.load ? h:  0, alignment: .center)
                    .padding(.all,0.5)
                    .background(Color.clear)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(color: color.opacity(0.5), radius: 3, x: 2.5, y: 5)
                if val != nil{
                    BasicText(content: val!, fontDesign: .monospaced, size: 9.5, weight: .regular)
                }
            }.frame(width: w, height: og_h, alignment: .bottom))
        }
        return view
    }
    
    func barChart(w:CGFloat,h:CGFloat) -> AnyView{
        let min = 0
        let max = self.weekData.max() ?? 1
        
        let view =
            
            GeometryReader {g -> AnyView in
                let minY = g.frame(in: .global).minY
                
                DispatchQueue.main.async {
                    if minY <= totalHeight * 0.4{
                        self.onAppear()
                    }
                }
                
                return AnyView (
                    HStack(alignment: .bottom, spacing: 4) {
                        ForEach(0..<self.weekData.count,id: \.self) { i in
                            let data = self.weekData[i]
                            let bar_h = normalize(min: min, max: max, val: data) * h
                            let opacity:Double = i == 0 ? 1 : bar_op(x: self.weekData[i - 1], y: self.weekData[i])
                            let color = Color.green.opacity(opacity)
                            let bar_w = (w/7) - 8
                            
                            self.barForBarChart(w:bar_w, h: bar_h,og_h: h,color: color,val: self.days[i])
                            //                self.barForBarChart(w:bar_w, h: bar_h,color: color,val: "\(opacity)")
                        }
                    }.frame(width: w, height: h, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                )
            }
        
        return AnyView(view)
        
    }
    
    func mainBody(w:CGFloat,h:CGFloat) -> AnyView{
        return AnyView(
            Group{
                VStack(spacing: 10){
                    BasicText(content: "Total Views", fontDesign: .serif, size: 10, weight: .thin)
                    BasicText(content: "\(self.total)k", fontDesign: .serif, size: 35, weight: .bold)
                }.padding(.vertical,10)
                self.barChart(w: w, h: h * 0.45)
            }
        )
    }
    
    var body: some View {
//        GeometryReader{g in
//            let local = g.frame(in: .local)
//            let w = local.width
//            let h = local.height
//
//
//            VStack(alignment: .center, spacing: 10){
//                BasicText(content: self.header, fontDesign: .serif, size: 20, weight: .semibold)
//                    .frame(width: w,alignment: .leading)
//                VStack(spacing: 10){
//                    BasicText(content: "Total Views", fontDesign: .serif, size: 10, weight: .thin)
//                    BasicText(content: "\(self.total)k", fontDesign: .serif, size: 35, weight: .bold)
//                }.padding(.vertical,10)
//                self.barChart(w: w, h: h * 0.45)
//            }
//
//
//        }.padding()
//        .frame(width: self.size.width, height: self.size.height, alignment: .center)
//        .background(Color.white)
//        .clipShape(RoundedRectangle(cornerRadius: 20))
//        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 2)
        ChartCard(header: self.header, size: self.size, insideView: self.mainBody)
    }
}

struct WeekBarChart_Previews: PreviewProvider {
    static var previews: some View {
        WeekBarChart(header: "Views",values: [25,45,60,10,30,79,91].shuffled())
            .previewLayout(.sizeThatFits)
    }
}

//
//  Components.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/5/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI

struct LineChart: Shape {
    var data:[CGFloat] = []
    func path(in rect: CGRect) -> Path {
        
        var xM = rect.width/CGFloat(self.data.count - 1)
        var yM = rect.height
//        print("xM:\(xM) and yM:\(yM)")
//        print(self.data)
        func point(_ index:Int) -> CGPoint{
            var x = CGFloat(index)*xM
            var y = (1 - self.data[index])*yM
            var result = CGPoint(x:x,y:y)
//
//            print(result)
            return result
        }
        return Path{p in
            guard data.count > 1 else {return}
            var startPoint = point(0)
            p.move(to: startPoint)
            for x in 0..<self.data.count{
                var px = point(x)
                p.addLine(to: px)
                
                p.addRect(CGRect(x: px.x, y:px.y,width: 1,height: 1))
                
            }
        }
    }
}

struct LineChartView:View{
    var data:[CGFloat] = []
    var title:String
    @State var animate:Bool = false
    var width:CGFloat = 300
    var height:CGFloat = 300
    
    var maxmin:(max:CGFloat,min:CGFloat){
        get{
            return (max:self.data.max() ?? 1.0,min:self.data.min() ?? 1.0)
        }
    }
    
    var normalizedData:[CGFloat]{
        get{
            var max = maxmin.max
            var min = maxmin.min
            var result = self.data.map { (temp) -> CGFloat in
                return (temp - min)/(max - min)
            }
            return result
        }
    }
    
    var body: some View {
        VStack{
            HStack {
                MainText(content: self.title, fontSize: 20, color: .purple, fontWeight: .regular).padding(.vertical).padding(.leading)
                Spacer()
                MainText(content: "H:\(String(format: "%.0F",(maxmin.max)))", fontSize: 17.5, color: .red, fontWeight: .thin)
                MainText(content: "L:\(String(format: "%.0F",(maxmin.min)))", fontSize: 17.5, color: .green, fontWeight: .thin)
                Spacer().frame(width:10)
            }
            LineChart(data: self.normalizedData)
                .trim(to: self.animate ? 1 : 0)
                .stroke(Color.red, lineWidth: 2)
                .frame(width:300,height:200)
                .animation(.easeInOut)
                .padding(.all)
        }.onAppear(perform: {
            withAnimation(.easeInOut(duration:2)){
                self.animate = true
            }
            
        }).padding(.all).background(RoundedRectangle(cornerRadius: 20).fill(Color.white.opacity(0.35)).padding(.all))
    }
}

struct Components_Previews: PreviewProvider {
    static var data = example.hourly.map({ (wp) -> CGFloat in
        return CGFloat(wp.temp - 273)
    })
    static var previews: some View {
        LineChartView(data: Array(Components_Previews.data[0...5]), title: "Next Few Hours")
    }
}

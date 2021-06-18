//
//  SideScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI

class TASScrollParams:ObservableObject{
    @Published var dy_off:CGFloat = 0.0
    @Published var st_off:CGFloat = 0.0
    @Published var swiped:Int = 0
    
}

struct TopArtScroll: View {
    var cardSize:CGSize = .init(width: totalWidth * 0.45, height: totalHeight * 0.4)
    @StateObject var SP:TASScrollParams = .init()
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
    
    func onChanged(value:DragGesture.Value){
        self.SP.dy_off = value.translation.width
    }
    
    
    func onEnded(value:DragGesture.Value){
        let dragValue = value.translation.width
        let incre = dragValue < 0 ? 1 : -1
        if abs(dragValue) > 50 && self.SP.swiped + incre >= 0 && self.SP.swiped + incre <= self.data.count - 1{
//            if self.SP.swiped < 3{
                self.SP.st_off += -CGFloat(incre) * cardSize.width
//            }
            self.SP.swiped += incre
        }
        self.SP.dy_off = 0
    }
    
    func imgCard(data:AVSData,idx: Int) -> some View{
        return GeometryReader{g -> AnyView in
            let local = g.frame(in: .local)
            let global = g.frame(in: .global)
            let w = local.width
            let h = local.height
            let midX = global.midX
            let mid_diff = midX - totalWidth * 0.5
            let skewX:Double = idx == self.SP.swiped ? 0 : (mid_diff < 0 ? 1 : -1) * 10
            
//            DispatchQueue.main.async {
//                if idx == self.SP.swiped &&  self.SP.dy_off == 0 && mid_diff != 0{
//                    self.SP.st_off -= mid_diff
//                }
//            }
            
            return AnyView(
                ZStack(alignment: .center) {
                    ImageView(url: data.img,heading: data.title, width: w, height: h, contentMode: .fill, alignment: .center,headingSize: 14)
                    if self.SP.swiped != idx{
                        BlurView(style: .regular)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .contentShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(idx == self.SP.swiped ? 1.2 : 1)
                .rotation3DEffect(.init(degrees: .init(skewX)),axis: (x: 0.0, y: 1.0, z: 0.0))
                .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
//                .transition(.move(edge: .leading))
            )
                
        }
        .frame(width: cardSize.width, height: cardSize.height, alignment: .center)
    }
    
    
    func computeParams(idx:Int) -> (Bool,CGFloat,CGFloat,Double){
        let isViewing = idx == self.SP.swiped
        let diff = CGFloat(idx - self.SP.swiped)
        let x_off:CGFloat = isViewing ? self.SP.dy_off : -cardSize.width * (isViewing && diff == 0 ? 0 : diff * 0.6)
        let zInd:Double = -Double(diff)
        return (isViewing,diff,x_off,zInd)
    }
    
    var spacerWidth:CGFloat{
        let w = (totalWidth - self.cardSize.width) * 0.5
        return self.SP.swiped < 2 ? CGFloat(2 - self.SP.swiped) * w * 0.5 : 0
    }


    var FancyHStack:some View{
        HStack(alignment: .center, spacing: 0){
            ForEach(Array(self.data.enumerated()),id: \.offset) {_data in
                let data = _data.element
                let idx = _data.offset
                let (isViewing,_,x_off,zInd) = self.computeParams(idx: idx)
                if idx >= self.SP.swiped - 3 && idx <= self.SP.swiped + 3{
                    self.imgCard(data: data,idx: idx)
                        .offset(x: isViewing ? self.SP.dy_off : x_off)
                        .zIndex(isViewing ? 1 : zInd > 0 ? -zInd : zInd)
                }else{
                    Color.clear
                        .frame(width: self.cardSize.width, height: self.cardSize.height, alignment: .center)
                        .offset(x: isViewing ? self.SP.dy_off : x_off)
                        .zIndex(isViewing ? 1 : zInd > 0 ? -zInd : zInd)
                }
                    
            }
        }
        .frame(width: totalWidth,height: cardSize.height + 10, alignment: .leading)
        .animation(.easeInOut(duration: 0.5))
        .offset(x: self.SP.st_off)
        .onAppear(perform: {
            self.SP.st_off = self.spacerWidth
        })
    }
    
    
    var body: some View {
            self.FancyHStack
                .padding(.vertical,75)
    }
}

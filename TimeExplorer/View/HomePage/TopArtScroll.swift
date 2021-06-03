//
//  SideScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 28/05/2021.
//

import SwiftUI

struct TopArtScroll: View {
    var cardSize:CGSize = .init(width: totalWidth * 0.45, height: totalHeight * 0.4)
    @State var dy_off:CGFloat = 0.0
    @State var st_off:CGFloat = 0.0
    @State var swiped:Int = 0
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
    
    func onChanged(value:DragGesture.Value){
        self.dy_off = value.translation.width
    }
    
    
    func onEnded(value:DragGesture.Value){
        let dragValue = value.translation.width
        let incre = dragValue < 0 ? 1 : -1
        if abs(dragValue) > 50 && self.swiped + incre >= 0 && self.swiped + incre <= self.data.count - 1{
            self.swiped += incre
            self.st_off += CGFloat(-incre) * cardSize.width * 0.6
        }
        self.dy_off = 0
    }
    
    func imgCard(data:AVSData,idx: Int) -> some View{
        return GeometryReader{g -> AnyView in
            let local = g.frame(in: .local)
            let global = g.frame(in: .global)
            let w = local.width
            let h = local.height
//            let minX = global.minX
            let midX = global.midX
//            let skewX:Double = minX > 10 ? -10 : 0
            let mid_diff = midX - totalWidth * 0.5
            let skewX:Double = idx == self.swiped ? 0 : (mid_diff < 0 ? 1 : -1) * 10
            
            DispatchQueue.main.async {
                if idx == self.swiped && mid_diff != 5 && self.dy_off == 0{
                    self.st_off += -mid_diff
                }
            }
            
            
            return AnyView(
                ZStack(alignment: .center) {
                    ImageView(url: data.img, width: w, height: h, contentMode: .fill, alignment: .center, testMode: false)
                    if self.swiped != idx{
                        BlurView(style: .regular)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
//                .contentShape(RoundedRectangle(cornerRadius: 20))
                .scaleEffect(idx == self.swiped ? 1.2 : 1)
                .rotation3DEffect(.init(degrees: .init(skewX)),axis: (x: 0.0, y: 1.0, z: 0.0))
                
                .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
                .transition(.move(edge: .leading))
            )
                
        }
        .frame(width: cardSize.width, height: cardSize.height, alignment: .center)
    }
    
    
    func computeParams(idx:Int) -> (Bool,CGFloat,CGFloat,Double){
        let isViewing = idx == self.swiped
        let diff = CGFloat(idx - self.swiped)
        let x_off:CGFloat = isViewing ? self.dy_off : -cardSize.width * (isViewing && diff == 0 ? 0 : diff * 0.6)
        let zInd:Double = -Double(diff)
        return (isViewing,diff,x_off,zInd)
    }
    
    var spacerWidth:CGFloat{
        let w = (totalWidth - cardSize.width) * 0.5
        return self.swiped < 2 ? CGFloat(2 - self.swiped) * w * 0.5 : 0
    }


    var FancyHStack:some View{
        HStack(alignment: .center, spacing: 0){
            ForEach(Array(self.data.enumerated()),id: \.offset) {_data in
                let data = _data.element
                let idx = _data.offset
                let (isViewing,_,x_off,zInd) = self.computeParams(idx: idx)
//                if idx >= self.swiped - 4 && idx <= self.swiped + 4{
                self.imgCard(data: data,idx: idx)
                    .offset(x: isViewing ? self.dy_off : x_off)
                    .zIndex(isViewing ? 1 : zInd > 0 ? -zInd : zInd)
//                }
//                
            }
        }
        .frame(width: totalWidth, alignment: .leading)
        .animation(.easeInOut(duration: 0.5))
        .offset(x: self.st_off)
        .onAppear(perform: {
            self.st_off = self.spacerWidth
        })
    }
    
    
    var body: some View {
//        LazyVStack(alignment: .leading, spacing: 10){
            //            Spacer()
            self.FancyHStack.padding(.vertical,25)
            //            Spacer()
//        }
        .padding(.vertical,50)
        
    }
}

//struct SideScroll_Previews: PreviewProvider {
//    static var previews: some View {
//        SideScroll()
//    }
//}

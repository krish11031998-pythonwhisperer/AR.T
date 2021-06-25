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
    @StateObject var IMD:ImageDownloader = .init()
    let cards:Int = 3
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
    func onAppear(){
        let imgs = self.data.compactMap({$0.img})
        if imgs.count > 0{
            self.IMD.getImages(urls: imgs)
        }
    }
    
    func imgCard(data:AVSData,idx: Int) -> some View{
        let viewing = idx == self.SP.swiped
        let skewX:Double = viewing ? 0 : (idx < self.SP.swiped ? 1 : -1) * 10
        return ImageView(url: data.img, width: cardSize.width, height: cardSize.height, contentMode: .fill, alignment: .center,isHidden: !viewing)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .scaleEffect(idx == self.SP.swiped ? 1.2 : 1)
            .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
            .frame(width: cardSize.width, height: cardSize.height, alignment: .center)
            .rotation3DEffect(.init(degrees: .init(skewX)),axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    var FancyHStack:some View{
        HStack(alignment: .center, spacing: 0){
            Spacer().frame(width: self.spacerWidth, alignment: .center)
            ForEach(Array(self.data.enumerated()),id: \.offset) {_data in
                let data = _data.element
                let idx = _data.offset
                let (isViewing,_,x_off,zInd) = self.computeParams(idx: idx)
                if idx >= self.SP.swiped - cards  && idx <= self.SP.swiped + cards{
                    self.imgCard(data: data,idx: idx)
                        .offset(x: isViewing ? self.SP.dy_off : x_off)
                        .zIndex(isViewing ? 1 : zInd > 0 ? -zInd : zInd)
                }
            }
        }
        .frame(width:totalWidth,height: cardSize.height + 10, alignment: .leading)
        .offset(x: self.SP.st_off)
        .animation(.easeInOut(duration: 0.5))
    }
    
    
    var body: some View {
//        LazyVStack{
            self.FancyHStack
            .padding(.vertical,50)
//        }
    }
}

extension TopArtScroll{
    func onChanged(value:DragGesture.Value){
        self.SP.dy_off = value.translation.width
    }
    
    
    func onEnded(value:DragGesture.Value){
        let dragValue = value.translation.width
        let incre = dragValue < 0 ? 1 : -1
        if abs(dragValue) > 50 && self.SP.swiped + incre >= 0 && self.SP.swiped + incre <= self.data.count - 1{
            self.SP.st_off += -CGFloat(incre) * cardSize.width
//            self.SP.st_off += -CGFloat(incre) * totalWidth * 0.2
            self.SP.swiped += incre
        }
        self.SP.dy_off = 0
    }
    
    var spacerWidth:CGFloat{
        let w = (totalWidth - self.cardSize.width) * 0.5
        return 2 * w * 0.5 + CGFloat(self.SP.swiped < cards ? 0 : self.SP.swiped - cards) * cardSize.width
    }
    
    func computeParams(idx:Int) -> (Bool,CGFloat,CGFloat,Double){
        let isViewing = idx == self.SP.swiped
        let diff = CGFloat(idx - self.SP.swiped)
        let x_off:CGFloat = isViewing ? self.SP.dy_off : -cardSize.width * (isViewing && diff == 0 ? 0 : diff * 0.6)
        let zInd:Double = -Double(diff)
        return (isViewing,diff,x_off,zInd)
    }
}

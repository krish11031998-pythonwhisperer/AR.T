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
    var cardSize:CGSize = .init(width: totalWidth * 0.5, height: totalHeight * 0.4)
    @StateObject var SP:TASScrollParams = .init()
    @StateObject var IMD:ImageDownloader = .init(mode:"multiple")
    let cards:Int = 2
    var data:[AVSData] = []
    
    init(data:[AVSData]){
        self.data = data
    }
    
//    func onAppear(){
//        if !self.data.isEmpty && self.IMD.loading{
//            let urls = self.data.compactMap({$0.img})
//            print("TopScroll urls : ",urls)
//            self.IMD.getImages(urls: urls)
//        }
//    }
    
    var FancyHStack:some View{
        HStack(alignment: .center, spacing: 0){
            Spacer().frame(width: self.spacerWidth, alignment: .center)
            ForEach(Array(self.data.enumerated()),id: \.offset) {_data in
                let data = _data.element
                let idx = _data.offset
                let (isViewing,_,x_off,zInd) = self.computeParams(idx: idx)
                let viewing = idx == self.SP.swiped
                let skewX:Double = viewing ? 0 : (idx < self.SP.swiped ? 1 : -1) * 10
                
                if let img_url = data.img,idx >= self.SP.swiped - cards  && idx <= self.SP.swiped + cards{
                    let img = self.IMD.images[img_url]
                    ImageView(url: data.img, width: cardSize.width, height: cardSize.height, contentMode: .fill, alignment: .center,isHidden: !viewing)
//                    ImageView(img:img, width: cardSize.width, height: cardSize.height, contentMode: .fill, alignment: .center,isHidden: !viewing)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .scaleEffect(idx == self.SP.swiped ? 1.2 : 1)
                        .frame(width: cardSize.width, height: cardSize.height, alignment: .center)
                        .rotation3DEffect(.init(degrees: .init(skewX)),axis: (x: 0.0, y: 1.0, z: 0.0))
                        .offset(x: isViewing ? self.SP.dy_off : x_off)
                        .zIndex(isViewing ? 1 : zInd > 0 ? -zInd : zInd)
//                        .opacity(abs(self.SP.swiped - idx) > 2 ? 0  : 1)
                }
            }
        }
        .frame(width:totalWidth,height: cardSize.height + 10, alignment: .leading)
        .offset(x: self.SP.st_off)
        .animation(.easeInOut(duration: 0.5))
        .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
//        .onAppear(perform:self.onAppear)
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
        let x_off:CGFloat = isViewing ? self.SP.dy_off : -cardSize.width * (isViewing && diff == 0 ? 0 : diff * 0.65)
        let zInd:Double = -Double(diff)
        return (isViewing,diff,x_off,zInd)
    }
}

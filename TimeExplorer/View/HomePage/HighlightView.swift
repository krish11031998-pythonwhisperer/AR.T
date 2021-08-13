//
//  HighlightView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 22/07/2021.
//

import SwiftUI

struct HighlightView: View {
    var data:[AVSData]
    @StateObject var SP:swipeParams
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    init(data:[AVSData]){
        self.data = data
        self._SP = .init(wrappedValue: .init(0, data.count - 1, 50, type: .Carousel))
    }
    
    var offset:CGFloat{
        return self.SP.swiped > 0 ? -totalWidth : 0
    }
    
    func checkTime(){
        DispatchQueue.main.async {
            if self.time != 10{
                self.time += 1
            }else{
                self.time = 0
                self.SP.swiped  = self.SP.swiped + 1 < self.data.count ? self.SP.swiped + 1 : 0
            }
        }
    }
    
    var CarouselView:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            ZStack(alignment: .leading) {
                ForEach(Array(self.data.enumerated()), id: \.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    let off = idx > self.SP.swiped ? totalWidth : 0
                    let scale:CGFloat = idx < self.SP.swiped ? 0.9 : 1
                    if idx >= self.SP.swiped - 1 && idx <= self.SP.swiped + 1{
                        AuctionCard(idx: idx, data: data, size: .init(width: w, height: h))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .offset(x: off)
                            .scaleEffect(scale)
//                        ImageView(url: data.img, heading: data.title, width: w, height: h, contentMode: .fill, alignment: .center, quality: .lowest)
                        
                    }
                }
            }
        }.padding(5)
        .frame(width: totalWidth, height: totalHeight * 0.5, alignment: .center)
        .animation(.linear(duration: 0.35))
        .onReceive(self.timer) { _ in self.checkTime()}
        
    }
    

    var body: some View {
        self.CarouselView
//            .offset(x: self.SP.extraOffset + self.offset)
//        ImageView(width: totalWidth, height: totalHeight * 0.75, contentMode: .fill, alignment: .center)
    }
}

struct HighlightView_Previews: PreviewProvider {
    static var previews: some View {
        HighlightView(data: Array(repeating: asm, count: 5))
    }
}

//
//  FancyHCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 18/08/2021.
//

import SwiftUI

struct FancyHCarousel: View {
    var views:[AnyView]
    //    var view: (CGSize) -> AnyView
    var size:CGSize
    var headers:[String]?
    @StateObject var SP:swipeParams
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    
    init(views:[AnyView],headers:[String]? = nil,size:CGSize){
        self.views = views
        self._SP = StateObject(wrappedValue: .init(0, views.count - 1, 100, type: .Carousel))
        self.size = size
        self.headers = headers
    }
    
    func scaleEff(midX:CGFloat) -> CGFloat{
        let thres:CGFloat = totalWidth * 0.25
        let tar = totalWidth * 0.15
        var perc = (midX - tar)/(thres - tar)
        perc = midX > totalWidth ? (perc > 1 ? 1 : perc < 0 ? 0 : perc) : 1 - (perc > 1 ? 1 : perc < 0 ? 0 : perc)
        let scale = midX < thres || midX > (1 - thres) ? 1 - 0.2 * CGFloat(perc) : 1
        return scale
    }
    
    
    func Card(view:AnyView,size:CGSize) -> some View{
        return GeometryReader{g in
            let midX = g.frame(in: .global).midX
            view
                .frame(width: size.width, height: size.height, alignment: .center)
                .scaleEffect(scaleEff(midX: midX))
            
            
        }.frame(width: size.width, height: size.height, alignment: .center)
            .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
    }
    
    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * totalWidth
    }
    
    func onReceiveTimer(){
        if self.time == 10{
            withAnimation(.easeInOut) {
                self.SP.swiped = self.SP.swiped + 1 <= self.views.count - 1 ? self.SP.swiped + 1 : 0
            }
        }else{
            self.time += 1
        }
    }
    
    func resetTimer(_ idx:Int){
        self.time = 0
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let timeBlob_h = self.size.height * 0.1 - 5
            let mainView_h = self.size.height * ( self.headers == nil ? 1 : 0.9) - 5

            HStack(alignment: .center, spacing: 20) {
                ForEach(Array(self.views.enumerated()),id:\.offset) { _view in
                    let view = _view.element
                    let idx = _view.offset
                    self.Card(view: view, size: CGSize(width: size.width, height: mainView_h))
                        .id(idx)
                }
            }
            
            .offset(x: self.SP.extraOffset + self.offset)
            Spacer()
        }
//        .animation(.easeInOut)
        .frame(width:size.width,height: size.height, alignment: .leading)
        .onReceive(self.timer, perform: { _ in
            self.onReceiveTimer()
        })
        .onChange(of: self.SP.swiped, perform: self.resetTimer)
//        .animation(.easeInOut)
    }
}

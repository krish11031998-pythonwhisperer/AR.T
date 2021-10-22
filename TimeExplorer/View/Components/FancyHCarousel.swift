//
//  FancyHCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 18/08/2021.
//

import SwiftUI

struct FancyHCarousel<T:View>: View {
    var views:[T]
    //    var view: (CGSize) -> AnyView
    var size:CGSize
    var headers:[String]?
    @StateObject var SP:swipeParams
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    
    init(views:[T],headers:[String]? = nil,size:CGSize){
        self.views = views
        self._SP = StateObject(wrappedValue: .init(0, views.count - 1, 100, type: .Carousel))
        self.size = size
        self.headers = headers
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
                    
                    view
                        .horizontalAnimation(size: CGSize(width: size.width, height: mainView_h))
                        .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
                        .id(idx)
                        
                }
            }
            
            .offset(x: self.SP.extraOffset + self.offset)
            Spacer()
        }
//        .animation(.easeInOut)
        .frame(width:size.width,height: size.height, alignment: .leading)
        .onReceive(self.timer, perform: { _ in self.onReceiveTimer()})
        .onChange(of: self.SP.swiped, perform: self.resetTimer)
    }
}

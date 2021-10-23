//
//  FancyHCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 18/08/2021.
//

import SwiftUI

struct FancyHCarousel<T:View>: View {
    var data:[Any]
    var viewGenrator:(Any) -> T
    var onClickHandle:(Any) -> Void
//    var views:[T]
    //    var view: (CGSize) -> AnyView
    var size:CGSize
    var headers:[String]?
    @StateObject var SP:swipeParams
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State var time:Int = 0
    
    init(data:[Any],headers:[String]? = nil,size:CGSize, @ViewBuilder viewGen:@escaping (Any) -> T,clickHandle : @escaping (Any) -> Void){
        self.data = data
        self.viewGenrator = viewGen
        self.onClickHandle = clickHandle
        self._SP = StateObject(wrappedValue: .init(0, data.count - 1, 100, type: .Carousel))
        self.size = size
        self.headers = headers
    }
    
    
    var offset:CGFloat{
        return -CGFloat(self.SP.swiped) * totalWidth
    }
    
    func onReceiveTimer(){
        if self.time == 15{
            withAnimation(.easeInOut) {
                self.SP.swiped = self.SP.swiped + 1 <= self.data.count - 1 ? self.SP.swiped + 1 : 0
            }
        }else{
            self.time += 1
        }
    }
    
    func resetTimer(_ idx:Int){
        self.time = 0
    }
    
    func onChanged(val:DragGesture.Value){
        let w_trans = val.translation.width
        if abs(w_trans) > 10{
            self.SP.onChanged(ges_value: val)
        }
    }
    
    
    func onEnded(val:DragGesture.Value){
        let w_trans = val.translation.width
        let h_trans = val.translation.height
        if abs(w_trans) > 10{
            self.SP.onEnded(ges_value: val)
        }else if abs(h_trans) == 0{
            self.onClickHandle(data[self.SP.swiped])
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            let timeBlob_h = self.size.height * 0.1 - 5
            let mainView_h = self.size.height * ( self.headers == nil ? 1 : 0.9) - 5

            HStack(alignment: .center, spacing: 20) {
                ForEach(Array(self.data.enumerated()),id:\.offset) { _data in
                    let data = _data.element
                    let idx = _data.offset
                    
                    viewGenrator(data)
                        .horizontalAnimation(size: CGSize(width: size.width, height: mainView_h))
                        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                    .onChanged(self.onChanged(val:))
                                    .onEnded(self.onEnded(val:)))
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

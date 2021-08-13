//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI
import Combine

struct AVSData{
    var img:String?
    var title:String?
    var subtitle:String?
    var data:Any?
}

struct AVScrollView: View {
    var data:[AVSData] = []
    @EnvironmentObject var e_SP:swipeParams
    @StateObject var IMD:ImageDownloader
    @StateObject var _SP:swipeParams
    var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State var time:Int = 0
    var haveTimer:Bool
    var cancellable =  Set<AnyCancellable>()
//    var cardView:((AVSData,swipeParams) -> AnyView)? = nil
    var cardView:((EnumeratedSequence<[AVSData]>.Element) -> AnyView)? = nil
    var leading:Bool
    var includeChart:Bool

    init(attractions attr:[AVSData],cardView:((EnumeratedSequence<[AVSData]>.Element) -> AnyView)? = nil,haveTimer:Bool = false,leading:Bool = true,chart:Bool = false){
        self.data = attr
        self.cardView = cardView
        self._IMD = StateObject(wrappedValue: .init(urls: attr.compactMap({$0.img}), mode: "multiple", quality: .low))
        self.__SP = StateObject(wrappedValue: .init(0, attr.count - 1, 100))
        self.leading = leading
        self.includeChart = chart
        self.haveTimer = haveTimer
        if haveTimer{
            self.timer.connect().store(in: &cancellable)
        }
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5)
    
    
    var SP:swipeParams{
        return self.cardView != nil ? self.e_SP  : self._SP
    }
    
    func checkTime(){
        if !self.haveTimer {return}
        if time < 10 {
            self.time += 1
        }else{
            self.time = 0
            self.SP.swiped = self.SP.swiped + 1 < self.data.count - 1 ? self.SP.swiped + 1 : 0
        }
    }
    
    func imgView(idx:Int,data:AVSData) -> AnyView{
        let view =
            
            GeometryReader{ g -> AnyView in
                let local = g.frame(in: .local)
//                let global = g.frame(in: .global)
                let selected = self.SP.swiped == idx
                let w = local.width
                let h = local.height
                let scale:CGFloat = selected ? 1.05 : 0.9
                
                let view = ZStack(alignment: .bottom) {
                    ImageView(url: data.img, width: w, height: h, contentMode: .fill, alignment: .center)
                    lightbottomShadow.frame(width: w + 1, alignment: .center)
                    if selected && !self.includeChart{
                            BasicText(content: data.title ?? "No Heading", fontDesign: .serif, size: 15, weight: .semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: w, alignment: .leading)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                    if includeChart{
                        CurveChart(data: [45,25,10,60,30,79], size: .init(width: w * 0.75, height: h * 0.3),bg: .clear,lineColor: .white,chartShade: false)
                            .frame(width: w, alignment: .leading)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: selected ? 20 : 10))
                .shadow(radius: selected ? 10 : 0)
                .scaleEffect(scale)
                .opacity(selected ? 1 : 0.2)
                .gesture(DragGesture().onChanged(self.SP.onChanged(ges_value:)).onEnded(self.SP.onEnded(ges_value:)))
                .onTapGesture {
                    self.SP.swiped = idx
                }
                
                return AnyView(view)
                
            }.padding()
            .frame(width: self.cardSize.width , height: self.cardSize.height, alignment: .center)
        
        
        
        return AnyView(view.id(idx))
    }
    

    var scrolledOffset:CGFloat{
        let off =  CGFloat(self.SP.swiped >= 2 ? 2 : self.SP.swiped < 0 ? 0 : self.SP.swiped) * -(self.cardSize.width) - 10
        return off
    }
    
    
    var v2:some View{
        HStack(alignment: .center, spacing: 0){
            Spacer().frame(width: self.leading ? (totalWidth - self.cardSize.width) * 0.5 : 0)
            ForEach(Array(self.data.enumerated()),id: \.offset){ _attr in
                let attr = _attr.element
                let idx = _attr.offset
                
                if idx >= self.SP.swiped - 2 && idx <= self.SP.swiped + 2{
                    self.cardView?(_attr) ?? self.imgView(idx:idx,data: attr)
                }
            }
            Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
        }
        .edgesIgnoringSafeArea(.horizontal)
        .frame(width:totalWidth,height: cardSize.height * 1.01,alignment: .leading)
        .padding(.leading,10)
        .offset(x: self.scrolledOffset)
        .offset(x: self.SP.extraOffset)
        .animation(.easeInOut(duration: 0.65))
        
    }
    
    var body: some View{
            self.v2
                .onReceive(self.timer, perform: {_ in self.checkTime()})
    }
}

//struct AVScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVScrollView()
//    }
//}

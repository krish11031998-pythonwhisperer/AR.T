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

struct AVScrollView:View {
    @EnvironmentObject var mainStates:AppStates
    var data:[AVSData] = []
    var leading:Bool
    var includeChart:Bool

    init(attractions attr:[AVSData],leading:Bool = true,chart:Bool = false){
        self.data = attr
        self.leading = leading
        self.includeChart = chart
    }

    let cardSize:CGSize = .init(width: totalWidth * 0.6, height: totalHeight * 0.5)


    func imgView(idx:Int,data:AVSData) -> some View{
        ImageView(url: data.img, width: self.cardSize.width, height: self.cardSize.height , contentMode: .fill, alignment: .center)
            .modifier(ImageOverlayModifier(size: self.cardSize,clipping: .roundClipping, innerView: {
                if !self.includeChart{
                    BasicText(content: data.title ?? "No Heading", fontDesign: .serif, size: 15, weight: .semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: self.cardSize.width, alignment: .leading)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }else{
                    CurveChart(data: [45,25,10,60,30,79], size: .init(width: self.cardSize.width * 0.75, height: self.cardSize.height * 0.3),bg: AnyView(Color.clear),lineColor: .white,chartShade: false)
                        .frame(width: self.cardSize.width, alignment: .leading)
                }
            }))
            .horizontalAnimation(size: self.cardSize)
            .buttonify {
                if let data = data.data as? CAData, let art = data.parseToArtData(), !self.mainStates.showArt && self.mainStates.selectedArt == nil{
                    withAnimation(.linear) {
                        self.mainStates.selectedArt = art
                    }
                }
            }
    }


    var v2:some View{
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 10){
                Spacer().frame(width: self.leading ? (totalWidth - self.cardSize.width) * 0.5 : 0)
                ForEach(Array(self.data.enumerated()),id: \.offset){ _attr in
                    let attr = _attr.element
                        self.imgView(idx:idx,data: attr)
                }
                Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
            }.animation(.easeInOut )
        }
        .edgesIgnoringSafeArea(.horizontal)
        .frame(width:totalWidth,height: cardSize.height * 1.01,alignment: .leading)
        
    }

    var body: some View{
            self.v2
//                .onReceive(self.timer, perform: {_ in self.checkTime()})
    }
}
//struct CardSize{
//    static var slender = CGSize(width: totalWidth * 0.6, height: totalHeight * 0.5)
//    static var small = CGSize(width: totalWidth * 0.45, height: totalHeight * 0.2)
//}
//
//
//struct CardSlidingView: View {
//    var cardSize:CGSize
//    var views:Array<AnyView>
//    @StateObject var SP:swipeParams
//    var leading:Bool
//    init(cardSize:CGSize = CardSize.slender,views:Array<AnyView>,leading:Bool = true){
//        self.cardSize = cardSize
//        self.views = views
//        self.leading = leading
//        self._SP = .init(wrappedValue: .init(0, views.count - 1, 100, type: .Carousel))
//    }
//
//    var scrolledOffset:CGFloat{
//        let off =  CGFloat(self.SP.swiped >= 2 ? 2 : self.SP.swiped < 0 ? 0 : self.SP.swiped) * -(self.cardSize.width) - 10
//        return off
//    }
//
//
//    func zoomInOut(view:AnyView) -> some View{
//        GeometryReader{g in
//            let midX = g.frame(in: .global).midX
//            let diff = abs(midX - (totalWidth * 0.5))/totalWidth
//            let diff_percent = (diff > 0.25 ? 1 : diff/0.25)
//            let scale = 1 - 0.075 * diff_percent
//
//            view.scaleEffect(scale)
//
//        }.frame(width: cardSize.width, height: cardSize.height, alignment: .center)
//    }
//
//
//    var body: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            LazyHStack(alignment: .center, spacing: 0){
//                Spacer().frame(width: self.leading ? (totalWidth - self.cardSize.width) * 0.5 : 0)
//                ForEach(Array(self.views.enumerated()),id: \.offset){ _view in
//                    let view = _view.element
//                    zoomInOut(view: view)
//                }
//                Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
//            }
//
//        }
//        .frame(height: cardSize.height * 1,alignment: .leading)
//    }
//}


//struct AVScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        AVScrollView()
//    }
//}

//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI

struct AVSData{
    var img:String?
    var title:String?
    var subtitle:String?
    var data:Any?
}


struct AVScrollView: View {
    var data:[AVSData] = []
    @State var scroll:Int = 0
    @State var offset:CGFloat = 0.0
    var cardView:AnyView? = nil

    init(attractions attr:[AVSData]? = nil,cardView:AnyView? = nil){
        if let attr = attr{
            self.data = attr
        }else{
            let test = attractionExample.map({AVSData(img: $0.photo?.images?.original?.url, title: $0.name, subtitle: nil, data: $0 as Any?)})
            self.data = test
            self.data.append(contentsOf: test)
        }
        self.cardView = cardView
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.65, height: totalHeight * 0.45)
    
    
    func imgView(idx:Int,data:AVSData) -> AnyView{
        let view =
            
            GeometryReader{ g -> AnyView in
                let local = g.frame(in: .local)
//                let global = g.frame(in: .global)
                let selected = self.scroll == idx
                let w = local.width
                let h = local.height
                let scale:CGFloat = self.scroll == idx ? 1 : 0.9
                
                let view = ZStack(alignment: .bottom) {
                    ImageView(url: data.img,width: w, height: h, contentMode: .fill, alignment: .center,testMode: true)
                    
                    if selected{
                        ZStack(alignment: .bottom){
                            lightbottomShadow.frame(width: w + 1, alignment: .center)
                            BasicText(content: data.title ?? "No Heading", fontDesign: .serif, size: 15, weight: .semibold)
                                .foregroundColor(.white)
                                .padding()
                                .frame(width: w, alignment: .leading)
                        }.transition(.move(edge: .bottom).combined(with: .opacity))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: selected ? 20 : 10))
                .scaleEffect(scale)
                
                return AnyView(view)
                
            }.padding()
            .frame(width: self.cardSize.width , height: self.cardSize.height, alignment: .center)
        
        
        
        return AnyView(view.id(idx))
    }
    

    var scrolledOffset:CGFloat{
        let off =  CGFloat(self.scroll >= 2 ? 2 : self.scroll < 0 ? 0 : self.scroll) * -(self.cardSize.width) - 10
//        let off =  CGFloat(self.scroll >= 1 ? 1 : 0) * -(self.cardSize.width)
//        let off = -CGFloat(self.scroll) * self.cardSize.width
        return off
    }
    
    
    
    func onChanged(value:DragGesture.Value){
        self.offset = value.translation.width
    }
    
    func onEnded(value:DragGesture.Value){
        let condition = self.scroll >= 0 && self.scroll <= self.data.count - 1
        let w = value.translation.width
        let add = self.scroll + (w < 0 ? 1 : -1)
        if condition{
            if abs(w) > 100 && add >= 0 && add <= self.data.count - 1{
                self.scroll = add
            }
        }
        self.offset = 0
    }
        
    var v2:some View{
        HStack(alignment: .center, spacing: 0){
            Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
            ForEach(Array(self.data.enumerated()),id: \.offset){ _attr in
                let attr = _attr.element
                let idx = _attr.offset
                
                if idx >= self.scroll - 2 && idx <= self.scroll + 2{
                    self.imgView(idx:idx,data: attr)
                }
            }
            Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
        }
        .edgesIgnoringSafeArea(.horizontal)
        .padding(.leading,10)
        .frame(width:totalWidth,height: totalHeight * 0.5,alignment: .leading)
        .offset(x: self.scrolledOffset)
        .offset(x: self.offset)
        .gesture(DragGesture().onChanged(self.onChanged(value:)).onEnded(self.onEnded(value:)))
        .animation(.easeInOut(duration: 0.65))
    }
    
    var body: some View{
        self.v2
    }
}

struct AVScrollView_Previews: PreviewProvider {
    static var previews: some View {
        AVScrollView()
    }
}

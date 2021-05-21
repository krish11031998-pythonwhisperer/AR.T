//
//  AVScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/05/2021.
//

import SwiftUI

struct AVScrollView: View {
    var attractions:[AttractionModel] = []
    @State var scroll:Int = 0
    @State var offset:CGFloat = 0.0

    init(attractions attr:[AttractionModel]? = nil){
        if let attr = attr{
            self.attractions = attr
        }else{
            self.attractions = attractionExample
            self.attractions.append(contentsOf: attractionExample)
        }
    }
    
    let cardSize:CGSize = .init(width: totalWidth * 0.65, height: totalHeight * 0.4)
    
    
    func imgView(idx:Int,attr:AttractionModel) -> AnyView{
        let view =
            
            GeometryReader{ g -> AnyView in
                let local = g.frame(in: .local)
//                let global = g.frame(in: .global)
                let w = local.width
                let h = local.height
                let scale:CGFloat = self.scroll == idx ? 1 : 0.9
                
                let view = ZStack(alignment: .bottom) {
                    ImageView(url: attr.photo?.images?.original?.url,width: w, height: h, contentMode: .fill, alignment: .center,testMode: false)
                    bottomShadow.frame(width: w, alignment: .center)
                    BasicText(content: attr.name ?? "Attraction", fontDesign: .serif, size: 15, weight: .semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: w, alignment: .leading)
                }
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .scaleEffect(scale)
                
                return AnyView(view)
                
            }.padding()
            .frame(width: self.cardSize.width , height: self.cardSize.height, alignment: .center)
        
        
        
        return AnyView(view.id(idx))
    }
    

    var scrolledOffset:CGFloat{
        let off =  CGFloat(self.scroll >= 2 ? 2 : self.scroll < 0 ? 0 : self.scroll) * -(self.cardSize.width)
//        let off =  CGFloat(self.scroll >= 1 ? 1 : 0) * -(self.cardSize.width)
        return off
    }
    
    
    
    func onChanged(value:DragGesture.Value){
        self.offset = value.translation.width
    }
    
    func onEnded(value:DragGesture.Value){
        let condition = self.scroll >= 0 && self.scroll <= self.attractions.count - 1
        let w = value.translation.width
        let add = self.scroll + (w < 0 ? 1 : -1)
        if condition{
            if abs(w) > 100 && add >= 0 && add <= self.attractions.count - 1{
                self.scroll = add
            }
        }
        self.offset = 0
    }
        
    var v2:some View{
        LazyHStack(alignment: .center, spacing: 0){
            Spacer().frame(width: (totalWidth - self.cardSize.width) * 0.5)
            ForEach(Array(self.attractions.enumerated()),id: \.offset){ _attr in
                let attr = _attr.element
                let idx = _attr.offset
                
                if idx >= self.scroll - 2 && idx <= self.scroll + 2{
                    self.imgView(idx:idx,attr: attr)
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
        .animation(.easeInOut(duration: 0.75))
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

//
//  FancyScroll.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 08/05/2021.
//

import SwiftUI

extension CGSize{
    static func + (lhs:CGSize,rhs:CGSize) -> CGSize{
        return .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }
}

extension CGRect{
    func centralize() -> CGSize{
        let card = self
        let midX = card.midX
        let midY = card.midY
        let diff_w = (totalWidth * 0.5) - midX
        let diff_h = (totalHeight * 0.5) - midY
        let res:CGSize = .init(width: diff_w, height: diff_h)
        return res
    }
    
}



struct FancyScroll: View {
    @Namespace var animation
    @StateObject var scrollStates:FancyScrollStates
    @Binding var selectedArt:ArtData?
    @Binding var showArt:Bool
    @Binding var idx:Int
    var data:[ExploreData]
    let cardSize:CGSize = .init(width: totalHeight * 0.3, height: totalHeight * 0.5)
    
    init(selectedArt: Binding<ArtData?>? = nil,showArt: Binding<Bool>? = nil,data:[ExploreData],idx:Binding<Int>){
        self.data = data
        self._selectedArt = selectedArt ?? .constant(test)
        self._idx = idx
        self._showArt = showArt ?? .constant(false)
        self._scrollStates = StateObject(wrappedValue: .init(size: .init(width: totalHeight * 0.3, height: totalHeight * 0.4)))

    }
    
    var off_size:CGSize{
        return .init(width: self.scrollStates.dynamic_off.width + self.scrollStates.static_off.width, height: self.scrollStates.dynamic_off.height + self.scrollStates.static_off.height)
    }
    
    let col = [GridItem.init(.adaptive(minimum: totalHeight * 0.3,maximum: totalHeight * 0.3), spacing: 0, alignment: .center)]
    
    func showArt(value : Bool){
        if value && self.selectedArt == nil, let data = self.selectedArtData?.data as? CAData{
            self.selectedArt = .init(date: Date(), title:data.title ?? "No Title", introduction: data.wall_description ?? "Description",infoSnippets: self.PaintingInfo, painterName: data.artistName, thumbnail: data.thumbnail,model_img: data.original)
        }else if !value && self.selectedArt != nil{
            self.selectedArt = nil
        }
    }
        
    func grid() -> some View{
        let start = self.idx * 25
        let end = (self.idx + 1) * 25
        print("start : \(start) and end : \(end) and idx : \(self.idx)")
        let data = Array(self.data[start..<end].enumerated())
        
        return GeometryReader{g -> AnyView in
            let global = g.frame(in: .global)
            
            DispatchQueue.main.async {
                if self.scrollStates.dynamic_off == .zero && self.scrollStates.dragging && self.scrollStates.selectedCard == -1{
                    self.scrollStates.centralizeContainer(rect: global)
                    self.scrollStates.dragging = false
                }
            }
            
            
            return AnyView(
                LazyVGrid(columns: self.col, alignment: .center, spacing: 0){
                    ForEach(data,id:\.offset) { _data in
                        let data = _data.element
                        let idx = _data.offset
                        let viewing = self.scrollStates.isViewing == idx && self.scrollStates.selectedCard == -1
                        FancyCardView(data: data, idx: idx)
                            .matchedGeometryEffect(id: idx, in: self.animation,isSource:true)
                            .environmentObject(self.scrollStates)
                            .scaleEffect(viewing ? 1.1 : 0.9)
                    }
                }
                .onChange(of: self.scrollStates.selectedCard, perform: { value in
                    if value == -1{
                        self.scrollStates.centralizeContainer(rect: global)
                    }
                })
                .gesture(DragGesture().onChanged(self.scrollStates.onChanged).onEnded(self.scrollStates.onEnded))
                
            )
            
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalHeight * 1.5,height: totalHeight * 2.5)
        
        .offset(self.off_size)
        .animation(.easeInOut(duration: 1))
        
    }

    
    var body: some View {
        ZStack(alignment: .center) {
            if !self.data.isEmpty{
                self.grid()
                if let sD = self.selectedArtData, self.scrollStates.selectedCard != -1{
                    BlurView(style: .dark)
                    self.selectedArtImage(sD: sD)
                    InfoCard(data:sD,selectedCard: $scrollStates.selectedCard,showArt:self.$showArt)
                }
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onChange(of: self.showArt, perform: self.showArt(value:))

    }
}

extension FancyScroll{
    var PaintingInfo:[String:String]?{
        guard let data = self.selectedArtData?.data as? CAData else {return nil}
        
        var details:[String:String] = [:]
        
        if let department = data.department{
            details["Department"] = department
        }
        
        if let culture = data.culture?.first{
            details["Culture"] = culture
        }
        
        
        if let technique = data.technique{
            details["Technique"] = technique.capitalized
        }
            
        if let dim = data.dimensions{
            if let framed = dim.framed{
                details["Framed"] = "\(framed.height ?? 0)m x \(framed.width ?? 0)m"
            }
        }
        
        return details.keys.count == 0 ? nil : details
}

    
    var selectedArtData : ExploreData?{
        return self.scrollStates.selectedCard != -1 ? self.data[self.scrollStates.selectedCard] : nil
    }
    
    func selectedArtImage(sD:ExploreData) -> AnyView{
        guard let url_str = sD.img,let url = URL(string: url_str), let img = ImageCache.cache[url] else {return AnyView(Color.clear.frame(width: 0, height: 0, alignment: .center))}
        return AnyView(ImageView(img: img, width: cardSize.width, height: cardSize.height, contentMode: .fill, alignment: .topLeading)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .matchedGeometryEffect(id: self.scrollStates.selectedCard, in: self.animation,isSource:false)
            .scaleEffect(1)
            .zIndex(10))
    }
}


//struct FancyScroll_Previews: PreviewProvider {
//    static var previews: some View {
//        FancyScroll(data: [])
//    }
//}

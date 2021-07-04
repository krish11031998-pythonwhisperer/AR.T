//
//  ArtTopFactView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/05/2021.
//

import SwiftUI

struct ArtTopFactView: View {
    var data:ArtData
    
    @State var minY:CGFloat = 0
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    var ver_onChanged:(DragGesture.Value) -> Void
    var ver_onEnded:(DragGesture.Value) -> Void
//    @State var changeFocus:Bool = false
//    let no_cards:Int = 4

    func onChanged(value:DragGesture.Value){
        let width = value.translation.width
        let height = value.translation.height
        
        if abs(width) > abs(height){
            self.offset = width
        }else{
            self.ver_onChanged(value)
        }
        
    }
    
    func onEnded(value:DragGesture.Value){
        
        let width = value.translation.width
        let height = value.translation.height
        
        if abs(width) > abs(height){
            var val:Int = 0
            if abs(width) > 100{
                val = width > 0 ? -1 : 1
                if self.swiped + val <= self.top_Facts.count - 1 && self.swiped + val >= 0{
                    self.swiped += val
//                    print("swiped : \(self.swiped)")
                }
            }
            self.offset = 0
        }else{
            self.ver_onEnded(value)
        }
        
        
    }
    
    var swipedOffset:CGFloat{
        let x_off = -CGFloat(self.swiped) * totalWidth
        return x_off
    }
    
    var top_Facts:[String:String]{
        return self.data.top_facts ?? [:]
    }
    
    func infoOverlay(q:String,ans:String) -> some View{
        return
            GeometryReader{g in
                let w = g.frame(in: .local).width
                let h = g.frame(in: .local).height
                VStack(alignment: .leading, spacing: 10) {
                    Text(q)
                        .font(.system(size: 35, weight: .semibold, design: .serif))
                        .foregroundColor(.white)
                        .frame(width: w, alignment: .leading)
                        .background(Color.clear)
                    Spacer()
                    FactCard(q: "", ans: ans, width: w, height: h * 0.25)
                }.frame(width: w, height: h, alignment: .leading)
            }.padding(.horizontal)
            .padding(.vertical,30)
            .padding(.top,10)
            .frame(width: totalWidth, height: totalHeight, alignment: .center)
            
    }
    
    func infoView(q:String,ans:String) ->  some View{
        return ZStack(alignment: .center) {
            Color.black.opacity(0.3)
            self.infoOverlay(q: q, ans: ans)
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
    
    var mainBody:some View{
        HStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.top_Facts.keys).reversed(),id:\.self) { key in
                let value = self.top_Facts[key] ?? "No Value"
                self.infoView(q: key, ans: value)
                    .tag(key)
                    .gesture(DragGesture()
                                .onChanged(self.onChanged(value:))
                                .onEnded(self.onEnded(value:))
                    )
                    .offset(x: self.offset + swipedOffset)
                    
            }
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .leading)
        .background(ImageView(url: self.data.thumbnail, width: totalWidth, height: totalHeight, contentMode: .fill, alignment: .center)
                        .clipShape(Rectangle()))
    }

    var body: some View {
        self.mainBody
    }
}



//struct ArtTopFactView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtTopFactView(data: test)
//    }
//}

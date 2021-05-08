//
//  HorinzontalCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/19/20.
//

import SwiftUI

struct HorinzontalCarousel: View {
    var data:[Any] = []
    var type:String
    var isIdentifiable:Bool = false
//    var viewFunc:(_ index:Int) -> some View
    @State var swiped:Int = 0
    @State var extraOffset:CGFloat = 0.0
    var IdTypes:[String] = ["attractions"]
    
    init(data:[Any],type:String){
        if IdTypes.contains(type){
            self.isIdentifiable.toggle()
        }
        self.type = type
        self.data = data
        self.convertData()
    }
    
    func convertData(data:[Any]){
        if self.type == "attractions", let safedata = data as! [AMID]{
            self.data = safedata
        }
    }
    
    func onChanged(value:CGFloat){
        if value < 0{
            if self.swiped != self.data.count - 1{
                self.extraOffset = value
            }
        }else if value > 0{
            if self.swiped != 0{
                self.extraOffset = value
            }
        }
    }
    
    func onEnded(value:CGFloat){
        if value < 0{
            if -value > 50 && self.swiped != self.data.count - 1{
                self.swiped += 1
                self.extraOffset = 0
            }else{
                self.extraOffset = 0
            }
        }else{
            if self.swiped > 0{
                if value > 50{
                    self.extraOffset = 0
                    self.swiped -= 1
                }else{
                    self.extraOffset = 0
                }
            }
        }
    }
    
    func getIndex(index:Int) -> CGFloat{
        var diff = index - self.swiped
        var defaultOff = diff < 3 ? CGFloat(diff) * 20.0 : 60.0
        return  defaultOff
    }
    
    var attractionCarousel:some View{
        ZStack{
            ForEach(self.subsetArray.reversed()){d in
                self.attractionCards(d: d.d)
                    .offset(x:self.getIndex(index: d.id))
                    .gesture(DragGesture().onChanged({ (value) in
                        withAnimation(.easeInOut, {
                            self.onChanged(value: value.translation.width)
                        })
                    }).onEnded({ (value) in
                        withAnimation(.easeInOut, {
                            self.onEnded(value: value.translation.width)
                        })
                    }))
                    .offset(x: self.swiped == d.id ? self.extraOffset : 0)
                    
            }
        }
    }
    
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct HorinzontalCarousel_Previews: PreviewProvider {
    static var previews: some View {
        HorinzontalCarousel()
    }
}

//
//  PhotoZoomCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/30/20.
//

import SwiftUI

struct PhotoZoomCarousel: View {
    var incomingData:[AMID]
    @StateObject var SP:swipeParams = .init()

    
    
    var splitData:(left:[AMID],middle:AMID,right:[AMID]){
        get{
//            var data = self.formatData()
            var data = self.incomingData
            var length = data.count-1
            var lowest = self.SP.swiped >= 2 ? self.SP.swiped - 2 : self.SP.swiped == 1 ? self.SP.swiped - 1 : self.SP.swiped
//            var hight = self.SP.swiped + (self.SP.swiped < length - 1 ? )
            var l = Array(data[lowest..<self.SP.swiped])
            var m = data[self.SP.swiped]
            var r = Array(data[Int(self.SP.swiped+1)...])
            return (left:l,middle:m,right:r)
        }
    }
    
    func getOffset(index:Int) -> CGFloat{
        var swiped = self.SP.swiped
        //        var diff = index > swiped ? index - swiped : swiped - index
        var diff = index - swiped
        var factor:CGFloat = 15
        var defaultOff = diff < 3 && diff > -3  ? CGFloat(diff) * factor : 2 * factor
        return defaultOff
    }
    
    func onChanged(value:CGFloat){
        if value < 0{
            if self.SP.swiped != self.incomingData.last!.id{
                self.SP.extraOffset = value
            }
        }else if value > 0{
            if self.SP.swiped != 0{
                self.SP.extraOffset = value
            }
        }
    }
    
    func onEnded(value:CGFloat){
        if value < 0{
            if -value > 20 && self.SP.swiped != self.incomingData.last!.id{
                self.SP.swiped += 1
                self.SP.extraOffset = 0
            }else{
                self.SP.extraOffset = 0
            }
        }else{
            if self.SP.swiped > 0{
                if value > 20{
                    self.SP.extraOffset = 0
                    self.SP.swiped -= 1
                }else{
                    self.SP.extraOffset = 0
                }
            }
        }
    }
    
    func getAR(id:Int) -> CGFloat{
        let swipedID = self.SP.swiped > id ? self.SP.swiped - id : id - self.SP.swiped
        var diff = CGFloat(swipedID) * 0.25
        return swipedID > 2 ? 0.5 : (1.0 - diff)
    }
    
    func isSelected(d:Int) -> Bool{
        return d == self.SP.swiped
    }
    
    var leftCarousel: some View{
        ZStack{
            ForEach(self.splitData.left){d in
                ReviewCard(review: d)
//                d
                    .offset(x: self.getOffset(index: d.id))
                    .scaleEffect(0.95)
            }
        }
    }
    
    var rightCarousel: some View{
//        ,id :\.review.id
        ZStack{
            ForEach(self.splitData.right.reversed()){d in
                ReviewCard(review: d)
                    .offset(x: self.getOffset(index: d.id))
                    .scaleEffect(self.isSelected(d: d.id) ? 1.1 : 0.95)
                    
            }
        }
    }
    
    
    var carouselWidth = totalWidth - 125
    
    var backGroundStack:some View{
        HStack(spacing:0){
            self.leftCarousel.frame(width:carouselWidth/2.5)
            self.rightCarousel.frame(width:carouselWidth/2.5)
        }.animation(.easeInOut).frame(width:carouselWidth).padding()
        
    }
    
    var mainCard:some View{
        ReviewCard(review: self.splitData.middle)
        .gesture(DragGesture()
                        .onChanged({ (value) in
                            withAnimation(.easeInOut, {
                                self.onChanged(value: value.translation.width)
                            })

                        })
                        .onEnded({ (value) in
                            withAnimation (.easeInOut,{
                                self.onEnded(value: value.translation.width)
                            })

                        })
            )
            .offset(x: self.SP.extraOffset)
            .scaleEffect(1.35)

    }
    
    var body: some View {
        ZStack(alignment: .center){
            self.backGroundStack
            self.mainCard.animation(.easeInOut)
        }.frame(width:totalWidth)
    }
}


struct PhotoZoomCarousel_Previews: PreviewProvider {
    static var previews: some View {
        PhotoZoomCarousel(incomingData:reviewData)
    }
}

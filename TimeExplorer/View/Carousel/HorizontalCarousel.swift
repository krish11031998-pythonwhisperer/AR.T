//
//  HorizontalCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 05/01/2021.
//

import SwiftUI

enum ClipperShape{
    case allcorners
    case cutLeft
    case cutRight
}

struct CarouselData{
    var mainTitle:String?
    var mainLocation:String?
    var username:String?
    var userImg:String?
    var mainImage:String?
}

struct HorizontalCarousel: View {
    @State var SP:swipeParams = .init()
    var data:[CarouselData] = []
    @Binding var clickAction:Bool
    var height:CGFloat
    var width:CGFloat
    var numbered:Bool
    
    var countCheck:Bool{
        get{
            return self.SP.swiped < self.data.count - 1 && self.SP.swiped > 0
        }
    }
    
    var upperBound:Bool{
        get{
            return self.SP.swiped < self.data.count - 1
        }
    }
    
    var lowerBound:Bool{
        get{
            return self.SP.swiped > 0
        }
    }
    
    func onChanged(_ value:CGFloat){
        if (value < 0 && self.SP.swiped < self.data.count - 1) || (value > 0 && self.SP.swiped > 0){
            self.SP.extraOffset = value
        }
    }
    
    
    func onEnded(_ value:CGFloat){
        if value < 0{
            if (self.SP.swiped < self.data.count - 1) && abs(value) > 35{
                self.SP.swiped += 1
            }
        }else if value > 0{
            if (self.SP.swiped > 0) && abs(value) > 35{
                self.SP.swiped -= 1
            }
        }
        self.SP.extraOffset = 0
    }
    
    func getOffset(_ idx:Int) -> CGFloat{
        var diff = idx - self.SP.swiped
        return diff < 3 ? CGFloat(diff) * 15 : 30
    }
    
    func getHeight(_ idx:Int) -> CGFloat{
        var diff = idx - self.SP.swiped
        return (1 - (diff < 3 ? CGFloat(diff) * 0.1 : 0.2)) * self.height
    }
    
    func rotationAngleEffect(_ viewing:Bool) -> Angle{
        var factor = self.SP.extraOffset / self.width
        var degrees =  Double(factor * (viewing ? 10 : 0))
        return .init(degrees: degrees)
    }
    
    var body: some View {
        ZStack{
            ForEach(self.data.enumerated().reversed(),id:\.offset){ _data in
                var idx = _data.offset
                var data = _data.element
                var viewing = self.SP.swiped == idx
                if idx >= self.SP.swiped{
                    CarouselSliderCard(idx, data, self.width, self.height, nil, self.clickAction, .cutRight)
                        .offset(x: self.getOffset(idx))
                        .gesture(DragGesture()
                                    .onChanged({ (value) in
                                        withAnimation(.easeInOut) {
                                            self.onChanged(value.translation.width)
                                        }
                                    })
                                    .onEnded({ (value) in
                                        withAnimation(.easeInOut) {
                                            self.onEnded(value.translation.width)
                                        }
                                    })
                        )
                        .offset(x: viewing ? self.SP.extraOffset : 0)
                        .rotationEffect(self.rotationAngleEffect(viewing))
                }
            }
        }
    }
}

struct CarouselSliderCard:View{
    var data:CarouselData = .init()
    var count:Int
    @Binding var clickAction:Bool
//    @StateObject var IMD:ImageDownloader = .init()
    var width:CGFloat
    var height:CGFloat
    var numbered:Bool
    var cShape:ClipperShape
    init(_ count:Int, _ data:CarouselData, _ width:CGFloat = 300, _ height:CGFloat = 300, _ clickAction:Binding<Bool>? = nil ,_ numbered:Bool = false, _ clipper: ClipperShape = .allcorners){
        self.count = count
        self.data = data
        self._clickAction = clickAction != nil ? clickAction! : Binding.constant(false)
        self.numbered = numbered
        self.cShape = clipper
        self.width = width
        self.height = height
    }
    
    
    var overlayView : some View{
        VStack{
            
           
            HStack{
                Spacer()
                if self.numbered{
                    MainText(content: "\(count+1)", fontSize: 10, color: .white)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.black))
                }
            }
            Spacer()
            if self.data.mainLocation != nil{
                MainText(content: self.data.mainLocation!, fontSize: 10, color: .black, fontWeight: .regular, style: .normal)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
            }
            MainText(content: data.mainTitle ?? "", fontSize: 25, color: .white, fontWeight: .semibold, style: .normal)
                .padding()
                .background(BlurView(style: .systemThinMaterialDark).clipShape(RoundedRectangle(cornerRadius: 25 + 1)))
            if self.data.username != nil && self.data.userImg != nil{
                HStack{
                    Image(uiImage: ImageDownloader.shared.image)
                        .resizable()
                        .frame(width: 15, height: 15, alignment: .center)
                        .clipShape(Circle())
                    MainText(content: self.data.username!, fontSize: 15, color: .white, fontWeight: .bold, style: .normal)
                    Spacer()
                }
            }
            Spacer(minLength: 50)
        }.padding(10).frame(width: self.width, height: self.height)
//        .background(bottomShadow.cornerRadius(30))
    }
    
    var body: some View{
        ImageView(url: self.data.mainImage, width: self.width, height: self.height, contentMode: .fill)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .overlay(
                self.overlayView
            )
//            .onAppear {
//                if let url = self.data.mainImage , self.IMD.url != url{
//                    self.IMD.getImage(url: url)
//                }
//            }
            
    }
    
    
    
    
}


//struct HorizontalCarousel_Previews: PreviewProvider {
//    static var previews: some View {
//        HorizontalCarousel()
//    }
//}

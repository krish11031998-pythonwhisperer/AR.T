//
//  AVQuickMenu.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

struct AMID:Identifiable{
    var id:Int
    var attraction:AttractionModel
}

import SwiftUI
import MapKit

enum SliderType{
    case Carousel
    case Stack
}

var previousCoordinate:CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
var Attractions:[AMID] = []

struct AVQuickMenu: View {
    @StateObject var SP:swipeParams
    var attractions:[AMID] = []
    var coordinate:CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
    let cardWidth:CGFloat = AppWidth - 75
    init(coordinates:CLLocationCoordinate2D,attr:[AMID]){
        self.coordinate = coordinates
        self.attractions = attr.count < 10 ? attr : Array(attr[0...10])
        print("attr.count : ",attr.count)
        self._SP = StateObject(wrappedValue: .init(0, attr.count - 1, 50))
    }
    
    func absDiff(x:Float,y:Float) -> Float{
        return x >= y ? x - y : y - x
    }
    
    
    func getIndex(index:Int) -> CGFloat{
        let diff = index - self.SP.swiped
        let factor:CGFloat = 25.0
        let defaultOff = diff < 3 ? CGFloat(diff) * factor : 3 * factor
        return  defaultOff
    }
    
    func getAR(id:Int) -> CGFloat{
        let swipedID = id - self.SP.swiped
        let diff = CGFloat(swipedID) * 0.025
        return swipedID > 2 ? 0.8 : (1.0 - diff)
    }
    
    func getHeight(_ id:Int) -> Double{
        let diff:Double = Double(id - self.SP.swiped)
        let diffHeight = diff < 3 ? diff * 0.1 : 0.2
        return (1 - diffHeight )
    }
    
    func rotatingAngle() -> Angle{
        let rotateFactor = Double(self.SP.extraOffset/self.cardWidth)
        return Angle(degrees: rotateFactor * 10)
    }
    
    var attractionCarousel:some View{
        ZStack{
            ForEach(self.attractions.reversed(),id:\.id){ attraction in
                let x_off = self.getIndex(index: attraction.id)
                let extra_x_off = self.SP.swiped == attraction.id ? self.SP.extraOffset : 0
                let rotation = self.SP.swiped == attraction.id ? self.rotatingAngle() : .init(degrees: 0)
                let current = self.SP.swiped
                if attraction.id >= current && attraction.id <= current + 2{
                    AVQuickCards(attraction.attraction, heightFactor: self.getHeight(attraction.id), width: cardWidth,selected: self.SP.swiped == attraction.id)
                        .gesture(DragGesture().onChanged({ (value) in
                            withAnimation(.easeInOut, {
                                self.SP.onChanged(value: value.translation.width)
                            })
                        }).onEnded({ (value) in
                            withAnimation(.easeInOut, {
                                self.SP.onEnded(value: value.translation.width)
                            })
                        }))
                        .offset(x: x_off + extra_x_off)
                        .rotationEffect(rotation)
                        .scaleEffect(self.getAR(id: attraction.id))
                }
                
                
            }
        }.frame(width:totalWidth)
    }
    
    var body: some View {
        VStack(alignment: .center, spacing: 0){
            self.attractionCarousel
        }.padding(.bottom)
        .onChange(of: self.attractions.count, perform: { count in
            if count > 0{
                self.SP.end = count - 1
            }
        })
    }
}

struct AVQuickCards: View{
    var aspectRatio:CGFloat = 1.0
    var url:String = ""
    var attraction:AttractionModel
    var selected:Bool
    var heightFactor:Double
    var width:CGFloat?
    @StateObject var IMGD:ImageDownloader = .init()

    init(_ attr:AttractionModel,heightFactor:Double, width:CGFloat,selected:Bool = false){
        if let image  = attr.photo?.images?.original,let width = image.width,let height = image.height,let urlString = image.url{
            self.aspectRatio = CGFloat(Float(width) ?? 1.0)/CGFloat(Float(height) ?? 1.0)
            self.url = urlString
        }
        self.attraction = attr
        self.heightFactor = heightFactor
        self.selected = selected
        self.width = width
    }
    
    var v4: some View{
        let width:CGFloat = self.width ?? AppWidth - 75
        let height:CGFloat = 400 * CGFloat(heightFactor)
        return GeometryReader{g in
            let w = g.frame(in:.local).width
            let h = g.frame(in: .local).height
            
            
            VStack(alignment: .leading, spacing: 0) {
                ImageView(url:self.url,width: w,height: h*0.7,contentMode:.fill)
                VStack(alignment: .leading, spacing: 10) {
                    HStack{
                        Spacer()
                    }
                    MainText(content: self.attraction.name ?? "No Location", fontSize: 17.5, color: .black, fontWeight: .semibold).frame(alignment:.leading)
                    MainText(content: self.attraction.location_string ?? "No location", fontSize: 15, color: .gray, fontWeight: .medium, style: .normal).frame(alignment:.leading)
                }.padding(.vertical,10)
                .padding(.horizontal,5)
                .frame(width: w, height: h*0.3, alignment: .center)
                .background(BlurView(style: .regular))
                .fixedSize(horizontal: true, vertical: true)
            }.overlay(
                AnyView(
                    BlurView(style: .regular)
                        .frame(width: w, height: h, alignment: .center)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .opacity(self.selected ? 0 : 1)
                )
            )
        }.frame(width: width, height: height, alignment: .center).clipShape(RoundedRectangle(cornerRadius: 30))
    }
    
    var body: some View{
        self.v4
    }
}

struct AVQuickMenu_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            AVQuickMenu(coordinates: .init(latitude: 0, longitude: 0), attr: attractionExampleTwo)
        }
    }
}

//struct AVQuickCards_Previews: PreviewProvider {
//    static var previews: some View {
//        ZStack{
//            Color.black
//            AVQuickCards(attractionExample.first!)
//        }
//
//    }
//}

//
//  AVCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 15/02/2021.
//

import SwiftUI

struct AVCarousel: View {
    var attractions:[AMID] = []
    @Binding var swiped:Int
    let thresWidth:CGFloat = totalWidth * 0.3;
    let targetWidth:CGFloat = totalWidth * 0.1
    let cardWidth:CGFloat = totalWidth * 0.4;
    let cardHeight:CGFloat = totalHeight * 0.3;
    @StateObject var SP:swipeParams
    @State var selctedAttraction:AttractionModel = .init()
    @State var showAttraction:Bool = false
    
    init(attractions:[AMID],swiped:Binding<Int>){
        self.attractions = attractions
        self._swiped  = swiped
        self._SP = StateObject(wrappedValue: swipeParams(0, attractions.count - 1, 50))
    }
    
    func inScopeView(minX:CGFloat) -> Bool {
        return (self.targetWidth >= minX && minX < self.thresWidth)
    }

    func chosenAttractionDetails() -> some View{
        func content(name:String,icon:String,value:String,color:Color) -> some View{
            return HStack(spacing:5){
                Image(systemName: icon)
                    .resizable()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.white)
                MainText(content: name, fontSize: 10,color: .white)
                MainText(content: value, fontSize: 10,color: .white)
            }.aspectRatio(contentMode: .fit)
            .padding()
            .background(BlurView(style: .regular).background(color))
            .cornerRadius(25)
        }
        let choosenAttraction = self.attractions[self.SP.swiped].attraction
        let view = VStack(alignment:.leading){
            MainText(content: choosenAttraction.name ?? "", fontSize: 25, color: .black, fontWeight: .bold, style: .normal)
            MainText(content: choosenAttraction.location_string ?? "", fontSize: 15, color: .black, fontWeight: .regular, style: .normal)
            content(name: "Distance", icon: "location.fill", value: String(format:"%.2f",  choosenAttraction.distance ?? "0km"),color: .green)
            content(name: "Rating", icon: "star.fill", value: choosenAttraction.rating ?? "0",color: .blue)
            content(name: "Cost", icon: "dollarsign.circle.fill", value: choosenAttraction.offer_group?.lowest_price ?? "0",color: .red)
        }.padding().frame(width: AppWidth, alignment: .leading).background(BlurView(style: .regular)).clipShape(RoundedRectangle(cornerRadius: 30))
        
        return view
    }
    
    var navigationToDetailView:some View{
        return NavigationLink(destination: AVDetail(attraction: self.selctedAttraction, showAttraction: self.$showAttraction), isActive: self.$showAttraction) {
            Text("")
        }.hidden()
    }
    
    var HCarousel:some View{
        HStack{
            ForEach(self.attractions){_attr in
                let attraction = _attr.attraction
                let idx = _attr.id
                let cardOffset = 20 * CGFloat(idx - self.SP.swiped)
                if idx >= self.SP.swiped && idx <= self.SP.swiped + 2{
                    Button {
                        self.showAttraction = true
                        self.selctedAttraction = attraction
                    } label: {
                        AVCard(attraction: attraction, width: self.cardWidth, height: self.cardHeight, blur: self.SP.swiped != _attr.id)
                            .gesture(
                                DragGesture()
                                    .onChanged({ (value) in
                                        self.SP.onChanged(value: value.translation.width)
                                    })
                                    .onEnded({ (value) in
                                        self.SP.onEnded(value: value.translation.width)
                                    })
                            )
                            .offset(x: self.SP.extraOffset + cardOffset)
                            .padding(.leading, self.SP.swiped == idx ? 20 : 0)
                    }.buttonStyle(PlainButtonStyle())
                }
                
            }
        }.frame(width: totalWidth,alignment:.leading)
        .onChange(of: self.SP.swiped) { (idx) in
            self.swiped = idx
        }
    }

    var body: some View {
        VStack{
            self.HCarousel
            Spacer()
            HStack{
                Spacer()
                self.chosenAttractionDetails()
                Spacer()
            }.padding(.horizontal,10)
            self.navigationToDetailView
        }.padding(.vertical,50).padding(.bottom,100).frame(width: totalWidth, height: totalHeight, alignment: .center)
        
    }
}

struct AVCard:View{
    var attraction:AttractionModel
    var width:CGFloat
    var height:CGFloat
    @StateObject var IMD:ImageDownloader = .init()
    var blur:Bool
    
    
    let thresWidth = totalWidth * 0.4
    let targetWidth = totalWidth * 0.3
    init(attraction:AttractionModel, width w:CGFloat,height h:CGFloat,blur:Bool){
        self.attraction = attraction;
        self.width = w;
        self.height = h;
        self.blur = blur
    }
    
    func scale(minX:CGFloat) -> CGFloat{
        var percent = (minX - targetWidth)/(thresWidth - targetWidth)
        percent = percent < 0 ? 0 : percent > 1 ? 1 : percent
        let scale = 0.8 + 0.2 * (1 - percent)
        return scale
    }
    
    
    var body:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            let minX = g.frame(in:.global).minX
            let img_url = self.attraction.photo?.images?.medium?.url
            let scale = self.scale(minX: minX)
            ZStack{
                if blur{
                    BlurView(style: .regular)
                        .aspectRatio(contentMode: .fill)
                }
                ImageView(url: img_url, width: self.width, height: self.height, contentMode: .fill)
            }.frame(width: w, height: h, alignment: .center)
            .clipShape(RoundedRectangle(cornerRadius: 30))
            .scaleEffect(scale)
        }
        .frame(width: self.width, height: self.height, alignment: .center)
        
        .onAppear {
                if let img_url = self.attraction.photo?.images?.medium?.url, self.IMD.url != img_url{
                    self.IMD.getImage(url: img_url)
                }
            }
    }
}


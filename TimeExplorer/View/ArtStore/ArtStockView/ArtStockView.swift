//
//  ArtStockView.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 22/06/2021.
//

import SwiftUI

struct ArtStockView: View {
    var data:AVSData
    @Binding var close:Bool
    var closeFn: (() -> Void)? = nil
    init(data:AVSData,close:Binding<Bool>,closeFn: @escaping () -> Void){
        self.data = data
        self._close = close
        self.closeFn = closeFn
    }
    
    var body: some View {
//        VStack(alignment: .leading, spacing: 10){
        ScrollView(.vertical, showsIndicators: false){
            self.mainImage
            self.IntroSection
            ChartMainView()
            self.PurchaseView
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .background(Color.black)
    }
}


extension ArtStockView{
    
    func backButton(){
        print("Back button pressed")
        if let fn = self.closeFn{
            fn()
        }else{
            self.close.toggle()
        }
    }
    
    func optionButton(){
        print("Options button pressed")
    }
    
// MARK:- Main Image View
    var mainImage:some View{
        GeometryReader {g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            ZStack(alignment: .top){
                ImageView(url: self.data.img, width: w, height: h, contentMode: .fill, alignment: .top)
                    .clipped()
                HStack(alignment: .center, spacing: 10){
                    SystemButton(b_name: "arrow.left", b_content: "", action: self.backButton)
                    Spacer()
                    SystemButton(b_name: "circle.grid.cross", b_content: "", action: self.optionButton)
                }.padding()
                .padding(.top)
                .frame(width: w, alignment: .center)
            }.frame(width: w, height: h, alignment: .center)
        }.frame(width: totalWidth, height: totalHeight * 0.45, alignment: .center)
    }

// MARK:- IntroSection View
    
    var IntroSection:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "Top Bids", fontSize: 25, color: .white, fontWeight: .regular)
                .padding(10)
            self.Bidders
        }.aspectRatio(contentMode: .fill)
        .padding(.vertical)
        .frame(width: totalWidth, alignment: .center)
//        .background(Color.black)
    }
    
// MARK:- Bidder View
    
    func bidderInfo(name:String,value:Float,idx:Int) -> AnyView{
        let scale:CGFloat = 1.0 - 0.0125 * CGFloat(idx)
        let view = HStack(alignment: .center, spacing: 10){
            MainText(content: "\(name.first ?? "U")", fontSize: 10,color: .black)
                .frame(width: 15, height: 15, alignment: .center)
                .padding(5)
                .background(Color.white)
                .clipShape(Circle())
            MainText(content: name, fontSize: 15, color: .white, fontWeight: .regular)
            Spacer()
            MainText(content: "\(String(format: "%.1f", value)) btc", fontSize: 17.5, color: .white, fontWeight: .regular)
        }.padding()
        .background(BlurView(style: .systemThickMaterialDark))
        .clipShape(Capsule())
        .scaleEffect(scale)
        return AnyView(view)
    }
    
    var Bidders:some View{
        let bidders:[(String,Float)] = [("John",120),("Sarah",160),("Frank",220),("Mason",420),("Emily",20)].sorted { a, b in
            return a.1 > b.1
        }
        return VStack(alignment: .leading, spacing: 10){
            ForEach(Array(bidders.enumerated()), id: \.offset) { _bidder in
                let bidder = _bidder.element
                let idx = _bidder.offset
                let (name,value) = bidder
                self.bidderInfo(name: name, value: value,idx:idx)
                    
            }
        }.padding()
    }
    
// MARK: - Purchase View
    
    var PurchaseView: some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            VStack(alignment: .leading, spacing: 10) {
                    MainText(content: "Buy", fontSize: 25, color: .white, fontWeight: .semibold)
                    MainText(content: "\(4500) BTC", fontSize: 35, color: .white, fontWeight: .semibold)
                Spacer()
                HStack(alignment: .center, spacing: 0){
                    self.PurchaseInfoView(size: .init(width: w * 0.65, height: h * 0.65))
                    Spacer()
                    SystemButton(b_name: "arrow.right", b_content: "Buy", color: .black, haveBG: true, size: .init(width: 25, height: 25),bgcolor: .white, alignment: .vertical) {
                        print("Buyu was clicked!")
                    }
                }
                
            }.frame(width: w, height: h, alignment: .leading)
        }.padding()
        .frame(width: totalWidth, height: totalHeight * 0.5, alignment: .center)
    }
    
    
    
    func PurchaseInfoView(size:CGSize) -> some View{
        let items:[String] = ["3D Art","NFT Signature","MR Experience","10 Day LocAd"]
        return VStack(alignment: .leading, spacing: 10){
            MainText(content: "You'll be getting", fontSize: 15, color: .black, fontWeight: .semibold)
                .padding(.bottom)
            ForEach(items,id: \.self){ item in
                MainText(content: item, fontSize: 15, color: .black, fontWeight: .regular)
                Divider()
            }
            Spacer()
        }
        .padding()
        .frame(width: size.width, height: size.height, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
// MARK:- Chart View
    
    var ChartView: some View{
        return ChartMainView()
    }
}

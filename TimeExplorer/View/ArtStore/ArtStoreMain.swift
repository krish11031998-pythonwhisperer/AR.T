//
//  ArtStoreMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 26/05/2021.
//

import SwiftUI
import SwiftUICharts

let asm = AVSData(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test as Any)

enum BlobIcons:String{
    case btc = "btc_icon"
    case likes = "like_icon"
    case view = "view_icon"
}


struct ArtStoreMain: View {
    var data:[AVSData]
    @EnvironmentObject var mainStates:AppStates
    init(data:[AVSData] = Array.init(repeating: asm, count: 10)){
        self.data = data
    }
    
    var auctionBuyView:some View{
        VStack(alignment: .leading, spacing: 15){
            MainText(content: "Auction", fontSize: 35, color: .black, fontWeight: .bold, style: .heading, addBG: false)
            TopArtScroll(data: self.data)
                .padding(.top,30)
            self.infoView
            Spacer()
        }
        .padding()
        .padding(.top,50)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
//    func ValueBlob(heading:String,value:String,color:Color,width w:CGFloat, height h:CGFloat,s1:CGFloat = 14,s2:CGFloat = 25,img_name:BlobIcons = .btc) -> some View{
    func ValueBlob(info:(String,String),color:Color,size:CGSize,font_size:(CGFloat,CGFloat) = (18,28),percent:(Int,Int)? = nil,img_name:BlobIcons = .btc) -> some View{
        let (heading,value) = info
        let w = size.width
        let h = size.height
        
        let (s1,s2) = font_size
        
        let view = ZStack(alignment: .leading) {
            VStack(alignment: .leading) {
                BasicText(content: heading, fontDesign: .serif, size: s1, weight: .semibold)
                    .foregroundColor(.black)
                Spacer()
                if percent != nil{
                    HStack(alignment: .center, spacing: 10) {
                        Image(systemName: percent!.1 < 0 ? "arrow.down" : "arrow.up")
                            .frame(width: 20, height: 20, alignment: .center)
                        BasicText(content: "\(percent!.0)%", fontDesign: .serif, size: 20, weight: .semibold)
                            .foregroundColor(percent!.1 < 0 ? .red : percent!.1 == 0 ? .gray : .green)
                    }
                    Spacer()
                }
                
                BasicText(content: value, fontDesign: .serif, size: s2, weight: .semibold)
                    .foregroundColor(.black)
            }
            ImageView(img: .init(named: img_name.rawValue), width: w * 0.3,height: h * 0.3, contentMode: .fill, alignment: .center)
                .offset(x: w * 0.7)
                .opacity(0.3)
            
        }
        .padding()
        .frame(width: w, height: h, alignment: .leading)
        .background(color.overlay(BlurView(style: .regular)))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(radius: 1.5)
        
        return view
    }
    
    var infoView:some View{
        let w = totalWidth - 20
        let h = totalHeight - 20
        
        let cols = [GridItem(.flexible(minimum: w * 0.5), spacing: 10, alignment: .center),GridItem(.flexible(minimum: w * 0.5), spacing: 10, alignment: .center)]
        
        var view =
            VStack(alignment: .leading, spacing: 10) {
                BasicText(content: "Mona Lisa", fontDesign: .serif, size: 25, weight: .semibold)
                    .foregroundColor(.black)
                    .padding()
                    .frame(width: w, alignment: .leading)
                LazyVGrid(columns: cols, alignment: .center, spacing: 15) {
                    self.ValueBlob(info: ("Current","\(25.0)"), color: .white,size: .init(width: w * 0.5, height: h * 0.125))
                    self.ValueBlob(info: ("Difference","-\(0.025)"), color: .white,size: .init(width: w * 0.5, height: h * 0.125))
                    self.ValueBlob(info: ("Views","\(25000)"), color: .white,size: .init(width: w * 0.5, height: h * 0.2),font_size: (18,28),percent: (2,-1),img_name: .view)
                    self.ValueBlob(info: ("Likes","\(20000)"), color: .white,size: .init(width: w * 0.5, height: h * 0.2),font_size: (18,28),percent: (1,1),img_name: .likes)
                }
            }.padding()
            .frame(width: totalWidth)
        return view
    }
    
    
    
    
    var body: some View {
        ZStack(alignment: .center) {
            ScrollView(.vertical, showsIndicators: false) {
                Spacer().frame(height: 75)
                self.auctionBuyView
                Spacer().frame(height: totalHeight * 0.3)
            }
        }
        .frame(width: totalWidth,height: totalHeight, alignment: .center)
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            self.mainStates.loading = false
        })
    }
}



struct ArtStoreMain_Previews: PreviewProvider {
    static var previews: some View {
        ArtStoreMain()
    }
}

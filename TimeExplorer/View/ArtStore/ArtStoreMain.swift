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
    @EnvironmentObject var mainStates:AppStates
    @StateObject var ArtAPI:CAAPI = .init()
    @State var posts:[AVSData] = []
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
    
    
    func onAppear(){
        self.mainStates.loading = true
//        self.ArtAPI.getBatchArt(limit: 50, skip: 100)
        if let data = self.mainStates.getArt(limit: 100,skip: 200){
            self.parseData(data)
        }
    }
    
    func parseData(_ data:[CAData]){
        if !data.isEmpty{
            let _data = data.compactMap({ $0.thumbnail != "" ? AVSData(img: $0.thumbnail, title: $0.title, subtitle: $0.artistName, data: $0) : nil})
            DispatchQueue.main.async {
                self.posts = _data
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    
    func onReceive(output: [CAData]){
        if !output.isEmpty{
            self.mainStates.loading = false
        }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
//            Color.black
            if !self.posts.isEmpty && !self.mainStates.loading{
                AuctionArtView(data: self.posts)
            }
        }.onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
        
    }
}



struct ArtStoreMain_Previews: PreviewProvider {
    static var previews: some View {
        ArtStoreMain()
    }
}

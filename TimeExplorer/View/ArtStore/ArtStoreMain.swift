//
//  ArtStoreMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 26/05/2021.
//

import SwiftUI

let asm = AVSData(img: test.thumbnail, title: test.title, subtitle: test.painterName, data: test as Any)

struct ArtStoreMain: View {
    var data:[AVSData]
    @EnvironmentObject var mainStates:AppStates
    init(data:[AVSData] = Array.init(repeating: asm, count: 10)){
        self.data = data
    }
    
    var auctionBuyView:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "Auction", fontSize: 15, color: .black, fontWeight: .bold, style: .heading, addBG: false)
            AVScrollView(attractions: self.data, cardView: nil)
            Spacer()
        }.padding()
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
    var infoView:some View{
        VStack(alignment: .leading, spacing: 10){
            BasicText(content: asm.title ?? "heading", fontDesign: .serif, size: 20, weight: .semibold)
                .foregroundColor(.white)
            
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .center) {
            self.auctionBuyView
            
            
            
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
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

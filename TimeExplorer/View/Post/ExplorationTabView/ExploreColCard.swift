//
//  ExploreColCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 01/04/2021.
//

import SwiftUI

struct ExploreColCard:View{
    var data:ExploreData
    var width:CGFloat = 0
    var height:CGFloat = 0
    @Binding var selectedCard:ExploreData
    @Binding var showSelectedCard:Bool
    @StateObject var IMD:ImageDownloader = .init()
    
    init(data:ExploreData,selectedCard:Binding<ExploreData>,showSelectedCard:Binding<Bool>,w: CGFloat, h: CGFloat){
        self.data = data
        self._selectedCard = selectedCard
        self._showSelectedCard = showSelectedCard
        self.width = w
        self.height = h
    }
    
    var heading:String{
        guard let data = self.data.data else {return "PlaceHolder"}
        if let safeData = data as? PostData{
            return safeData.caption
        }else if let safeData = data as? BlogData{
            return safeData.headline ?? "Headline"
        }
        
        return "PlaceHolder"
    }
    
    
    var v2:some View{
        LazyVStack(alignment: .leading, spacing: 5) {
            ImageView(url: self.data.img, width: width, height: (height * 0.75) - 5, contentMode: .fill, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 20))
            VStack(alignment: .leading, spacing: 2.5){
                Text("heading")
                    .font(.system(size: 12, weight: .regular, design: .serif))
                Text("subheading")
                    .font(.system(size: 10, weight: .regular, design: .monospaced))
            }.padding()
            .frame(width: width,height: height * 0.25,alignment: .leading)
        }
        .frame(width: width, height: height, alignment: .center)
        .onAppear {
            if let url = self.data.img{
                self.IMD.getImage(url: url)
            }
        }
        
    }
    
    var body:some View{
        self.v2
    }
    
    
}

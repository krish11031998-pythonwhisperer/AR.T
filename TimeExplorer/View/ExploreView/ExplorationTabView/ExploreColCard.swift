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
        LazyVStack(alignment: .leading, spacing: 10) {
            MainText(content: "heading" , fontSize: 12, color: .black, fontWeight: .regular)
                .padding()
                .padding(.top)
                .frame(width: width,height: height * 0.15,alignment: .leading)
            Image(uiImage: self.IMD.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: width, height: height * 0.85, alignment: .center)
                .clipShape(Corners(rect: .topRight, size: .init(width: 20, height: 20)))
                .overlay(ZStack{
                    Color.clear
                    if self.IMD.loading{
                        BlurView(style: .dark)
                    }
                })
        }
        .frame(width: width, height: height, alignment: .center)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(radius: 5)
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

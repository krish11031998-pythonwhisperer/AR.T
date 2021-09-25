//
//  Constants.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI

var totalWidth = UIScreen.main.bounds.width
var AppWidth = totalWidth * 0.9
var totalHeight = UIScreen.main.bounds.height
extension Color{
    static var gold = Color(UIColor(hex: "#FFD700") ?? .blue)
    static var mainBGColor = LinearGradient(gradient: .init(colors: [.black,Color.gold]), startPoint: .topTrailing, endPoint: .bottomLeading)
//    static var mainBGColor:Color = .init(red: 255, green: 255, blue: 255)
    static var primaryColor:Color = .init(UIColor(hex: "#191A1DFF") ?? .white)
}
var baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
var bottomShadow = LinearGradient(gradient: .init(colors: [.clear,.black]), startPoint: .top, endPoint: .bottom)
var lightbottomShadow = LinearGradient(gradient: .init(colors: [.clear,Color.black.opacity(0.5)]), startPoint: .top, endPoint: .bottom)

var mainBGView: some View {
    ZStack(alignment: .top){
        Color.black
        Color.mainBGColor.frame(width: totalWidth, height: totalHeight * 0.25)
        BlurView(style: .dark)
        
    }
}

func overlayShadows(width w:CGFloat,height h:CGFloat) -> some View{
    return VStack{
        Image.topShadow
            .resizable()
            .frame(width: w)
            .aspectRatio(contentMode: .fit)
            .frame(minHeight:h*0.25)
        Spacer(minLength: h * 0.5)
        Image.bottomShadow
            .resizable()
            .frame(width: w)
            .aspectRatio(contentMode: .fit)
            .frame(minHeight:h*0.25)
    }.edgesIgnoringSafeArea(.all).frame(height:h)
}

func wideText(width w: CGFloat,text: String, fontSize: CGFloat, color: Color = .black, fontWeight: Font.Weight = .regular, style:TextStyle = .normal) -> some View{
    return HStack{
        MainText(content: text, fontSize: fontSize, color: color, fontWeight: fontWeight, style: style)
            .fixedSize(horizontal: false, vertical: true)
            .lineLimit(2)
            .padding()
            .multilineTextAlignment(.leading)
            
        Spacer()
    }.padding(10).frame(width: w)
}

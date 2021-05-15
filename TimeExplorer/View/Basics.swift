//
//  Basics.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI

enum TextStyle:String{
//    case main = "Avenir Next Medium"
    case main = "NeueMachina-Regular"
    case heading = "BungeeShade-Regular"
    case title = "SortsMillGoudy-Regular"
//    case normal = "NeueMachina-Regular"
    case normal = "Avenir Next Medium"
//    case normal = "SF Pro"
//    case normal = "Raleway-VariableFont_wght"
}
struct BasicText: View {
    
    var content:String
    var fontDesign:Font.Design
    var size:CGFloat
    var weight:Font.Weight
    
    
    init(content:String,fontDesign:Font.Design = .default,size:CGFloat = 15, weight:Font.Weight = .regular){
        self.content = content
        self.fontDesign = fontDesign
        self.size = size
        self.weight = weight
        
    }
    
    var body:some View{
        Text(self.content)
            .font(.system(size: self.size, weight: self.weight, design: self.fontDesign))
//            .foregroundColor(.black)
    }

}

struct MainText: View {
    var content:String
    var fontSize:CGFloat
    var color:Color
    var font:Font
    var fontWeight:Font.Weight
    var style:TextStyle
    var addBG:Bool
    init(content:String,fontSize:CGFloat,color:Color = .white, fontWeight:Font.Weight = .medium,style:TextStyle = .normal,addBG:Bool = false){
        self.content = content
        self.fontSize = fontSize
        self.color = color
        self.style = style
        self.font = .custom(self.style.rawValue, size: self.fontSize)
        self.fontWeight = fontWeight
        self.addBG = addBG
        
    }
    
    var oppColor:Color{
        return self.color == .black ? .white : .black
    }
     
    var body: some View {
        Text(self.content.stripSpaces().removeEndLine())
            .font(self.font)
            .fontWeight(self.fontWeight)
            .foregroundColor(self.color)
            .frame(alignment:.topLeading)
            .padding(.horizontal,addBG ? 15 : 0)
            .padding(.vertical,addBG ? 7.5 : 0)
            .background(addBG ? self.oppColor : .clear)
            .clipShape(RoundedRectangle(cornerRadius: addBG ? 20 : 0))
//            .multilineTextAlignment(.leading)
            
    }
}


struct HeadingInfoText:View{
    var heading:String
    var headingSize:CGFloat
    var headingColor:Color
    var subhead:String
    var subheadSize:CGFloat
    var subheadColor:Color
    var headingDesign:Font.Design
    var subheadDesign:Font.Design
    var haveBG:Bool = false
    
    init(heading:String,subhead:String, headingSize:CGFloat = 15,headingColor:Color = .white, headingDesign:Font.Design = .serif, subheadSize:CGFloat = 18,subheadColor:Color = .white,subheadDesign:Font.Design = .default,haveBG:Bool = false){
        self.heading = heading
        self.subhead = subhead
        self.headingSize = headingSize
        self.headingColor = headingColor
        self.subheadSize = subheadSize
        self.subheadColor = subheadColor
        self.headingDesign = headingDesign
        self.subheadDesign = subheadDesign
        self.haveBG = haveBG
    }
    
    func oppColor(color:Color) -> Color{
        return color == .black ? .white : .black
    }
    
    func infoText() -> some View{
        return VStack(alignment: .leading, spacing:0){
            Text(self.heading)
//                .font(.headline)
                .font(.system(size: self.headingSize, weight: .bold, design: self.headingDesign))
                .foregroundColor(self.headingColor)
                .fontWeight(.bold)
                .aspectRatio(contentMode: .fill)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.headingColor) : .clear)
            Text(self.subhead)
                .font(.system(size: self.subheadSize, weight: .semibold, design: self.subheadDesign))
                .foregroundColor(self.subheadColor)
                .fontWeight(.bold)
                .aspectRatio(contentMode: .fill)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.subheadColor) : .clear)
        }
    }

    var body: some View{
        self.infoText()
    }
    
}

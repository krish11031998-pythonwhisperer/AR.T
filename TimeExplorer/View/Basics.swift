//
//  Basics.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI
import SUI

enum TextStyle: String {
    case main = "NeueMachina-Regular"
    case heading = "BungeeShade-Regular"
    case normal = "Satoshi-Regular"
    case black = "Satoshi-Black"
    case blackItalic = "Satoshi-BlackItalic"
    case medium = "Satoshi-Medium"
    case mediumItalic = "Satoshi-MediumItalic"
    case light = "Satoshi-Light"
    case lightItalic = "Satoshi-LightItalic"
    case bold = "Satoshi-Bold"
    case boldItalic = "Satoshi-BoldItalic"
    //case regular = "Satoshi-Regular.otf"
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

extension String {
	
	func normal(size: CGFloat, color: Color = .white) -> RenderableText {
		styled(font: .init(name: TextStyle.normal.rawValue, size: size) ?? .systemFont(ofSize: size, weight: .regular), color: color)
	}
	
	func main(size: CGFloat, color: Color = .white) -> RenderableText {
		styled(font: .init(name: TextStyle.main.rawValue, size: size) ?? .systemFont(ofSize: size, weight: .regular), color: color)
	}
	
	func heading(size: CGFloat, color: Color = .white) -> RenderableText {
		styled(font: .init(name: TextStyle.heading.rawValue, size: size) ?? .systemFont(ofSize: size, weight: .regular), color: color)
	}
	
    
    func styled(font: TextStyle, color: Color, size: CGFloat) -> RenderableText {
        guard let customFont = UIFont(name: font.rawValue, size: size) else {
            return styled(font: .systemFont(ofSize: size, weight: .regular), color: color)
        }
        return styled(font: customFont, color: color)
    }
}

extension Color {
    static let textColor: Self = .white
}

extension String {
    
    func heading1(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 32) }
    func heading2(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 24) }
    func heading3(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 22) }
    func heading4(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 18) }
    func heading5(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 16) }
    func heading6(color: Color = .textColor) -> RenderableText { styled(font: .black, color: color, size: 14) }
    func body1Bold(color: Color = .textColor) -> RenderableText { styled(font: .bold, color: color, size: 16) }
    func body1Medium(color: Color = .textColor) -> RenderableText { styled(font: .medium, color: color, size: 16) }
    func body1Regular(color: Color = .textColor) -> RenderableText { styled(font: .normal, color: color, size: 16) }
    func body2Bold(color: Color = .textColor) -> RenderableText { styled(font: .bold, color: color, size: 14) }
    func body2Medium(color: Color = .textColor) -> RenderableText { styled(font: .medium, color: color, size: 14) }
    func body2Regular(color: Color = .textColor) -> RenderableText { styled(font: .normal, color: color, size: 14) }
    func body3Medium(color: Color = .textColor) -> RenderableText { styled(font: .medium, color: color, size: 12) }
    func body3Regular(color: Color = .textColor) -> RenderableText { styled(font: .normal, color: color, size: 12) }
    func bodySmallRegular(color: Color = .textColor) -> RenderableText { styled(font: .normal, color: color, size: 11) }
    func largeBodyRegular(color: Color = .textColor) -> RenderableText { styled(font: .normal, color: color, size: 16) }
    func buttonBold(color: Color = .textColor) -> RenderableText { styled(font: .bold, color: color, size: 13) }
}

struct MainText: View {
    var content:String
    var fontSize:CGFloat
    var color:Color
    var font:Font
    var fontWeight:Font.Weight
    var style:TextStyle
    var addBG:Bool
    init(content:String,fontSize:CGFloat,color:Color = .white, fontWeight:Font.Weight = .thin,style:TextStyle = .normal,addBG:Bool = false){
        self.content = content.stripSpaces().removeEndLine()
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
        Text(self.content)
            .font(self.style == .normal ? self.font : Font.system(.body, design: .serif))
            .fontWeight(self.fontWeight)
            .foregroundColor(self.color)
            .padding(.all,addBG ? 10 : 0)
            .background(addBG ? self.oppColor : .clear)
            .clipShape(RoundedRectangle(cornerRadius: addBG ? 20 : 0))
            
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
//                .aspectRatio(contentMode: .fill)
                .fixedSize(horizontal: false, vertical: true)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.headingColor) : .clear)
            Text(self.subhead)
                .font(.system(size: self.subheadSize, weight: .semibold, design: self.subheadDesign))
                .foregroundColor(self.subheadColor)
                .fontWeight(.bold)
//                .aspectRatio(contentMode: .fill)
                .padding(self.haveBG ? 10 : 2.5)
                .background(self.haveBG ? self.oppColor(color: self.subheadColor) : .clear)
        }
    }

    var body: some View{
        self.infoText()
    }
    
}

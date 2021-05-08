//
//  Color.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/12/20.
//

import SwiftUI
extension Color{
    static func colorConvert(red:Double,green:Double,blue:Double) -> Color{
        var r:Double = red/255.0
        var g:Double = green/255.0
        var b:Double = blue/255.0
        return .init(red: r, green: g, blue: b)
    }
    static var mainBG:Color = Color.colorConvert(red: 250, green: 251, blue: 245)

    static func linearGradient(colorOne:UIColor,colorTwo:UIColor) -> LinearGradient{
        return LinearGradient(gradient: .init(colors: [Color(colorOne),Color(colorTwo)]), startPoint: .top, endPoint: .bottom)
    }
//    static var fourthColor:Color = Color.colorConvert(red: 237, green: 242, blue: 243)
}


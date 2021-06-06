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


extension UIColor{
    public convenience init?(hex: String) {
        let r, g, b, a: CGFloat
        
        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])
            
            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0
                
                if scanner.scanHexInt64(&hexNumber) {
                    r = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    g = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    b = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    a = CGFloat(hexNumber & 0x000000ff) / 255
                    
                    self.init(red: r, green: g, blue: b, alpha: a)
                    return
                }
            }
        }
        
        return nil
    }

}

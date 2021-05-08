//
//  SystemButton.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 07/04/2021.
//

import SwiftUI

struct SystemButton: View {
    var buttonName:String
    var buttonContent:String
    var actionHandler: () -> Void
    var color:Color
    var haveBG:Bool
    fileprivate var bgcolor:Color? = nil
    init(b_name:String,b_content:String,color:Color = .white,haveBG:Bool = true,action:@escaping () -> Void){
        self.buttonName = b_name
        self.buttonContent = b_content
        self.actionHandler = action
        self.color = color
        self.haveBG = haveBG
    }
    init(b_name:String,b_content:String,color:Color = .white,haveBG:Bool = true,bgcolor:Color? = nil,action:@escaping () -> Void){
        self.buttonName = b_name
        self.buttonContent = b_content
        self.actionHandler = action
        self.color = color
        self.haveBG = haveBG
        self.bgcolor = bgcolor
    }
    
    var bgColor:Color{
        get{
            return self.bgcolor != nil ? self.bgcolor! : self.color == .white ? .black : .white
        }
    }
    
    var body: some View {
        Button(action: {
            self.actionHandler()
        }, label: {
            VStack(alignment:.center){
                Image(systemName: self.buttonName)
                    .frame(width: 10, height: 10, alignment: .center)
                    .foregroundColor(color)
                    .padding()
                    .background(haveBG ? bgColor : Color.clear)
                    .clipShape(Circle())
                if self.buttonContent != ""{
                    MainText(content: self.buttonContent, fontSize: 14,color: bgColor)
                }
                
            }
            
        })
    }
}

//struct SystemButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SystemButton()
//    }
//}

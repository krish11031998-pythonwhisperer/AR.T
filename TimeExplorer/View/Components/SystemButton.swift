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
    var alignment:Axis.Set
    var size:CGSize = .init(width: 10, height: 10)
    fileprivate var bgcolor:Color? = nil
    init(b_name:String,b_content:String,color:Color = .white,
         haveBG:Bool = true,
         size:CGSize? = nil,
         bgcolor:Color? = nil,
         alignment:Axis.Set = .horizontal,
         action:@escaping () -> Void){
        self.buttonName = b_name
        self.buttonContent = b_content
        self.actionHandler = action
        self.color = color
        self.haveBG = haveBG
        self.bgcolor = bgcolor
        self.alignment = alignment
        if let safeSize = size{
            self.size = safeSize
        }
    }
    
    var bgColor:Color{
        get{
            return self.bgcolor != nil ? self.bgcolor! : self.color == .white ? .black : .white
        }
    }
    
    
    
    var ButtonImg:AnyView{
        if self.haveBG{
            return AnyView(
                Image(systemName: self.buttonName)
                    .resizable()
                    .frame(width: self.size.width, height: self.size.height, alignment: .center)
                    .foregroundColor(color)
//                    .padding(size.width * 0.5)
                    .padding(10)
                    .background(haveBG ? bgColor : Color.clear)
                    .clipShape(Circle())
            )
        }else{
            return AnyView(Image(systemName: self.buttonName)
                            .resizable()
                            .frame(width: self.size.width, height: self.size.height, alignment: .center)
                            .foregroundColor(color)
                            .padding(.vertical,size.width * 0.5)
            )
        }
    }
    
    var labelView:AnyView{
        var view = AnyView(Color.clear)
        if self.alignment == .vertical{
            view =  AnyView(VStack(alignment:.center,spacing:5){
                self.ButtonImg
                if self.buttonContent != ""{
                    MainText(content: self.buttonContent, fontSize: size.width,color: bgColor)
                }
                
            })
        }else if self.alignment == .horizontal{
            view =  AnyView(HStack(alignment:.center,spacing:5){
                self.ButtonImg
                if self.buttonContent != ""{
                    MainText(content: self.buttonContent, fontSize: size.width,color: bgColor)
                }
                
            })
        }
        return view
    }
    
    var body: some View {
        Button(action: {
            self.actionHandler()
        }, label: {
            self.labelView
        })
    }
}

//struct SystemButton_Previews: PreviewProvider {
//    static var previews: some View {
//        SystemButton()
//    }
//}

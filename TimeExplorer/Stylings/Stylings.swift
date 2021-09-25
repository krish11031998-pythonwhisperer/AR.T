//
//  Stylings.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/5/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI

struct ContentClipping:ViewModifier{
    var clipping:Clipping
    func body(content: Content) -> some View {
        return content
            .contentShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
            .clipShape(RoundedRectangle(cornerRadius: self.clipping.rawValue))
    }
}

struct ImageTransition:ViewModifier{
    @State var load:Bool = false
    
    func onAppear(){
        withAnimation(.easeInOut(duration: 0.5)) {
            self.load = true
        }
    }
    
    var scale:CGFloat{
        return self.load ? 1 : 1.075
    }
    
    func body(content: Content) -> some View {
        return content
            .scaleEffect(self.scale)
            .onAppear(perform: self.onAppear)
    }
}

extension AnyTransition{
    static var slideInOut:AnyTransition{
        return AnyTransition.asymmetric(insertion:.move(edge: .bottom), removal: .move(edge: .bottom))
    }
    
}

struct ButtonModifier:ButtonStyle{
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
    }
}

extension View{
    func springButton() -> some View{
        self.buttonStyle(ButtonModifier())
    }
    
    func imageSpring() -> some View{
        self.modifier(ImageTransition())
    }
    
    func clipContent(clipping:Clipping = .clipped) -> some View{
        self.modifier(ContentClipping(clipping: clipping))
    }
}

struct Corners:Shape{
    
    var rectCorners:UIRectCorner
    var size:CGSize
    init(rect:UIRectCorner,size:CGSize? = nil){
        self.rectCorners = rect
        if let safeSize = size{
            self.size = safeSize
        }else{
            self.size = CGSize(width: 50, height: 50)
        }
    }
    func path(in rect: CGRect) -> Path {
        return Path(UIBezierPath(roundedRect: rect, byRoundingCorners: self.rectCorners, cornerRadii: self.size).cgPath)
//        return Path(
    }
    
    
}

struct Wave:Shape{
    var offset:CGFloat = 0.5
    var animatableData: CGFloat{
        get{
            return self.offset
        }
        set{
            self.offset = newValue
        }
    }
    
    func curveHeight(value:CGFloat,factor:CGFloat) -> CGFloat{
        var finalValue = value * factor
//        return finalValue > value ? value : finalValue
        return finalValue
    }
    
    func path(in rect:CGRect) -> Path{
        var path = Path()
        let maxH:CGFloat = rect.maxY * 0.9
        var c1H = self.curveHeight(value:maxH,factor:(1 - offset))
        var c2H = self.curveHeight(value:maxH,factor:(1 + offset))
        path.move(to: .zero)
        path.addLine(to: .init(x: rect.maxX, y: rect.minY))
        path.addLine(to: .init(x: rect.maxX, y: rect.maxY))
//        path.addCurve(to: .init(x: rect.minX, y: rect.maxY), control1: .init(x: rect.maxX * 0.75, y: maxH * (1 - offset)), control2: .init(x: rect.maxX * 0.25, y: maxH * (1 + offset)))
        path.addCurve(to: .init(x: rect.minX, y: rect.maxY), control1: .init(x: rect.maxX * 0.75, y: c1H ), control2: .init(x: rect.maxX * 0.25, y: c2H))
        path.addLine(to: .init(x: rect.minX, y: rect.minY))
        return path
    }
}

struct AnimatedWaves:View{
    var image:UIImage = .init()
    var offset:CGFloat = 0.5
    @State private var change:Bool = false
    var aR:CGFloat?
    
    var aspectRatio:CGFloat{
        get{
            return self.aR != nil ? self.aR! : UIImage.aspectRatio(img: self.image)
        }
    }
    var changeOffset:CGFloat{
        get{
           return self.change ? offset : -offset
        }
    }
    var body: some View{
        Image(uiImage: self.image)
            .resizable()
            .frame(width:totalWidth,height: 300)
            .aspectRatio(self.aspectRatio, contentMode: .fill)
            .clipShape(Wave(offset: self.changeOffset))
            .animation(Animation.easeInOut(duration: Double(self.offset * 10)).repeatForever(autoreverses: true))
            .onAppear(perform: {
                self.change = true
            })
    }
}

struct BlurView:UIViewRepresentable{
    var style : UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: self.style))
        return view
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}


struct ArcCorners:Shape{
    
    var corner:UIRectCorner = .topRight
    var curveFactor:CGFloat = 0.75
    var cornerRadius:CGFloat = 45.0
    var roundedCorner:UIRectCorner = .allCorners
    
    func CornerPoint(_ rect:CGRect,_ corner:UIRectCorner) -> CGPoint{
        var point:CGPoint = .init()
        var topCorner = self.corner == corner ? rect.height * self.curveFactor : 0
        var bottomCorner = self.corner == corner ? rect.height * (1 - self.curveFactor) : rect.height
        var val = corner == .topRight || corner == .topLeft ? topCorner : bottomCorner
        switch (corner){
            case .topLeft:
                point = CGPoint(x:0 , y: val)
                break
            case .topRight:
                point = CGPoint(x:rect.width,y:val)
                break
            case .bottomLeft:
                point = CGPoint(x:0 , y: val)
                break
            case .bottomRight:
                point = CGPoint(x:rect.width,y:val)
                break
            default:
                break
        }
        
        return point
    }
    
    func curvedCorners(_ corner:UIRectCorner) -> CGFloat{
        return corner == .allCorners || self.roundedCorner.contains(corner) ? self.cornerRadius : 0
    }
    
    func path(in rect: CGRect) -> Path {
        return Path{path in
            var topRight = self.CornerPoint(rect, .topRight)
            var topLeft = self.CornerPoint(rect, .topLeft)
            var bottomLeft = self.CornerPoint(rect, .bottomLeft)
            var bottomRight = self.CornerPoint(rect, .bottomRight)
            
            switch (corner){
            case .topLeft, .bottomLeft:
                    path.move(to: topLeft)
                    break
                case .topRight , .bottomRight:
                    path.move(to: topRight)
                    break
                default:
                    break
            }
            
            path.addArc(tangent1End: topLeft, tangent2End: bottomLeft, radius: self.curvedCorners(.topLeft))
            path.addArc(tangent1End: bottomLeft, tangent2End: bottomRight, radius: self.curvedCorners(.bottomLeft))
            path.addArc(tangent1End: bottomRight, tangent2End: topRight, radius: self.curvedCorners(.bottomRight))
            path.addArc(tangent1End: topRight, tangent2End: topLeft, radius: self.curvedCorners(.topRight))
            
        }
    }
    
    
    
}

struct BarCurve:Shape{
    var tabPoint:CGFloat
    
    var animatableData: CGFloat{
        get{return self.tabPoint}
        set{
            self.tabPoint = newValue
        }
    }
    
    
    func path(in rect: CGRect) -> Path {
        
        return Path{path in
            
            var width = rect.width
            var height = rect.height
            
            path.move(to: .init(x: width, y: height))
            path.addLine(to: .init(x: width, y: 0))
            path.addLine(to: .init(x: 0, y: 0))
            path.addLine(to: .init(x: 0, y: height))
            
            var mid = (width * 0.5 + self.tabPoint) - 15
            
            path.move(to: .init(x: mid - 40, y: height))
            
            var to1 = CGPoint(x: mid, y: height - 20)
            var control1 = CGPoint(x : mid - 15,y:height)
            var control2 = CGPoint(x : mid - 15,y:height - 20)
            
            
            var to2 = CGPoint(x: mid + 40, y: height)
            var control3 = CGPoint(x : mid + 15,y:height - 20)
            var control4 = CGPoint(x : mid + 15,y:height)
            
            path.addCurve(to: to1, control1: control1, control2: control2)
            
            path.addCurve(to: to2, control1: control3, control2: control4)
        }
    }
}


struct GradientShadows:View{
    
    var color:Color
    var mode:Color
    init(color:Color,mode:Color = .white){
        self.color = color
        self.mode = mode
    }
    
    var body: some View{
        LinearGradient(gradient: .init(colors: [self.color,self.color.opacity(0.5),self.mode]), startPoint: .topLeading, endPoint: .bottomTrailing);
    }
    
}

struct Stylings_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            AnimatedWaves(image: UIImage(named: "NightLifeStockImage")!, offset: 0.15)
            
            Spacer()
        }.edgesIgnoringSafeArea(.all)
        
    }
}

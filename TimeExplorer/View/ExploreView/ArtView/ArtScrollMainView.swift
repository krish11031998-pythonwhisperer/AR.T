//
//  ArtScrollMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 03/05/2021.
//

import SwiftUI

struct ArtScrollMainView: View {
    @EnvironmentObject var mainStates:AppStates
    var data:ArtData
    @Binding var showArt:Bool
    var imgSet:[String]{
        var res:[String] = ["monaLisa"]
        for x in 1...5{
            res.append("img\(x)")
        }
        return res
    }
    
    var thresHeight:CGFloat{
        return totalHeight * 0.1
    }
    @State var minY:CGFloat = 0
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    @State var changeFocus:Bool = false
    let no_cards:Int = 4

    func onChanged(value:DragGesture.Value){
        let height = value.translation.height
        self.offset = height
    }
    
    func onEnded(value:DragGesture.Value){
        let height = value.translation.height
        var off:CGFloat = 0
        var val:Int = 0
        if abs(height) > 100{
            val = height > 0 ? -1 : 1
            if self.swiped + val <= self.no_cards - 1 && self.swiped + val >= 0{
                self.swiped += val
                print("swiped : \(self.swiped)")
            }else if (self.swiped == 0 && height > 0) {
                off = totalHeight
            }else if (self.swiped == self.no_cards - 1 && height < 0) {
                self.swiped = 0
            }
        }
        self.offset = off
        
    }
    
    var off_percent:CGFloat{
        let percent = abs(self.offset)/self.thresHeight
        return percent > 1 ? 1 : percent < 0 ? 0 : percent
    }
    
    var swipedOffset:CGFloat{

        let y_off = -CGFloat(self.swiped) * totalHeight
        return y_off
    }
    
    func activeViews(idx:Int) -> some View{
        var view:AnyView = .init(Color.clear)
        switch(idx){
        case 0:
            view = AnyView(ScrollInfoCard(data: data,minY: $minY,showArt: $showArt,onChanged: self.onChanged(value:),onEnded: self.onEnded(value:)))
        case 1:
            view = AnyView(ArtView(data: data,onChanged: self.onChanged(value:),onEnded: self.onEnded(value:)))
        case 2:
            view = AnyView(ArtTopFactView(data: self.data,ver_onChanged: self.onChanged(value:),ver_onEnded:self.onEnded(value:)))
        case 3:
            view = AnyView(ArtPageView(data: self.data,onChanged: self.onChanged(value:),onEnded: self.onEnded(value:)))
        default:
            break
        }
        return view
    }
    
    var body:some View{
        return VStack(alignment: .center, spacing: 0) {
            ForEach(Array(0..<self.no_cards),id:\.self){idx in
                self.activeViews(idx: idx)
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .offset(y: swipedOffset + self.offset)
        .animation(.easeInOut)
        .onChange(of: self.minY, perform: { value in
            if self.swiped == 0 && self.minY == totalHeight && self.showArt{
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)) {
                    self.showArt = false
                    print("The main View is hidden !")
                }
            }
        })
        .onAppear(perform: {
            if self.mainStates.showTab{
                self.mainStates.showTab = false
            }
        })
        .onDisappear(perform: {
            if !self.mainStates.showTab{
                self.mainStates.showTab = true
            }
        })
        
    }
}

//struct VScrollView_Previews: PreviewProvider {
//    static var previews: some View {
//        ArtScrollMainView()
//    }
//}

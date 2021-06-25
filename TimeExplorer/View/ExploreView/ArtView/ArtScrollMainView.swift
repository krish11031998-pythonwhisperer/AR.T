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
    @State var minY:CGFloat = 0
    @State var swiped:Int = 0
    @State var offset:CGFloat = 0
    @State var changeFocus:Bool = false
    let no_cards:Int = 4
    var off_percent:CGFloat{
        let percent = abs(self.offset)/self.thresHeight
        return percent > 1 ? 1 : percent < 0 ? 0 : percent
    }
    
    var swipedOffset:CGFloat{
        let y_off = -CGFloat(self.swiped) * totalHeight
        return y_off
    }
    
    
    func onChanged(value:DragGesture.Value){
        let height = value.translation.height
        let val = value.location.y - value.startLocation.y
        self.offset = val
    }
    
    func onEnded(value:DragGesture.Value){
//        let height = value.translation.height  * 1.5
        let height = self.offset
        var off:CGFloat = 0
        var val:Int = 0
        if abs(height) > totalHeight * 0.15{
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
    var thresHeight:CGFloat{
        return totalHeight * 0.1
    }
    
    func activeViews(idx:Int,onChanged:((DragGesture.Value) -> Void)? = nil,onEnded:((DragGesture.Value) -> Void)? = nil) -> AnyView{
        var view:AnyView = .init(Color.clear)
        switch(idx){
        case 0:
            view = AnyView(ScrollInfoCard(data: data,minY: $minY,showArt: $showArt,onChanged: onChanged ?? self.onChanged(value:),onEnded: onEnded ?? self.onEnded(value:)))
        case 1:
            view = AnyView(ArtView(data: data,onChanged:onChanged ?? self.onChanged(value:),onEnded: onEnded ?? self.onEnded(value:)))
        case 2:
            view = AnyView(ArtTopFactView(data: self.data,ver_onChanged:onChanged ?? self.onChanged(value:),ver_onEnded:onEnded ?? self.onEnded(value:)))
        case 3:
//            view = AnyView(ArtPageView(data: self.data,onChanged:onChanged ?? self.onChanged(value:),onEnded: onEnded ?? self.onEnded(value:)))
            view = AnyView(ArtStockView(data: .init(img: self.data.thumbnail, title: self.data.title, subtitle: self.data.painterName, data: self.data),close: self.$showArt))
        default:
            break
        }
        return view
    }
    
    var scrollController:FeedVerticalScroll{
        var controller = FeedVerticalScroll(view: [])
        
        controller.views = views
        return controller
    }
    
    var views:[AnyView]{
        let views = Array(0..<self.no_cards).map({self.activeViews(idx: $0)})
        return views
    }
    
    var body:some View{
        return VStack(alignment: .center, spacing: 0) {
            ForEach(Array(self.views.enumerated()),id:\.offset){ _view in
//                self.activeViews(idx: idx)
                let view = _view.element
                view
            }
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .top)
        .offset(y: self.swipedOffset + self.offset)
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
                self.mainStates.toggleTab()
            }
            
            if self.mainStates.loading{
                self.mainStates.loading = false
            }
        })
    }
}

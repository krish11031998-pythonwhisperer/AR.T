//
//  FancyScrollMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI

struct FancyScrollMain: View {
    @EnvironmentObject var mainStates:AppStates
    @State var exploreList : [ExploreData] = []
    @State var art:ArtData? = nil
    @State var showArt:Bool = false
    @State var idx:Int = 0
    var dispatchGroup:DispatchGroup = .init()
    
    func onAppear(){
        self.mainStates.toggleTab()
        if let data = self.mainStates.getArt(limit: 100,skip: 300){
            self.parseData(data)
        }
    }
    
    
    
    func parseData(_ data:[CAData]){
        if !data.isEmpty{
            let _data = data.compactMap({$0.images?.web?.url != nil ? ExploreData(img: $0.images?.web?.url, data: $0) : nil})
            DispatchQueue.main.async {
                self.exploreList = _data
                withAnimation(.easeInOut) {
                    self.mainStates.loading = false
                }
            }
        }
       
    }
    
    func updateShowArt(art: ArtData?){
        if art != nil{
            self.showArt = true
        }else if self.showArt{
            self.showArt = false
        }
    }
    
    var header:some View{
        HStack(alignment: .center, spacing: 10){
            MainText(content: "Discover", fontSize: 50, color: .white, fontWeight: .bold, style: .heading)
            Spacer()
            SystemButton(b_name: "homekit", b_content: "",color: .white, size: .init(width: 20, height: 20)) {
                self.mainStates.tab = "home"
            }
            SystemButton(b_name: "arrow.clockwise", b_content: "", color: .white, haveBG: true, size: .init(width: 20, height: 20), bgcolor: .black) {
                if (self.idx + 2) * 25 <= self.exploreList.count{
                    self.idx += 1
                }else{
                    self.idx = 0
                }
            }
        }.padding()
        .padding(.top,35)
        .frame(width: totalWidth, alignment: .leading)
        .background(bottomShadow.rotationEffect(.init(degrees: .init(180))))
    }

    var body: some View {
        ZStack(alignment: .top) {
//            Color.black
//            FancyScroll(selectedArt: $art,showArt:$showArt,data: self.exploreList)
            FancyScroll(selectedArt: $art,showArt:$showArt,data: self.exploreList,idx: $idx).zIndex(1)
            self.header.zIndex(1)
            if self.showArt, let art = self.art{
                ArtScrollMainView(data: art, showArt: $showArt)
//                    .transition(.move(edge: .bottom).combined(with: .identity))
                    .transition(.slideInOut)
                    .zIndex(2)
            }
        }.edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
        .onChange(of: self.art, perform: self.updateShowArt(art:))
        .onDisappear(perform: self.mainStates.toggleTab)
        .animation(.easeInOut)

    }
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        FancyScrollMain()
    }
}

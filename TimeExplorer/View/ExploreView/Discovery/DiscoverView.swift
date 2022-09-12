//
//  FancyScrollMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI
import SUI

struct DiscoverView: View {
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
				self.art = _data.first?.data as? ArtData
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
            MainText(content: "Discover", fontSize: 30, color: .white, fontWeight: .bold, style: .heading)
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
	
	@ViewBuilder var selectedArtView: some View {
		if let art = self.art{
			ArtScrollMainView(data: art, showArt: $showArt)
		} else {
			Color.clear.frame(size: .zero)
		}
	}

    var body: some View {
        ZStack(alignment: .top) {
            Color.black
			DiscoveryView(data: exploreList, model: .init(cardSize: .init(width: 200, height: 350), rows: 4, spacing: 10, bgColor: .clear)) { data in
				SUI.ImageView(url: (data as? ExploreData)?.img)
					.framed(size: .init(width: 200, height: 350), cornerRadius: 15, alignment: .center)
			}
			header
        }
		.edgesIgnoringSafeArea(.all)
        .onAppear(perform: self.onAppear)
        .onReceive(self.mainStates.TabAPI[self.mainStates.tab]!.$artDatas, perform: self.parseData)
        .onChange(of: self.art, perform: self.updateShowArt(art:))
        .onDisappear(perform: self.mainStates.toggleTab)
		.fullScreenModal(isActive: $showArt, config: .init(isDraggable: false, showCloseIndicator: true)) {
			selectedArtView
		}

    }
}

struct FancyScrollMain_Previews: PreviewProvider {
    static var previews: some View {
        DiscoverView()
    }
}

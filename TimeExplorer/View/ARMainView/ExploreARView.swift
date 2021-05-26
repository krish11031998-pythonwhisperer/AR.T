//
//  ExploreARView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 21/05/2021.
//

import SwiftUI

struct ExplorationARView: View {
    @StateObject var MD:ARModelDownloader = .init()
    @EnvironmentObject var mainStates:AppStates
    
    func onAppear(){
        if self.MD.url == nil{
            self.MD.loadModel(name: "2FPainting_by_Zdzislaw_Beksinski_1", url_string: "https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/models%2FPainting_by_Zdzislaw_Beksinski_1.usdz?alt=media&token=1d59a3da-71f0-403a-877c-1f7fabd89388")
        }
    }
    
    
    var body: some View {
        ZStack(alignment: .center) {
            ExploreARView(url: self.$MD.url, testing: true)
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(self.MD.$url, perform: { _ in
            if self.mainStates.loading{
                self.mainStates.loading.toggle()
            }
        })
    }
}

struct ExploreARView_Previews: PreviewProvider {
    static var previews: some View {
        ExploreARView()
    }
}

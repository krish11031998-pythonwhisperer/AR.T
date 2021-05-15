//
//  ARView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/05/2021.
//

import SwiftUI

struct ARMainView: View {
    @StateObject var mdlDM:ARModelDownloader = .init()
    var name:String
    var url:String
    @Binding var show:Bool
    @State var cancel:Bool = true
    @State var placeModel:Bool = false
    
    init(name:String,url: String,show:Binding<Bool>){
        self.name = name
        self.url = url
        self._show = show
    }
    
    func togglePlace(){
        self.placeModel.toggle()
    }
    
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
            self.mdlDM.loadModel(name: self.name, url_string: self.url)
        }
    }
    
    func onReceive(url:URL?){
        if url != nil{
            self.cancel = false
        }
    }
    
    var ARControllerView:some View{
        VStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10){
                Spacer()
                SystemButton(b_name: "xmark", b_content: "", color: .black, haveBG: true, bgcolor: .white) {
                    self.show.toggle()
                }
            }.padding().frame(width: totalWidth, alignment: .center)
            Spacer()
            if !self.cancel{
                HStack(alignment: .center, spacing: 10){
                    Spacer()
                    SystemButton(b_name: "checkmark", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                        self.placeModel.toggle()
                    }
                    SystemButton(b_name: "xmark", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                        self.cancel.toggle()
                    }
                    Spacer()
                }.frame(width: totalWidth, alignment: .center)
            }
            
        }.padding()
        .padding(.bottom,20)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
    }
    
    var body: some View {
        ZStack{
            ARViewContainer(url: self.$mdlDM.url, place: self.$placeModel)
                .frame(width: totalWidth, height: totalHeight, alignment: .center)
            if !self.cancel{
                self.ARControllerView
            }
            
        }.edgesIgnoringSafeArea(.all)
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .onAppear(perform: self.onAppear)
        .onReceive(mdlDM.$url, perform: self.onReceive(url:))
    }
}

//struct ARView_Previews: PreviewProvider {
//    static var previews: some View {
//        ARMainView()
//    }
//}

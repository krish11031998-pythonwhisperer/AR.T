//
//  ARView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/05/2021.
//

import SwiftUI
import ARKit
import RealityKit

struct ARMainView: View {
    @EnvironmentObject var sceneState: ArtViewStates
    @StateObject var mdlDM:ARModelDownloader = .init()
    var name:String
    var model_url:String?
    var img_url:String?
    @Binding var show:Bool
    @State var cancel:Bool = true
    @State var placeModel:Bool = false
    @StateObject var IMD:ImageDownloader = .init()
    init(name:String,model_url: String? = nil,img_url: String? = nil,show:Binding<Bool>){
        self.name = name
        self.model_url = model_url
        self.img_url = img_url
        self._show = show
    }
    

    func togglePlace(){
        self.placeModel.toggle()
    }
    
    
    func onAppear(){
        if let url = self.model_url{
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(250)) {
                self.mdlDM.loadModel(name: self.name, url_string: url)
            }
        }else if let url = self.img_url{
            guard let model = ModelEntity.loadModelEntityFromImage(url: URL(string:url)) else {return}
            DispatchQueue.main.async {
                self.mdlDM.model = model
                self.cancel = false
            }
            
        }
        
    }
    
    
//    func load
    
    
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
            ARViewContainer(url: self.$mdlDM.url, model: self.$mdlDM.model, place: self.$placeModel)
//            ARViewContainer(model: self.$mdlDM.model, place: self.$placeModel)
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

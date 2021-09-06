//
//  SceneModelView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/04/2021.
//

import SwiftUI
import RealityKit
import ARKit
import SceneKit

struct SceneModelView: View {
    var w:CGFloat
    var h:CGFloat
    var name:String
    var model_url_str:String?
    var img_url_str:String?
    @EnvironmentObject var viewStates:ArtViewStates
    @StateObject var mdD:ARModelDownloader = .init()
    @StateObject var IMD:ImageDownloader = .init(quality:.highest)
    @State var scene:SCNScene? = nil
    @Binding var player:AVPlayer?
    @State var idx:Int = 1
    @State var img:UIImage? = nil
    var sendAnnotation: ((String,SCNVector3?) -> Void)? = nil
    
    
    init(w:CGFloat,h:CGFloat,name:String,model_url_str:String? = nil,img_url_str:String? = nil,player:Binding<AVPlayer?>? = nil,handler:((String,SCNVector3?) -> Void)? = nil){
        self.w = w
        self.h = h
        self.name = name
        self.model_url_str = model_url_str
        self.img_url_str = img_url_str
        self._player = player ?? .constant(nil)
        self.sendAnnotation = handler
    }
    
    
    func getName(name:String){
        print(name)
    }
    
    func onAppear(){
         if let model = self.model_url_str{
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.mdD.loadModel(name: self.name, url_string: model)
            }
        }else if let img = self.img_url_str{
            DispatchQueue.global(qos: .background).asyncAfter(deadline: .now() + .milliseconds(500)) {
                self.IMD.getImage(url: img)
            }
            
        }
    }
    
    
    func sceneTapHandler(_ name:String,_ vector:SCNVector3?){
        if self.sendAnnotation != nil{
            self.sendAnnotation!(name,vector)
        }
    }
    
    func sceneView() -> AnyView{
        var view = AnyView(Color.clear.frame(width: 0, height: 0, alignment: .center))
        view = AnyView(SCNSceneView(type: self.model_url_str == nil && self.img_url_str != nil ? .image : .model, modelImg: $IMD.image, model: $scene, idx: $idx, player: $player, taphandler: self.sceneTapHandler(_:_:)).environmentObject(self.viewStates))
        return view
    }
    
    func onReceive(url:URL?){
        var scene:SCNScene? = nil
        if let url = url{
            do{
                scene = try SCNScene(url: url)
            }catch{
                print(error.localizedDescription)
            }
        }
        
        if scene != nil{
            DispatchQueue.main.async {
                self.scene = scene
            }
        }
    }

    var body: some View {
        GeometryReader{g  -> AnyView in
            let minY = g.frame(in: .global).minY
            
            DispatchQueue.main.async {
                if minY == 0 && self.mdD.url == nil{
                    self.onAppear()
                }
            }
            return AnyView(
                ZStack{
                    if self.scene == nil{
                        Color.black
                        ProgressView()
                    }
                    
                    if self.scene != nil || self.IMD.image != nil{
                        self.sceneView()
                    }
                }
            )
        }
        .frame(width: w, height: h, alignment: .center)
//        .onAppear(perform: self.onAppear)
        .onReceive(self.mdD.$url, perform: self.onReceive)
        .animation(.easeInOut)
        
    }
}

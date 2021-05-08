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
    var url_str:String
    @EnvironmentObject var viewStates:ArtViewStates
    @StateObject var mdD:ARModelDownloader = .init()
    @State var scene:SCNScene? = nil
    @Binding var isEditting:Bool
    @Binding var showFeatures:Bool
    @Binding var selectedAnnotation:String
    @Binding var annotations:[String:SCNVector3]
    @Binding var player:AVPlayer?
    @State var idx:Int = 1
    var sendAnnotation: ((String,SCNVector3?) -> Void)? = nil
    
    
    init(isEdit:Binding<Bool> = .constant(false),annotations:Binding<[String:SCNVector3]> = .constant([:]),showAnnotations:Binding<Bool> = .constant(false),selectedAnnotation:Binding<String> = .constant(""),name:String,url_str:String,w:CGFloat,h:CGFloat,player:Binding<AVPlayer?>? = nil,handler: ((String,SCNVector3?) -> Void)? = nil){
        self._isEditting  = isEdit
        self._annotations = annotations
        self._selectedAnnotation = selectedAnnotation
        self._showFeatures = showAnnotations
        self.name = name
        self.url_str = url_str
        self.w = w
        self.h = h
        self.sendAnnotation = handler
        self._player = player ?? .constant(nil)
    }

    
    func getName(name:String){
        print(name)
    }
    
    func sceneView() -> some View{
        let sceneView  = SCNSceneView(model: $scene, isEditting: $isEditting, annotations: $annotations, idx: $idx, showAnnotations: $showFeatures
                                      ,annotationVideos: $viewStates.annotationVideo, inspect:$viewStates.inspect,player: $player, width: w, height: h)
        { (name,vector) in
            if self.sendAnnotation != nil{
                self.sendAnnotation!(name,vector)
            }
            self.selectedAnnotation = name
        }
        return sceneView
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
    
    func onAppear(){
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(500)) {
            self.mdD.loadModel(name: self.name, url_string: self.url_str)
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
                        BlurView(style: .dark)
                    }
                    
                    if self.scene != nil{
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

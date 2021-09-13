//
//  ARMainView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/05/2021.
//

import SwiftUI
import ARKit
import RealityKit
import FocusEntity

class FocusARView : ARView{
    var focusEntity:FocusEntity?
    
    required init(frame frameRect: CGRect) {
        super.init(frame: frameRect)
        self.focusEntity = .init(on: self, focus: .classic)
        self.focusEntity?.isEnabled = false
        self.configure()
    }
    
    @objc required dynamic init?(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(){
        let config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        self.session.run(config)
    }
}


struct ARViewContainer:UIViewRepresentable{

    @Binding var url:URL?
    @Binding var model:ModelEntity?
    @Binding var place:Bool
    @State var attachedModel:Bool = false
    var annotations:[SCNVector3] = []
    
    init(url:Binding<URL?> = .constant(nil),model:Binding<ModelEntity?> = .constant(nil),place:Binding<Bool>){
        self._url = url
        self._model = model
        self._place = place
    }
    
    func makeUIView(context: Context) -> FocusARView {
        let view = FocusARView(frame: .zero)
        return view
    }
    
    
    func updateModel(view: FocusARView, url:URL){
        guard let focusEntity = view.focusEntity else {return}
        view.addModel(url: url, position: focusEntity.position, scale: focusEntity.scale)
    }
    
    func deleteModel(view: FocusARView){
        guard let anchor = view.scene.findEntity(named: "arModel")?.anchor else {return}
        view.scene.removeAnchor(anchor)
        print("removed the Model from the scene !")
    }
    
    
    func loadFromURL(uiView: FocusARView){
        if let url = self.url,let focus = uiView.focusEntity{
            
            if !focus.isEnabled{
                print("Received the model !")
                DispatchQueue.main.async {
                    focus.isEnabled = true
                }
            }
            
            if self.place && !self.attachedModel{
                self.updateModel(view: uiView, url: url)
                DispatchQueue.main.async {
                    self.attachedModel = true
                }
            }
            
        }
    }
    
    func loadFromModel(uiView: FocusARView){
        if let model = self.model,let focus = uiView.focusEntity{
            if !focus.isEnabled{
                print("Received the model !")
                DispatchQueue.main.async {
                    focus.isEnabled = true
                }
            }
            
            
            if self.place && !self.attachedModel{
//                self.updateModel(view: uiView, url: url)
                uiView.addModel(model: model, position: .init(x: focus.position.x * 0.5, y: focus.position.y * 0.5, z: focus.position.z * 0.5), scale: focus.scale)
                DispatchQueue.main.async {
                    self.attachedModel = true
                }
            }
            
        }
    }
    
    func updateUIView(_ uiView: FocusARView, context: Context) {
        self.loadFromURL(uiView: uiView)
        self.loadFromModel(uiView: uiView)
        
        
        if let focusEntity = uiView.focusEntity,self.attachedModel && focusEntity.isEnabled{
            focusEntity.isEnabled = false
        }
    }
    
}

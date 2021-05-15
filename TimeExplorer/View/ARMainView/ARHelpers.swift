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
    @Binding var place:Bool
    @State var attachedModel:Bool = false
    
    func makeUIView(context: Context) -> FocusARView {
        let view = FocusARView(frame: .zero)
        return view
    }
    
    
    func updateModel(view: FocusARView, url:URL){
        guard let focusEntity = view.focusEntity else {return}
        view.addModel(url: url, position: focusEntity.position, scale: focusEntity.scale)
//        view.focusEntity?.isEnabled = false
    }
    
    func deleteModel(view: FocusARView){
        guard let anchor = view.scene.findEntity(named: "arModel")?.anchor else {return}
        view.scene.removeAnchor(anchor)
        print("removed the Model from the scene !")
    }
    
    
    func updateUIView(_ uiView: FocusARView, context: Context) {
        if let url = self.url{
            
            if let focus = uiView.focusEntity, !focus.isEnabled{
                print("Received the model !")
                focus.isEnabled = true
            }
            
            if self.place && !self.attachedModel{
                self.updateModel(view: uiView, url: url)
                DispatchQueue.main.async {
                    self.attachedModel = true
                }
            }
            
        }
        
        if let focusEntity = uiView.focusEntity,self.attachedModel && focusEntity.isEnabled{
//            uiView.focusEntity?.isEnabled = false
            focusEntity.isEnabled = false
        }
        
    }
    
}

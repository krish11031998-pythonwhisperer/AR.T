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
        var config = ARWorldTrackingConfiguration()
        config.planeDetection = [.horizontal,.vertical]
        self.session.run(config)
    }
}

//struct ARViewContainer:UIViewRepresentable{
//    @EnvironmentObject var mainContext:AppContext
//
//    func makeUIView(context: Context) -> CustomARView {
//        var arView = CustomARView(frame: .zero)
//        arView.enableGestures()
//        self.mainContext.subscriber = arView.scene.subscribe(to: SceneEvents.Update.self, { (event) in
//            self.updateScene(for: arView)
//        })
//        return arView
//    }
//
//
//    func updateScene(for arView:CustomARView){
//        arView.focusEntity?.isEnabled = self.mainContext.selectedModel != nil
//
//        if let confirmed = self.mainContext.confirmedModel, let modelEntity = confirmed.model, let position = arView.focusEntity?.position,let scale = arView.focusEntity?.scale{
//
//            arView.addModel(scale:scale,_modelEntity: modelEntity, position: position)
//            self.mainContext.allModelinView[modelEntity.name] = confirmed
//            self.mainContext.confirmedModel = nil
//        }
//
//        if let delete = self.mainContext.modelToDelete, let modelEntity = delete.model, let entity = arView.scene.findEntity(named: modelEntity.name), let anchor = entity.anchor{
//            arView.scene.removeAnchor(anchor)
//            self.mainContext.modelToDelete = nil
//            print("Successfully deleted the model with name : \(modelEntity.name)")
//            self.mainContext.allModelinView.removeValue(forKey: modelEntity.name)
//        }
//    }
//
//    func updateUIView(_ uiView: CustomARView, context: Context) {
//    }
//}


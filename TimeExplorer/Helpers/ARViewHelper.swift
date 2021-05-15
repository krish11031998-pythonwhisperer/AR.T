//
//  ARVIewHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/05/2021.
//

import Foundation
import ARKit
import RealityKit



extension ARView{
    
    
    func addModel(model _model:ModelEntity? = nil,url _url:URL? = nil,position _pos:SIMD3<Float>? = nil, scale _scale:SIMD3<Float>? = nil){
        var model:ModelEntity = .init()
        if let mod = _model{
            model = mod
        }else if let url = _url,let entity = try? ModelEntity.loadModel(contentsOf: url){
            model = entity
        }
        model.name = "arModel"
        model.generateCollisionShapes(recursive: true)
        let anchor = AnchorEntity(plane: .horizontal)
        if let pos = _pos{
            anchor.position = pos
        }
        anchor.addChild(model)
        self.scene.addAnchor(anchor)
        self.installGestures([.translation,.scale], for: model)
    }
    
}

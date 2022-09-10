//
//  ARVIewHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/05/2021.
//

import Foundation
import ARKit
import RealityKit



extension ModelEntity{
    
//    static func loadModelEntityFromImage(_img:UIImage? = nil) -> ModelEntity?{
//        guard let img = _img else {return nil}
//        let dim = UIImage.dimension(img: img)
//        let mesh = MeshResource.generatePlane(width: Float(dim.width), height: Float(dim.height))
////        let mat = SimpleMaterial()
//        let mat = SimpleMaterial(color: .white, roughness: 0.1, isMetallic: false)
//        let model = ModelEntity(mesh: mesh, materials: [mat])
//
////        model.model?.materials = [ImageMe]
//        model
//
//    }
    static func loadModelEntityFromImage(url:URL? = nil) -> ModelEntity?{
        // Create a temporary file URL to store the image at the remote URL.
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        // Download contents of imageURL as Data.  Use a URLSession if you want to do this asynchronously.
        guard let url = url, let data = try? Data(contentsOf: url) else {return nil}
        
        // Write the image Data to the file URL.
            try! data.write(to: fileURL)

        do {
            // Create a TextureResource by loading the contents of the file URL.
            let texture = try TextureResource.load(contentsOf: fileURL)
            var material = SimpleMaterial()
            material.baseColor = MaterialColorParameter.texture(texture)
            let entity = ModelEntity(mesh: .generatePlane(width: 0.2, height: 0.2), materials: [material])
            return entity
        } catch {
            print(error.localizedDescription)
            return nil
        }
        
    }
    
    
    
    
}

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
        let anchor = AnchorEntity()
        if let pos = _pos{
            anchor.position = pos
        }
        anchor.addChild(model)
        self.scene.addAnchor(anchor)
        self.installGestures([.translation,.scale], for: model)
    }
    
}

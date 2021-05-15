//
//  SCNSceneView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/04/2021.
//

import SwiftUI
import RealityKit
import ARKit
import SceneKit

class SceneViewStates:ObservableObject{
    @Published var firstLoad:Bool = false
    @Published var gesturesEnabled:Bool = false
    @Published var mainSceneNode:SCNNode? = nil
    @Published var annotationNode:[String:SCNNode] = [:]
    @Published var playerNode:SCNNode? = nil
    @Published var addedPlayer:Bool = false
    @Published var location:SCNVector3? = nil
    @Published var prevLoc:CGPoint = .init(x: 0,y:0)
}

struct SCNSceneView:UIViewRepresentable{
    
    @EnvironmentObject var arViewStates:ArtViewStates

    @Binding var model:SCNScene?
    @Binding var idx:Int
    @Binding var player:AVPlayer?
    
    @StateObject var sceneStates:SceneViewStates = .init()
    
    var width:CGFloat
    var height:CGFloat
    var view:SCNView = .init()
    var handleTap: (String,SCNVector3?) -> Void
    
    
    var cameraController:SCNCameraController{
        return self.view.defaultCameraController
    }
    
    func makeUIView(context: Context) -> SCNView {
        view.frame = .init(x: 0, y: 0, width: self.width, height: self.height)
//        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.enableTapRecognizer(target: context.coordinator,selector: #selector(context.coordinator.onTapHandler(recognizer:)))
        view.enablePanGesture(target: context.coordinator, selector: #selector(context.coordinator.onSwipe(recognizer:)))
        view.enablePinchGesture(target: context.coordinator, selector: #selector(context.coordinator.onPinch(recognizer:)))
        return view
    }

    
    func loadAnnotations(){
        if !self.arViewStates.annotations.isEmpty{
            var annotations:[String:SCNNode] = [:]
            var idx = 1
            self.arViewStates.annotations.sorted(by: { a1, a2 in
                return a1.key < a2.key
            })
            .forEach { (key: String, value: SCNVector3) in
                let plane = self.view.createPlaneNode(location: value, name: key, idx: idx)
                plane.isHidden = self.arViewStates.showFeatures
                annotations[key] = plane
                self.view.createAnnotation(node: plane)
                idx+=1
            }
            DispatchQueue.main.async {
                self.sceneStates.annotationNode = annotations
                self.idx = self.arViewStates.annotations.count + 1
            }
        }
    }
    
    func makeCoordinator() -> SCNSceneView.Coordinator {
         return Coordinator(parent: self) { (name,vector) in
            self.handleTap(name,vector)
        }
    }
    
    func resetSceneView(node:SCNNode){
        
        if self.sceneStates.prevLoc != .zero{
            node.position = .init(0, 0, 0)
            self.sceneStates.prevLoc = .zero
            print("node Position : ",node.position)
        }
        
        if node.scale.x != 1.5 && node.scale.y != 1.5 && node.scale.z != 1.5 && !self.arViewStates.isEditting{
            node.scale = .init(1.5, 1.5, 1.5)
            print("node Scale : ",node.scale)
        }else if self.arViewStates.isEditting && node.scale.x != 1 && node.scale.y != 1 && node.scale.z != 1{
            node.scale = .init(1, 1 , 1)
            print("node Scale : ",node.scale)
        }
    }
    
    func updateInspect(uiView:SCNView){
        if self.arViewStates.showFeatures{
            self.arViewStates.showFeatures = false
        }
//        
        guard let node = uiView.scene?.rootNode else {return}
        self.resetSceneView(node: node)
    }
    
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = self.model{
            uiView.scene = scene
            guard let node = uiView.scene?.rootNode else {return}
            if let sceneNode = node.childNodes.first{
                DispatchQueue.main.async {
                    self.sceneStates.mainSceneNode = sceneNode
                }
            }
        }
        
        if !self.sceneStates.firstLoad && !self.arViewStates.annotations.isEmpty && self.model != nil{
            DispatchQueue.main.async {
                self.sceneStates.firstLoad = true
            }
            self.loadAnnotations()
        }
        
        if self.arViewStates.isEditting{
            self.resetSceneView(node: uiView.scene?.rootNode ?? .init())
        }
        
//        self.resetSceneView(node: uiView.scene?.rootNode ?? .init())
        
        if !self.arViewStates.inspect{
            DispatchQueue.main.async {
                self.updateInspect(uiView: uiView)
            }
        }
        
        if !self.sceneStates.annotationNode.isEmpty{
            self.sceneStates.annotationNode.values.forEach { (node) in
                node.isHidden = !self.arViewStates.showFeatures
            }
        }
        
        if !self.arViewStates.showFeatures{
            self.view.deleteNode(name: "playerNode")
        }
        if self.player != nil && (self.sceneStates.location != nil || self.sceneStates.playerNode != nil ) && !self.sceneStates.addedPlayer{
            context.coordinator.attachPlayer(avplayer: self.player!,node:self.sceneStates.playerNode,location: self.sceneStates.location)
        }
        
    }
    
    class Coordinator{
        var handleTap: (String,SCNVector3?) -> Void
        var parent:SCNSceneView
        init(parent:SCNSceneView,handleTap: @escaping (String,SCNVector3?) -> Void){
            self.handleTap = handleTap
            self.parent = parent
        }
        
        
        var view:SCNView{
            get{
                return self.parent.view
            }
        }
        
        var annotations:[String:SCNVector3]{
            get{
                return self.parent.arViewStates.annotations
            }
            
            set{
                self.parent.arViewStates.annotations = newValue
            }
        }
        
        func isEditting(location:CGPoint){
            if let first = self.view.getClosestNode(location: location){
                let worldCoord = first.worldCoordinates
                self.view.createAnnotation(location: worldCoord, idx: self.parent.idx) { (location, name) in
                    self.parent.idx += 1
                    self.parent.arViewStates.annotations[name] = location
                    self.handleTap(name, location)
                }
            }
        }
        
        func calcLocation(location:SCNVector3) -> (SCNVector3,CGSize){
            let cardWidth:CGFloat = 75
            let cardHeight:CGFloat = 50
            var screenLocation = location
            let factor_x = Float(location.x < 0 ? -1 : 1)
            let factor_y = Float(location.y < 0 ? -1 : 1)
            screenLocation.x += factor_x * (10 + Float(cardWidth) * 0.5 )
            screenLocation.y -= factor_y * (10 + Float(cardHeight) * 0.1)
            screenLocation.z = 10
            return (screenLocation,.init(width: cardWidth, height: cardHeight))
        }
        
        
        func addPlayerScreen(closest:SCNVector3,player:AVPlayer){
            let (screenLocation,size) = self.calcLocation(location:closest)
            self.view.addVideoScreen(screenLocation: screenLocation, card: size, avplayer: player)
        }
        
        func isViewing(location:CGPoint){
            guard let firstNode = self.view.hitTest(location, options: nil).first?.node,let name = firstNode.name,self.annotations.keys.contains(name) else {return}
            print(name)
            self.parent.sceneStates.annotationNode.values.forEach { (node) in
                if node.name != name{
                    node.opacity = 0.5
                }else{
                    node.opacity = 1
                    print("closest \(node.position) : \(String(describing: node.name))")
                }
            }
            self.parent.sceneStates.playerNode = nil
            self.parent.sceneStates.addedPlayer = false
            self.parent.sceneStates.location = firstNode.worldPosition
            self.view.deleteNode(name: "playerNode")
            
            handleTap(name,firstNode.worldPosition)
            
        }
        
        func attachPlayer(avplayer:AVPlayer,node:SCNNode?,location:SCNVector3?){
            if let node = node{
                node.geometry?.firstMaterial?.diffuse.contents = avplayer
            }else if let closest = location{
                let(screenLocation,card) = self.calcLocation(location: closest)
                DispatchQueue.main.async {
                    self.parent.sceneStates.playerNode  = self.view.addVideoScreenFrame(screenLocation: screenLocation, card: card)
                    self.parent.sceneStates.playerNode?.geometry?.firstMaterial?.diffuse.contents = avplayer
                } 
            }
// 
            DispatchQueue.main.async {
                self.parent.sceneStates.addedPlayer = true
            }
            
        }
    
        func removeNode(location:CGPoint){
            guard let vector_loc = self.view.getClosestNode(location: location)?.worldCoordinates else{return}
            self.view.scene?.rootNode.childNodes.forEach({ (node) in
                if node.position == vector_loc{
                    node.removeFromParentNode()
                }
            })
        }
        
        @objc func onTapHandler(recognizer: UITapGestureRecognizer){
            let location = recognizer.location(in: self.view)
            if self.parent.arViewStates.isEditting{
                self.isEditting(location: location)
            }else{
                self.isViewing(location: location)
            }
        }
        
        @objc func onLongPress(recognizer: UILongPressGestureRecognizer){
            let location = recognizer.location(in: self.view)
            self.removeNode(location: location)
            
        }
        
        @objc func onSwipe(recognizer: UIPanGestureRecognizer){
            guard let mainNode = self.view.scene?.rootNode else {return}
            var delta = recognizer.translation(in: self.view)
            let loc = recognizer.location(in: self.view)
            let previousLoc = self.parent.sceneStates.prevLoc
            let cameraLoc = mainNode.position ?? .init(0, 0, 0)
            if recognizer.state == .changed {
                delta = CGPoint.init(x: 2 * (loc.x - previousLoc.x), y: 2 * (loc.y - previousLoc.y))
                mainNode.position = SCNVector3.init(cameraLoc.x + Float(delta.x * 0.25), cameraLoc.y + Float(-delta.y * 0.25), mainNode.position.z)
            }
            self.parent.sceneStates.prevLoc = loc
        }
        
        @objc func onPinch(recognizer: UIPinchGestureRecognizer){
            if !self.parent.arViewStates.inspect{
                return
            }
            guard let node = self.view.scene?.rootNode else {return}
            switch (recognizer.state) {
            case .began:
                break
            case .changed:
                DispatchQueue.main.async {
                    print("recognizer.scale : ",recognizer.scale)
                    let pinchScaleX = Float(recognizer.scale) * node.scale.x
                    let pinchScaleY =  Float(recognizer.scale) * node.scale.y
                    let pinchScaleZ =  Float(recognizer.scale) * node.scale.z
                    
                    node.scale = SCNVector3(x: Float(pinchScaleX), y: Float(pinchScaleY), z: Float(pinchScaleZ))
                    recognizer.scale=1
                }
            default:
                break
            }
        }
        
        
        func findClosestAnnotation(closest:SCNVector3) -> String?{
            var annotations_name:String? = nil
            self.annotations.keys.forEach { (key) in
                if let val = self.annotations[key],val.isEqual(y: closest){
                    annotations_name = key
                }
            }
            return annotations_name
        }
    }
    
}

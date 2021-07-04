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

enum ModelType{
    case model
    case image
}

struct SCNSceneView:UIViewRepresentable{
    
    @EnvironmentObject var arViewStates:ArtViewStates
    var type:ModelType = .model
    @State var showingFeatures:Bool = false
    @Binding var modelImg:UIImage?
    @Binding var model:SCNScene?
    @Binding var idx:Int
    @Binding var player:AVPlayer?
    @StateObject var sceneStates:SceneViewStates = .init()
    
    var width:CGFloat
    var height:CGFloat
    var view:SCNView = .init()
    var handleTap: (String,SCNVector3?) -> Void
    
    
    init(size:CGSize = .init(width: totalWidth, height: totalHeight),type:ModelType = .model,modelImg:Binding<UIImage?> = .constant(nil),model:Binding<SCNScene?> = .constant(nil),idx:Binding<Int> = .constant(0),player:Binding<AVPlayer?> = .constant(nil),taphandler: @escaping ((String,SCNVector3?) -> Void)){
        self.type = type
        self._modelImg = modelImg
        self._model = model
        self._idx = idx
        self._player = player
        self.width = size.width
        self.height = size.height
        self.handleTap = taphandler
    }
    
    
    var cameraController:SCNCameraController{
        return self.view.defaultCameraController
    }
    
    func makeUIView(context: Context) -> SCNView {
        view.frame = .init(x: 0, y: 0, width: self.width, height: self.height)
        view.autoenablesDefaultLighting = true
//        view.allowsCameraControl = true
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
                plane.isHidden = !self.arViewStates.showFeatures
                annotations[key] = plane
                self.view.createAnnotation(node: plane)
                idx+=1
            }
        }
    }
    
    func toggleShowStates(view:SCNView){
//        print(view.scene?.rootNode.childNodes.count ?? -1)
        guard let childnodes = view.scene?.rootNode.childNodes else {return}
        childnodes.forEach { node in
            if node.name!.contains("annotation"){
                node.isHidden = !self.arViewStates.showFeatures
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
//            print("node Position : ",node.position)
        }
        node.scale = .init(1, 1, 1)
//        if node.scale.x != 1.5 && node.scale.y != 1.5 && node.scale.z != 1.5 && !self.arViewStates.isEditting{
//            node.scale = .init(1.5, 1.5, 1.5)
//            print("node Scale : ",node.scale)
//        }else if self.arViewStates.isEditting && node.scale.x != 1 && node.scale.y != 1 && node.scale.z != 1{
//            node.scale = .init(1, 1 , 1)
//            print("node Scale : ",node.scale)
//        }
    }
    
    func updateInspect(uiView:SCNView){
        if self.arViewStates.showFeatures{
            self.arViewStates.showFeatures = false
        }
//
        let _node =  self.type == .model ? uiView.scene?.rootNode : uiView.scene?.rootNode.childNode(withName: "mainNode", recursively: true)
        guard let node = _node else {return}
        self.resetSceneView(node: node)
    }
    
    
    func makeImageNode() -> SCNNode?{
        guard let img = self.modelImg else {return nil}
        let ar = UIImage.aspectRatio(img: img)
        let plane = SCNPlane(width: self.width, height: self.width/ar)
        plane.cornerRadius = 15
        let node = SCNNode(geometry: plane)
        node.name = "mainNode"
        node.geometry?.firstMaterial?.diffuse.contents = img
        return node
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        if let scene = self.model, self.type == .model, !self.sceneStates.firstLoad{
//            print("Calledd ....")
            uiView.scene = scene
            if !self.arViewStates.annotations.isEmpty{
                self.loadAnnotations()
            }
            DispatchQueue.main.async {
                self.sceneStates.firstLoad = true
            }
        }
        
        if let _ = self.modelImg, !self.sceneStates.firstLoad, self.type == .image, let node = self.makeImageNode(){
            if uiView.scene == nil{
                uiView.scene = SCNScene()
            }
            uiView.scene?.rootNode.addChildNode(node)
            DispatchQueue.main.async {
                self.sceneStates.firstLoad = true
            }
        }
        
        
        if self.arViewStates.isEditting{
            self.resetSceneView(node: self.type == .model ? uiView.scene?.rootNode ?? .init() : uiView.scene?.rootNode.childNode(withName: "mainNode", recursively: true) ?? .init())
        }
        
        
        if !self.arViewStates.inspect{
            DispatchQueue.main.async {
                self.updateInspect(uiView: uiView)
            }
        }
        
        if self.arViewStates.showFeatures != self.showingFeatures{
            self.toggleShowStates(view:uiView)
            DispatchQueue.main.async {
                self.showingFeatures = self.arViewStates.showFeatures
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
        
        var childNodes:[SCNNode]{
            guard let childNodes = self.view.scene?.rootNode.childNodes else {return []}
            return childNodes.filter({$0.name?.contains("annotation") ?? false})
        }
        
        var view:SCNView{
            get{
                return self.parent.view
            }
        }
        
        var mainNode:SCNNode?{
            return self.parent.type == .model ? self.view.scene?.rootNode : self.view.scene?.rootNode.childNode(withName: "mainNode", recursively: true)
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
            func helper(location:SCNVector3,name:String){
                self.parent.idx += 1
                self.parent.arViewStates.annotations[name] = location
                self.handleTap(name, location)

            }
            
            if let first = self.view.getClosestNode(location: location),let node = self.mainNode{
                let worldCoord = first.worldCoordinates
                node.createAnnotation(location: worldCoord, idx: self.parent.idx, handler: helper(location:name:))
//                if self.parent.type == .model{
//                    self.view.createAnnotation(location: worldCoord, idx: self.parent.idx, handler: helper(location:name:))
//                }else if self.parent.type == .image{
//                    let node = first.node
//                    node.createAnnotation(location: worldCoord, idx: self.parent.idx, handler: helper(location:name:))
//                }
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
            guard let firstNode = self.view.hitTest(location, options: nil).first?.node,let mainNode = self.mainNode,let name = firstNode.name,self.annotations.keys.contains(name) else {return}
            
            mainNode.childNodes.forEach { node in
                if node.name == "scene"{return}
                if node.name != name{
                    node.opacity = 0.5
                }else{
                    node.opacity = 1
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
            guard let vector_loc = self.view.getClosestNode(location: location)?.worldCoordinates, let node = self.mainNode else{return}
//            self.view.scene?.rootNode.childNodes.forEach({ (node) in
//                if node.position == vector_loc{
//                    node.removeFromParentNode()
//                }
//            })
            node.childNodes.forEach({ (node) in
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
            guard let mainNode = self.mainNode, !self.parent.arViewStates.isEditting else {return}
            var delta = recognizer.translation(in: self.view)
            let loc = recognizer.location(in: self.view)
            let previousLoc = self.parent.sceneStates.prevLoc
            let scale = mainNode.scale
//            print(scale)
            let scale_factor = scale.x > 2 ? scale.x > 4 ? 4 : scale.x : 2
            if recognizer.state == .changed {
                delta = CGPoint.init(x: (loc.x - previousLoc.x), y: (loc.y - previousLoc.y))
                mainNode.position.x += Float(delta.x)/scale_factor
                mainNode.position.y += Float(-delta.y)/scale_factor
            }
            self.parent.sceneStates.prevLoc = loc
        }
        
        @objc func onPinch(recognizer: UIPinchGestureRecognizer){
            if !self.parent.arViewStates.inspect{
                return
            }
//            let _node = self.parent.type == .model ? self.view.scene?.rootNode : self.view.scene?.rootNode.childNode(withName: "mainNode", recursively: true)
            guard let node = self.mainNode else {return}
            switch (recognizer.state) {
            case .began:
                break
            case .changed:
                DispatchQueue.main.async {
//                    print("recognizer.scale : ",recognizer.scale)
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

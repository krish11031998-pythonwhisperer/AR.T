//
//  SCNView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 09/04/2021.
//

import Foundation
import SceneKit
import ARKit
import RealityKit
import SwiftUI
import YouTubePlayer
import XCDYouTubeKit

protocol  SCNViewCommunicator {
    func updateChosenAnnotation(name:String)
}
var idx = 0

struct VectorData:Codable,Hashable,Equatable,Loopable{
    
    static func == (lhs:VectorData,rhs:VectorData) -> Bool{
        return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
    }
    
    func hash(into hasher: inout Hasher) {
        return hasher.combine(self.x)
    }
    
    var x:Float?
    var y:Float?
    var z:Float?
    
    static func parseFromSNCVector(vector:SCNVector3) -> VectorData{
        var vectorData = VectorData()
        vectorData.x = vector.x
        vectorData.y = vector.y
        vectorData.z = vector.z
        print("converted VectorData : \(String(describing: vectorData.x)) \(String(describing: vectorData.y)) \(String(describing: vectorData.z))")
        return vectorData
    }
    
    func parseFromSNCVector(vector:SCNVector3){
        var vectorData = self
        vectorData.x = vector.x
        vectorData.y = vector.y
        vectorData.z = vector.z
    }
}

extension SCNVector3:Equatable{
    
    func findClosestNode(nodes:[SCNVector3]) -> SCNVector3?{
        let target:SCNVector3 = self
        let min:SCNVector3
        let difference = nodes.compactMap { (vector) -> SCNVector3? in
            var res:SCNVector3? = nil
            let diff = vector.difference(y: target)
            if abs(diff.x) < 10 && abs(diff.y) < 10{
                res = vector
            }
            return res
        }
        return difference.first
    }
    
    public static func == (lhs:SCNVector3,rhs:SCNVector3) -> Bool{
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
    
    func difference(y:SCNVector3) -> SCNVector3{
        let x = self
        return .init(x.x - y.x, x.y - y.y, x.z - y.z)
    }
    
    func isEqual(y:SCNVector3) -> Bool{
        let x = self
        return x.x == y.x && x.y == y.y
    }
}


extension SCNView{
        
    func enableTapRecognizer(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let tapRecoginizer = UITapGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(tapRecoginizer)
    }
    
    func enableLongPressRecognizer(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let longTapRecoginizer = UILongPressGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(longTapRecoginizer)
    }
    
    func enablePanGesture(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let panRecoginizer = UIPanGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(panRecoginizer)
    }
    
    func enablePinchGesture(target:Any? = nil,selector:Selector? = nil){
        guard let target = target, let selector = selector else {return}
        let pinchRecoginizer = UIPinchGestureRecognizer(target: target, action: selector)
        self.addGestureRecognizer(pinchRecoginizer)
    }
    
    func getClosestNode(location:CGPoint) -> SCNHitTestResult?{
        return self.hitTest(location).first
    }
    
    func getAllNodes(location:CGPoint) -> [SCNHitTestResult]{
        let res = self.hitTest(location)
        return res
    }
    
        
    func getNodeName(location:CGPoint) -> String?{
        guard let res = self.getClosestNode(location: location)?.node.name else {return nil}
        return  res
    }
    
    
    func deleteNode(name:String){
        let node = self.scene?.rootNode.childNode(withName: name, recursively: true)
        if let node = node{
            node.removeFromParentNode()
        }
    }
    
    func createPlaneNode(location: SCNVector3,name _name:String?=nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil) -> SCNNode{
        let text = SCNText(string: "\(idx)", extrusionDepth: 4)
        text.font = .init(descriptor: .init(name: "Avenir", size: 5), size: 5)
        text.firstMaterial?.diffuse.contents = UIColor.init(.white)
        text.firstMaterial?.specular.contents = UIColor.init(.blue)
        //SCNTextNode
        let textnode = SCNNode(geometry: text)
        let name = _name ?? "annotation-\(idx)"
//        textnode.name = name

        let (min, max) = (text.boundingBox.min, text.boundingBox.max)
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        textnode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
        
//        self.deleteNode(name: name)
        
        let plane = SCNPlane(width: CGFloat(10), height: CGFloat(10))
        plane.cornerRadius = 5
        let planeNode = SCNNode(geometry: plane)
//        planeNode.name = "plane-\(name)"
        planeNode.name = name
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        planeNode.position = location
        planeNode.position.z = 1
//        textnode.eulerAngles = planeNode.eulerAngles
        planeNode.addChildNode(textnode)
        
        
        if let handler = handler{
            handler(location,name)
        }
        return planeNode
    }

    func addVideoScreen(screenLocation:SCNVector3,url:URL? = nil,card:CGSize,avplayer:AVPlayer? = nil){
        var _player:AVPlayer? = nil
        if let avp = avplayer{
            _player = avp
        }else if let url = url{
            _player = .init(url: url)
        }
        
        guard let player = _player else {return}
        
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        
        plane.firstMaterial?.diffuse.contents = player
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
        self.play(nil)
//        player.play()

        self.scene?.rootNode.addChildNode(planeNode)
    }
//    
    func addVideoScreenFrame(screenLocation:SCNVector3,card:CGSize) -> SCNNode{
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
        self.play(nil)
        self.scene?.rootNode.addChildNode(planeNode)
        return planeNode
    }
    
    
    func createTVScreen(location:SCNVector3,local_id:String = "sample",cardSize:CGSize = .init(width: 75, height: 50),handler: ((URL) -> Void)? = nil){
        self.deleteNode(name: "playerNode")
        guard let url = Bundle.main.url(forResource: local_id, withExtension: "mp4") else {return}
        if let handler = handler{
            handler(url)
        }else{
            self.addVideoScreen(screenLocation: location, url: url, card: cardSize)
        }
    }
    
    func addNodeToRootNode(node:SCNNode){
        self.scene?.rootNode.addChildNode(node)
    }
    
    func createAnnotation(location: SCNVector3,name:String? = nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil){
        let planeNode = self.createPlaneNode(location: location, name:name,idx: idx, handler: handler)
        self.scene?.rootNode.addChildNode(planeNode)
        

    }
    func createAnnotation(node:SCNNode? = nil){
        if let node = node{
            self.scene?.rootNode.addChildNode(node)
        }
    }
    
}

extension SCNNode{
    
    func createPlaneNode(location: SCNVector3,name _name:String?=nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil) -> SCNNode{
        let text = SCNText(string: "\(idx)", extrusionDepth: 4)
        text.font = .init(descriptor: .init(name: "Avenir", size: 5), size: 5)
        text.firstMaterial?.diffuse.contents = UIColor.init(.white)
        text.firstMaterial?.specular.contents = UIColor.init(.blue)
        //SCNTextNode
        let textnode = SCNNode(geometry: text)
        let name = _name ?? "annotation-\(idx)"
//        textnode.name = name

        let (min, max) = (text.boundingBox.min, text.boundingBox.max)
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)
        textnode.pivot = SCNMatrix4MakeTranslation(dx, dy, dz)
        
//        self.deleteNode(name: name)
        
        let plane = SCNPlane(width: CGFloat(10), height: CGFloat(10))
        plane.cornerRadius = 5
        let planeNode = SCNNode(geometry: plane)
//        planeNode.name = "plane-\(name)"
        planeNode.name = name
        planeNode.geometry?.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        planeNode.position = location
        planeNode.position.z = 1
//        textnode.eulerAngles = planeNode.eulerAngles
        planeNode.addChildNode(textnode)
        
        
        if let handler = handler{
            handler(location,name)
        }
        return planeNode
    }

    func addVideoScreen(screenLocation:SCNVector3,url:URL? = nil,card:CGSize,avplayer:AVPlayer? = nil){
        var _player:AVPlayer? = nil
        if let avp = avplayer{
            _player = avp
        }else if let url = url{
            _player = .init(url: url)
        }
        
        guard let player = _player else {return}
        
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        
        plane.firstMaterial?.diffuse.contents = player
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
//        self.play(nil)
//        player.play()

        self.addChildNode(planeNode)
    }
//
    func addVideoScreenFrame(screenLocation:SCNVector3,card:CGSize) -> SCNNode{
        let plane = SCNPlane(width: card.width, height: card.height)
        plane.cornerRadius = 5
        plane.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.5)
        
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position = screenLocation
        planeNode.name = "playerNode"
//        self.play(nil)
        self.addChildNode(planeNode)
        return planeNode
    }
    
    
    func createTVScreen(location:SCNVector3,local_id:String = "sample",cardSize:CGSize = .init(width: 75, height: 50),handler: ((URL) -> Void)? = nil){
//        self.deleteNode(name: "playerNode")
        guard let url = Bundle.main.url(forResource: local_id, withExtension: "mp4") else {return}
        if let handler = handler{
            handler(url)
        }else{
            self.addVideoScreen(screenLocation: location, url: url, card: cardSize)
        }
    }
    
    func addNodeToRootNode(node:SCNNode){
        self.addChildNode(node)
    }
    
    func createAnnotation(location: SCNVector3,name:String? = nil,idx:Int,handler: ((SCNVector3,String) -> Void)? = nil){
        let planeNode = self.createPlaneNode(location: location, name:name,idx: idx, handler: handler)
        self.addChildNode(planeNode)
        

    }
    func createAnnotation(node:SCNNode? = nil){
        if let node = node{
            self.addChildNode(node)
        }
    }
}

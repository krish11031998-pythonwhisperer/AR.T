//
//  ArtViewHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/04/2021.
//

import SwiftUI
import SceneKit
class ArtViewStates:ObservableObject{
    @Published var mainTab:Int = 1
    @Published var isEditting:Bool = false
    @Published var annotationHeading:String = ""
    @Published var annotationDetail:String = ""
    @Published var annotationInfos: [String:AnnotationData] = [:]
    @Published var annotations:[String:SCNVector3] = [:]
    @Published var selectedAnnotation:String = ""
    @Published var changes:Bool = false
    @Published var openModal:Bool = false
    @Published var showFeatures:Bool = false
    @Published var annotationVideo:[String:String] = [:]
    @Published var cachedAnnotationVideos:[String:URL] = [:]
    @Published var tappedLocation:SCNVector3? = nil
    @Published var inspect:Bool = false
    
    var infoEmpty:Bool{
        return self.annotations.isEmpty && self.annotationInfos.isEmpty && self.annotationVideo.isEmpty
    }
    
    func updateAnnotations(annotations:[FIRAnnotationData]){
        var infos:[String:AnnotationData] = [:]
        var coords: [String:SCNVector3] = [:]
        var video:[String:String] = [:]
        annotations.forEach { (data) in
            guard let key = data.name, let x = data.x,let y = data.y,let z = data.z, let heading = data.heading, let details = data.detail else {return}
            infos[key] = .init(heading: heading, detail: details)
            coords[key] = .init(x, y, z)
            if let vid = data.vid_url{
                video[key] = vid
            }
        }
        DispatchQueue.main.async {
            self.annotations = coords
            self.annotationInfos = infos
            self.annotationVideo = video
        }
    }
    
    static func updateAnnotations(annotations:[FIRAnnotationData]) -> ([String:AnnotationData],[String:SCNVector3],[String:String]){
        var infos:[String:AnnotationData] = [:]
        var coords: [String:SCNVector3] = [:]
        var video:[String:String] = [:]
        annotations.forEach { (data) in
            guard let key = data.name, let x = data.x,let y = data.y,let z = data.z, let heading = data.heading, let details = data.detail else {return}
            infos[key] = .init(heading: heading, detail: details)
            coords[key] = .init(x, y, z)
            if let vid = data.vid_url{
                video[key] = vid
            }
        }
//        DispatchQueue.main.async {
//            self.annotations = coords
//            self.annotationInfos = infos
//            self.annotationVideo = video
//        }
        return (infos,coords,video)
    }
    
    func resetAnnotationState(){
        self.annotationHeading = ""
        self.annotationDetail = ""
        self.selectedAnnotation = ""
    }
}

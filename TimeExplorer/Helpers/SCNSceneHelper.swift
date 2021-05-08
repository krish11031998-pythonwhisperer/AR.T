//
//  SCNSceneHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/04/2021.
//

import Foundation
import ARKit
import RealityKit


extension SCNScene{
    static func downloadModel(name:String,url:String) -> SCNScene?{
        var finalScene: SCNScene? = nil
        guard let url = URL(string: url) else {return finalScene}
        do{
            try url.download(to: .documentDirectory, filename: name){ (url, error) in
                guard let url = url else{
                    print("There was an error while downloading the model !")
                    if let err = error{
                        print(err.localizedDescription)
                    }
                    return
                }
                do{
                    finalScene = try .init(url: url)
                    print("model is successfully downloaded and loaded to SCNScene!")
                }catch{
                    print("error while loading the model into the SCNScene : \(error)")
                }
            }
        }catch{
            print(error)
        }
        return finalScene
    }
}

class ARModelDownloader:ObservableObject{
    @Published var url:URL? = nil
    
    func loadModel(name:String,url_string:String){
        guard let url = URL(string: url_string) else{return}
        do{
            try url.download(to: .documentDirectory, filename: name, overwrite: false) { (_url, err) in
                guard let final_url = _url else {
                    print(err!.localizedDescription)
                    return
                }
                
                DispatchQueue.main.async {
                    self.url = final_url
                }
            }
        }catch{
            print(error.localizedDescription)
        }
        
    }
    
    
}

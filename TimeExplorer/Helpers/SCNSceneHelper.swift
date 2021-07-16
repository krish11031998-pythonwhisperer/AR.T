//
//  SCNSceneHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/04/2021.
//

import Foundation
import ARKit
import RealityKit
import Combine

protocol URLDictCache{
    subscript(_ url:URL) -> URL? { get set }
}
//
struct ModelURLCache:URLDictCache{

    private let cache:NSCache<NSURL, NSURL> = {
        let cache = NSCache<NSURL,NSURL>()
        return cache
    }()
    
    static var cache = ModelURLCache()

    subscript(url: URL) -> URL? {
        get{
            var res : URL? = nil
            if let url = url as? NSURL{
                res = self.cache.object(forKey: url) as? URL
            }
            return res
        }
        set{
            guard let fin_url = newValue as? NSURL, let _url = url as? NSURL else {return}
            self.cache.setObject(fin_url, forKey: _url)
        }
    }
}

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
    @Published var model:ModelEntity? = nil
    var cancellable = Set<AnyCancellable>()
    
    func parseModelEntity(output: Publishers.SubscribeOn<LoadRequest<ModelEntity>, DispatchQueue>.Output){
        guard let model = output as? ModelEntity else {return}
        self.model = model
    }
    
    
    func loadModel(name:String,url_string:String){
        guard let url = URL(string: url_string) else{return}
        if let modelURL = ModelURLCache.cache[url]{
            DispatchQueue.main.async {
                self.url = modelURL
            }
        }else{
            do{
                try url.download(to: .documentDirectory, filename: name, overwrite: false) { (_url, err) in
                    guard let final_url = _url else {
                        print(err!.localizedDescription)
                        return
                    }
//                    do{
//                        let model = try ModelEntity.loadModel(contentsOf: final_url)
//                        DispatchQueue.main.async {
//                            self.model = model
//                        }
//                    }catch{
                        DispatchQueue.main.async {
                            self.url = final_url
                        }
//                    }
                    
//                    ModelEntity.loadModel(named: <#T##String#>)
//                    ModelEntity.loadModelAsync(contentsOf: final_url)
//                        .subscribe(on: DispatchQueue.global(qos: .userInteractive))
//                        .receive(on: DispatchQueue.main)
//                        .sink(receiveCompletion: { _ in}, receiveValue: self.parseModelEntity(output:))
//                        .store(in: &self.cancellable)
//                    DispatchQueue.main.async {
//                        self.model = model
//                    }

//
                }
            }catch{
                print(error.localizedDescription)
            }
        }
        
        
    }
    
    
}

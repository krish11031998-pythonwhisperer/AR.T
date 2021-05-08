//
//  FireBaseStorageHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/27/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FIRStorageManager:NSObject{
    
    static var shared:FIRStorageManager = FIRStorageManager()
    
    func uploadTask(data:Data,path:String,handler:@escaping (String) -> Void){
        let storageRef = Storage.storage().reference()
        var Ref = storageRef.child(path)
        var _url:String = ""
        let task = Ref.putData(data, metadata: nil) { (meta, err) in
            guard let metadata = meta else{
                handler(_url)
                return
            }
            
            let size = metadata.size
            Ref.downloadURL { (url, err) in
                guard let url = url else{
                    if err != nil{
                        print("There was an error ! : \(err!.localizedDescription)")
                    }
                    handler(_url)
                    return
                }
                _url = url.absoluteString
                print("_url : \(_url)")
                handler(_url)
            }
        }
    }
}

class FirebaseAPIHelper{
    static func parseData(q:QueryDocumentSnapshot,_ type:String) -> Any?{
        var res:Any? = nil
        do{
            let data = try q.data()
            let json = try JSONSerialization.data(withJSONObject: data)
            let decoder = JSONDecoder()
//            decoder.keyDecodingStrategy = .convertFromSnakeCase
            if type == "User"{
                res = try decoder.decode(User.self, from: json)
            }else if type == "Post"{
                res = try decoder.decode(PostData.self, from: json)
            }
            
        }catch{
            print("There was an error ! : \(error)")
        }
        return res
    }
}

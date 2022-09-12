//
//  FireStoreAPI.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/16/20.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import SwiftUI
import AVFoundation

class UserAPI{
    
    @EnvironmentObject var mainStates:AppStates
    
    static var shared:UserAPI = UserAPI()
    static var Cache:[String:User] = [:]
    func parseUser(_ data:QueryDocumentSnapshot) -> User?{
        var res:User? = nil
        do{
            res = try data.data(as: User.self)
        }catch{
            print("ERROR MESSAGE : There was an error while trying to parse the UserData : \(error)")
        }
        return res
    }
    
    func getUser(_ id:String,handler: @escaping (User?) -> Void){
        if UserAPI.Cache.keys.contains(id){
            handler(UserAPI.Cache[id])
        }else{
            let db = Firestore.firestore()
            db.collection("users")
                .whereField("emailID", isEqualTo: id)
                .addSnapshotListener { (qs, err) in
                    guard let safeQS = qs else {
                        if err != nil{
                            print("Error : \(err!.localizedDescription)")
                        }
                        return
                    }
                    
                    if let user_data = safeQS.documents.first, let user = UserAPI.shared.parseUser(user_data){
                        print("id: \(id)")
                        UserAPI.Cache[id] = user
                        handler(user)
                    }else{
                        handler(nil)
                    }
                }
        }
    }
    
    func addUser(user:User){
        let db = Firestore.firestore()
        do{
            let _ = try db.collection("users").addDocument(from: user)
        }catch{
            print("There was an error (addUser)! \(error.localizedDescription)")
        }
        
    }
    
    func addPhotos(data:Data, path:String, handler:@escaping (String) -> Void){
        FIRStorageManager.shared.uploadTask(data: data, path: path) { (url) in
            handler(url)
        }
    }
    
    func updateUserDetails(user:User,prev_user:User,completion: (() -> Void)? = nil){
        
        func userDict(u:User) -> [String:Any]?{
            var res:[String:Any]? = nil
            do{
                res = try u.allKeysValues(obj: nil)
            }catch{
                print("There was an error!,\(error)")
            }
            return res
        }
        
        let db = Firestore.firestore()
        if let id = user.id{
            var updateDict:[String:Any] = [:]
            if let u_dict = userDict(u: user), let pu_dict = userDict(u: prev_user){
                let keys = Array(u_dict.keys)
                keys.forEach { (key) in
                    if let u_val = u_dict[key] as? String{
                        let pu_val = pu_dict[key] as? String
                        if (pu_val != nil && pu_val! != u_val) || pu_val == nil{
                            updateDict[key] = u_val
                        }
                    }
                }
            }
            if let post = user.posts{
                let pu_posts = prev_user.posts
                if pu_posts == nil || (pu_posts != nil && pu_posts! != post){
                    updateDict["posts"] = post
                }
            }
            print("updateDict : \(updateDict)")
            db.collection("users").document(id).updateData(updateDict)
            if completion != nil{
                completion!()
            }
        }
        
    }
}

class FirebaseAPI{
    
    var collectionName:String
    var dispatchGroup = DispatchGroup()
    init(collectionName:String){
        self.collectionName = collectionName
    }
    
    static var firebase_shared:FirebaseAPI = .init(collectionName: "")
    
    func uploadImage(image:UIImage,folder:String,completion: @escaping (String?) -> Void){
        var final_url:String = ""
        if let safeData = image.pngData(){
            var path = "\(folder)/\(NSUUID().uuidString).jpg"
            FIRStorageManager.shared.uploadTask(data: safeData, path: path) { (url) in
                completion(url)
            }
        }
    }
    
    func uploadVideo(videoURL:URL,folder:String,completion:@escaping (String?) -> Void){
        var final_url:URL = .init(fileURLWithPath: "")
        var dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        AVAsset.convertVideoToMP4(toConvertURL: videoURL) { (url) in
            if let url = url{
                final_url = url
            }
            dispatchGroup.leave()
        }
        
        
        dispatchGroup.notify(queue: .main, work: .init(block: {
            guard let videoData = NSData(contentsOf: final_url) as Data?, let name = final_url.absoluteString.components(separatedBy: "/").last else {
                print("Couldnt read the MP4 Video!")
                completion(nil)
                return
            }
            FIRStorageManager.shared.uploadTask(data: videoData, path: "\(folder)/\(name)") { (url) in
                url != "" ? completion(url) : completion(nil)
            }
        }))
    }
  
    func uploadImages(images:[UIImage],folder:String = "postImages",completion: @escaping ([String]) -> Void){
        var url_links = [String]()
        images.enumerated().forEach { (img) in
            self.uploadImage(image: img.element,folder:folder) { (url) in
                if let url = url{
                    url_links.append(url)
                }
                if img.offset == images.count - 1{
                    completion(url_links)
                }
            }
            
        }
    }
    
    
    func paginationQuery(user:String,lastDoc:QueryDocumentSnapshot? = nil,completion : @escaping ((QuerySnapshot?,Error?) -> Void)){
        let db = Firestore.firestore()
		var query: Query = db.collection(self.collectionName)
								.whereField("user", isEqualTo: user)
								.order(by: "date",descending: true)
								.limit(to: 10)
        if let lastDoc = lastDoc{
			query = query
				.start(afterDocument: lastDoc)
        }
		
		query.addSnapshotListener(completion)
    }
    
    
    
    func getTopItems(limit:Int = 4,collectionName:String? = nil,completion: @escaping ((QuerySnapshot?,Error?) -> Void)){
        let db = Firestore.firestore()
        let collectionName = collectionName ?? self.collectionName
		var query: Query = db.collection(collectionName)
							 .order(by: "date",descending: true)
			
		if limit > 0 {
			query = query.limit(to:limit)
        }
	
		query.addSnapshotListener(completion)
    }
    
    func updateDocument(_ id:String, _ data:[String:Any]){
        Firestore.firestore().collection(self.collectionName).document(id).updateData(data) { (err) in
            if let err = err{
                print("There was an error : \(err.localizedDescription)")
                return
            }
            print("Updated post !")
        }
    }
    
}

class FirebaseArtAPI:FirebaseAPI,ObservableObject{
    
    @Published var arts:[ArtData] = []
    @EnvironmentObject var mainStates:AppStates
    @Published var lastDoc:QueryDocumentSnapshot? = nil
    var artSet:Set<ArtData> = .init()
    
    static var shared:FirebaseArtAPI = .init()
    
    init(){
        super.init(collectionName: "paintings")
    }
    
    func updateArts(sad:[ArtData]){
        var newArts:[ArtData] = []
        sad.forEach { (data) in
            if !self.artSet.contains(data){
                newArts.append(data)
                self.artSet.insert(data)
            }
        }
        DispatchQueue.main.async {
            if self.arts.isEmpty{
                self.arts = newArts
            }else{
                self.arts.append(contentsOf: newArts)
            }
        }
    }
    
    func updateArt(_ artData:ArtData){
        let onlyKeys = ["annotations"]
        guard let id = artData.id else {return}
        do{
            var data = try artData.allKeysValues(obj: nil)
            data = data.filter({onlyKeys.contains($0.key)})
            print(data)
            self.updateDocument(id, data)
        }catch{
            print("There was an error (updatePost)! \(error.localizedDescription)")
        }
    }
    
    func parseQueryDocuments(q:QuerySnapshot) -> [ArtData]?{
        print("q.documents : ",q.documents)
        let data = q.documents.compactMap({ (qds) -> ArtData? in
            var res:ArtData? = nil
            do{
                res = try qds.data(as: ArtData.self)
            }catch{
                print("Error whle decoding ArtData : \(error)")
            }
            return res
        })
        return data
    }
    
    func getArts(_name:String? = nil){
        self.getTopItems(limit: 10, collectionName: "paintings") { qs, err in
            guard let q = qs, let last = qs?.documents.last else {return}
            self.lastDoc = last
            
            if let safeArtData = self.parseQueryDocuments(q: q){
                self.updateArts(sad: safeArtData)
            }
        }
    }
    
    
}

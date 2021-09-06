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
        if let lastDoc = lastDoc{
            db.collection(self.collectionName)
                .whereField("user", isEqualTo: user)
                .order(by: "date",descending: true)
                .start(afterDocument: lastDoc)
                .limit(to: 10)
                .addSnapshotListener(completion)
        }else{
            db.collection(self.collectionName)
                .whereField("user", isEqualTo: user)
                .order(by: "date",descending: true)
                .limit(to: 10)
                .addSnapshotListener(completion)
        }
    }
    
    
    
    func getTopItems(limit:Int = 4,collectionName:String? = nil,completion: @escaping ((QuerySnapshot?,Error?) -> Void)){
        let db = Firestore.firestore()
        let collectionName = collectionName ?? self.collectionName
        if limit < 0{
            db.collection(collectionName)
                .order(by: "date",descending: true)
                .addSnapshotListener(completion)
            
        }else{
            db.collection(collectionName)
                .limit(to:limit)
                .order(by: "date",descending: true)
                .addSnapshotListener(completion)
        }
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

class PostAPI:FirebaseAPI,ObservableObject{
    @Published var posts:[PostData] = []
    @EnvironmentObject var mainStates:AppStates
    @Published var lastDoc:QueryDocumentSnapshot? = nil
    var loadedPosts:[String] = []
    
    init(){
        super.init(collectionName: "posts")
    }
    
    static var shared:PostAPI = .init()
    
    func newVideoPost(videoURL:URL,caption:String,username:String){
        var videoURLs:[String] = []
        var imgURLs:[String] = []
        self.uploadVideo(videoURL: videoURL, folder: "videos") { (url) in
            if let url = url{
                videoURLs = [url]
                UIImage.thumbnailImage(videoURL: videoURL) { (img) in
                    guard let img = img else {return}
                    self.uploadImage(image: img, folder: "thumbnailsImages") { (url) in
                        guard let img_url = url else {return}
                        imgURLs = [img_url]
                        self.addPost(post: .init(image: imgURLs,video: videoURLs , caption: caption, user: username, date: Date(), likes: 0,isVideo: true)) { (id) in
                            //                            if id != nil{
                            do {
                                try FileManager.default.removeItem(at: videoURL)
                            }catch{
                                print("There was an error while removing the video at videoURL: \(error)!")
                            }
                            
                            //                            }
                        }
                    }
                }
            }else{
                print("Video Upload was not a SUCCESS!")
            }
        }
    }
    
    func newImagePost(images:[UIImage],caption:String,username:String){
        self.uploadImages(images: images) { (urls) in
            let newPost = PostData(image: urls, caption: caption, user: username, date: Date(), isVideo: false)
            self.addPost(post: newPost)
        }
    }
    
    
    func addPost(post:PostData,handler:((_ doc:String) -> Void)? = nil){
        let db = Firestore.firestore()
        do{
            let doc = try db.collection("posts").addDocument(from: post, completion: { (err) in
                if let err = err{
                    print("There was an error (from addDocument completion handler) ! : \(err)")
                }
            })
            if handler != nil{
                handler!(doc.documentID)
            }
        }catch{
            print("There was an error (addPost)! \(error.localizedDescription)")
        }
    }
    
    func updatePost(_ post:PostData){
        var onlyKeys = ["likes","comments"]
        guard let id = post.id else {return}
        do{
            var data = try post.allKeysValues(obj: nil)
            data = data.filter({onlyKeys.contains($0.key)})
            print(data)
            self.updateDocument(id, data)
        }catch{
            print("There was an error (updatePost)! \(error.localizedDescription)")
        }
    }

    func parseQueryDocuments(q:QuerySnapshot) -> [PostData]?{

        var posts = q.documents.compactMap { (qds) -> PostData? in
            var res:PostData? = nil
            do{
                res = try qds.data(as: PostData.self)
            }catch{
                print("There was an error! : \(error.localizedDescription)")
            }
//            res = FirebaseAPIHelper.parseData(q: qds, "PostData") as? PostData
            return res
        }
        return posts
    }
        
    
    func processPosts(_ query:QuerySnapshot?,_ error:Error?){
        guard let q = query,let lastDoc = q.documents.last else {
            print("There was an error (processPost)!")
            print("error : \(error?.localizedDescription ?? "")")
            return
        }
        
        self.lastDoc = lastDoc
        
        if let posts = self.parseQueryDocuments(q: q){
//            let parsedPosts
            let newPosts = self.posts.isEmpty ? posts : posts.filter({$0.id != nil ? !self.loadedPosts.contains($0.id!) : false})
            self.loadedPosts.append(contentsOf: newPosts.compactMap({$0.id}))
            DispatchQueue.main.async {
                self.posts = newPosts
                print("Length of the posts : \(self.posts.count)")
            }
        }
    }
    
    func getTopPosts(limit:Int = 4){
        self.getTopItems(limit: limit, completion: processPosts)
    }
    
    func getPosts(user:String){
        self.paginationQuery(user:user,lastDoc: self.lastDoc, completion: processPosts)
    }

}

class BlogAPI:FirebaseAPI,ObservableObject{
    @Published var blogs:[BlogData] = []
    @EnvironmentObject var mainStates:AppStates
    @Published var lastBlog:QueryDocumentSnapshot? = nil
    var loadedBlogs:[String] = []
    
    init(){
        super.init(collectionName: "blogs")
    }
    
    static var shared:BlogAPI = .init()
    
    func parseQueryDocuments(q:QuerySnapshot) -> [BlogData]?{

        var posts = q.documents.compactMap { (qds) -> BlogData? in
            var res:BlogData? = nil
            do{
                res = try qds.data(as: BlogData.self)
            }catch{
                print("There was an error! : \(error.localizedDescription)")
            }
            return res
        }
        return posts
    }
    
    func newBlog(_ images:[UIImage],title:String,summary:String,article:String,user:String,location:String = "Dubai",handler:((Bool) -> Void)? = nil){
        self.uploadImages(images: images,folder: "blogImages") { (urls) in
            var newBlog = BlogData(image: urls, headline: title, articleText: article, summaryText: summary, user: user, date: Date(), location: location)
            self.addNewBlog(newBlog,handler: handler)
        }
    }
    
    func addNewBlog(_ blog:BlogData,handler:((Bool) -> Void)? = nil){
        let db = Firestore.firestore()
        do{
            let res = try db.collection("blogs").addDocument(from: blog,completion: { (err) in
                if let err = err{
                    print("There was an error (addNewBlog)! : \(err)")
                }
            })
            print("Blog with id : \(res.documentID)")
            if handler != nil{
                handler!(true)
            }
        }catch{
            print("There was an error (addNewBlog)2 ! : \(error.localizedDescription)")
            if handler != nil{
                handler!(false)
            }
        }
    }
    
    
    func processBlogs(_ q:QuerySnapshot?,_ error:Error?){
        guard let q = q else{
            if let err = error{
                print("There was an error while processes the blogs! : \(err)")
            }
            return
        }
        self.lastBlog = q.documents.last
        
        if let SPR = self.parseQueryDocuments(q: q){
            DispatchQueue.main.async {
                if self.blogs.isEmpty{
                    self.blogs = SPR
                    self.loadedBlogs = SPR.compactMap({$0.id})
                }else{
                    var newBlogs = SPR.filter({$0.id != nil ? !self.loadedBlogs.contains($0.id!) : false})
                    if !newBlogs.isEmpty{
                        self.blogs.append(contentsOf: newBlogs)
                        self.loadedBlogs.append(contentsOf: newBlogs.compactMap({$0.id}))
                    }
                    
                }
            }
        }
        
    }

    func getTopBlogs(limit:Int = 4){
        self.getTopItems(limit: limit, completion: processBlogs)
    }
    
    func getBlogs(user:String){
        self.paginationQuery(user:user, lastDoc: self.lastBlog, completion: processBlogs)
    }
//
    
}

class MessageAPI:FirebaseAPI,ObservableObject{
    
    var currentUser:String?
    let collection:String = "messages"
    @Published var messages:[MessageData] = []
    @Published var userMessages:[String:[MessageData]] = [:]
    @Published var allUsers:[User] = []
    
    static var shared:MessageAPI = MessageAPI()
    
    init(){
        super.init(collectionName: "messages")
//        self.currentUser = user
    }
    
    func getRecentMessages(_ user:String? = nil){
        if user != nil{
            self.currentUser = user
        }
        let db = Firestore.firestore()
        db.collection(self.collection)
//            .whereField("receiver", isEqualTo: self.currentUser)
//            .whereField("sender", isEqualTo:self.currentUser)
            .order(by: "date",descending: false)
            .addSnapshotListener { (snapshot, err) in
                guard let snapshot = snapshot else {
                    print("There was an error (getRecentMessage)!")
                    if let err = err{
                        print("\(err.localizedDescription)")
                    }
                    return
                }
                
                guard let parsedMessages = self.parseMessages(messages: snapshot.documents) else {
                    print("ERROR MESSAGE : Error while parsing the message into the messageData container")
                    return
                }
                
                var uniqueMessages:[String:[MessageData]] = [:]
                parsedMessages.forEach { (message) in
                    guard let sender = message.sender, let receiver = message.receiver else {return}
                    var other_user = sender == self.currentUser ? receiver : sender
                    if uniqueMessages.keys.contains(other_user){
                        uniqueMessages[other_user]?.append(message)
                    }else{
                        uniqueMessages[other_user] = [message]
                    }
                }
                print(uniqueMessages.keys)
                DispatchQueue.main.async {
                    if parsedMessages.count > 0{
                        self.messages = parsedMessages
                        self.userMessages = uniqueMessages
                    }
                }
            }
    }
    
    
    func getMessageUsers(_ users_ids:[String]){
        let db = Firestore.firestore()
        db.collection("user")
            .whereField("emailID", in: users_ids)
            .addSnapshotListener { (qs, err) in
                guard let safeqs = qs else {return}
                let _users = safeqs.documents.compactMap { (qs) -> User? in
                    guard let user = UserAPI.shared.parseUser(qs) else {return nil}
                    UserAPI.Cache[user.emailID!] = user
                    return user
                }
                if _users.count > 0{
                    DispatchQueue.main.async {
                        self.allUsers = _users
                    }
                }
            }

    }
    
    func parseMessages(messages:[QueryDocumentSnapshot]) -> [MessageData]?{
        return messages.compactMap { (qds) -> MessageData? in
            var res:MessageData?
            do{
                res = try qds.data(as: MessageData.self)
            }catch{
                print("ERROR MESSAGE : There was an error while trying to the parse the messages : \(error.localizedDescription)")
            }
            return res
        }
        
    }
    
    func sendMessage(_ newMessage:MessageData){
        let db = Firestore.firestore()
        
        do{
            let _ = try db.collection(self.collection).addDocument(from: newMessage, completion: { (err) in
                print("ERROR MESSAGE : Error while sending a message")
                if let err = err{
                    print("There was an error: \(err.localizedDescription)")
                }
                
            })
        }catch{
            print("ERROR MESSAGE : Error while sending a message : \(error.localizedDescription)")
        }
    }
    
}

class TourAPI:FirebaseAPI,ObservableObject{
    @Published var tours:[TourData] = []
    
    init() {
        super.init(collectionName: "tours")
    }
    
    static var shared:TourAPI = .init()
    
    func parseTours(qs:QuerySnapshot) -> [TourData]{
        return qs.documents.compactMap({self.parseTour($0)})
    }
    
    func getTours(){
        self.getTopItems(limit: 10) { (qs, err) in
            guard let safeQS = qs else {
                print("DEBUG ERROR : Error while attempting to fetch Tours")
                if let err = err{
                    print("ERROR MESSAGE : \(err.localizedDescription)")
                }
                return
            }
            
            let tours = self.parseTours(qs:safeQS)
            
            DispatchQueue.main.async {
                if !tours.isEmpty{
                    self.tours = tours
                }
            }
            
        }
    }
    
    func parseTour(_ qs:QueryDocumentSnapshot) -> TourData?{
        var res:TourData? = nil
        do{
            res = try qs.data(as: TourData.self)
        }catch{
            print("DEBUG ERROR : Error while attempting to parse the Tour Data \n\(error.localizedDescription)")
        }
        return res
    }
    
}


class ArtAPI:FirebaseAPI,ObservableObject{
    
    @Published var arts:[ArtData] = []
    @EnvironmentObject var mainStates:AppStates
    @Published var lastDoc:QueryDocumentSnapshot? = nil
    var artSet:Set<ArtData> = .init()
    
    static var shared:ArtAPI = .init()
    
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
        self.getTopItems(limit:10,collectionName: "paintings") { qs, err in
            guard let q = qs, let last = qs?.documents.last else {return}
            self.lastDoc = last
            
            if let safeArtData = self.parseQueryDocuments(q: q){
                self.updateArts(sad: safeArtData)
            }
        }
    }
    
    
}

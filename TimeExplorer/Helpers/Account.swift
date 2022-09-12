//
//  User.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/16/20.
//

import SwiftUI
import Firebase
class Account:ObservableObject{
    //    @EnvironmentObject var mainStates:AppStates
    @Published var user:User = .init()
    @Published var prev_user:User = .init()
//    @Published var username:String = ""
    @Published var userID:String = ""
    @Published var error:String = ""
    @Published var loggedIn:Bool = false
    var UAPI:UserAPI = .init()
//    var PAPI:PostAPI = .init()

    
    var username:String{
        get{
            return self.user.username ?? ""
        }
    }
    
    
    func autoLogIn(_ handler: @escaping (Bool) -> Void){
        var id = UserDefaults.standard.object(forKey: "eID")
        if let state = UserDefaults.standard.object(forKey: "isLoggedIn") as? Bool, state, id != nil, let safeID = id as? String{
            print("safeID : \(safeID)")
            self.UAPI.getUser(safeID){ user in
                if let safeUser = user{
                    self.user = safeUser
                    self.prev_user = safeUser
                    print("USER DETAILS : \(safeUser)")
                    handler(true)
                }else{
                    handler(false)
                }
            }
        }else{
            handler(false)
        }
    }
    
    func login(_ email:String,_ pwd:String,_ handler: @escaping (Bool) -> Void){
        if email != "" && pwd != ""{
            Auth.auth().signIn(withEmail: email, password: pwd) { (res, err) in
                if err != nil{
                    print("There was an error !")
                    self.error = err!.localizedDescription
                    print("err: \(err!.localizedDescription)")
                    handler(false)
                    return
                }
                if let id = res?.user.uid{
                    self.UAPI.getUser(email){ user in
                        if let safeUser = user{
                            self.user = safeUser
                            self.loggedIn = true
                        }
                    }
                    UserDefaults.standard.setValue(email, forKey: "eID")
                    UserDefaults.standard.setValue(true, forKey: "isLoggedIn")
                    handler(true)
                }
                
            }
        }else{
            self.error = "Enter Valid Email and Password"
            handler(false)
        }
    }
    
    
    func register(_ username:String, _ email:String, _ pwd:String, _ handler: @escaping (Bool) -> Void){
        guard email != "" , pwd != "" else {self.error = "Enter valid email ID or Password";return }
        var status:Bool = false
        Auth.auth().createUser(withEmail: email, password: pwd) { (res, err) in
            if err != nil {
                print("There was an error !")
                self.error = err!.localizedDescription
                handler(false)
                return
            }
            print("The user was register! logged in!")
            if let id = res?.user.uid{
                self.UAPI.addUser(user: .init(id:id,username: username, emailID: email))
                handler(true)
            }
            
        }
    }
    
    func updateProfile(image:Data?){
        if let safeImage = image{
            let imgName =  self.user.id ?? "testImage"
            let path = "profileImages/\(imgName).jpg"
            UAPI.addPhotos(data: safeImage, path:path){ url in
                print("Received URL: \(url)")
                let u_url = self.user.photoURL ?? ""
                if u_url != url{
                    self.user.photoURL = url
                    print("Updated the user photoURL: \(self.user.photoURL!)")
                    self.updateUserDetails()
                }
            }

        }else{
            self.updateUserDetails()
        }
    }
    
    func updateUserDetails(handler: (() -> Void)? = nil){
        UAPI.updateUserDetails(user: self.user,prev_user: self.prev_user,completion: handler)
    }
    
    //func addImagePosts(images:[UIImage] = [],caption:String = "", handler: @escaping (() -> Void)){
      //  self.PAPI.newImagePost(images: images, caption: caption,username: self.user.username ?? "")
//        {doc in
//            if self.user.posts == nil{
//                self.user.posts = [doc]
//            }else{
//                self.user.posts?.append(doc)
//            }
//            print("user Post Dic: \(self.user.posts ?? [])")
//            self.updateUserDetails(handler: handler)
//        }
    //}
    
//    func addVideoPosts(videoURL:URL,caption:String = "", handler: @escaping (() -> Void)){
//        self.PAPI.newVideoPost(videoURL: videoURL, caption: caption, username: self.user.username ?? "")
//    }
}

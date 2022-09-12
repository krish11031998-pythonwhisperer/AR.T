//
//  UVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/16/20.
//

import SwiftUI

struct UVMain: View {
    @EnvironmentObject var mainStates:AppStates
    @StateObject var IMD:ImageDownloader = .init()
    @State var editForm:Bool = false
    @State var finishedEditting:Bool = false
    @State var imagePicker:Bool = false
    @State var selectedPost:PostData = .init(id: "0",image:[],caption:"")
    @State var showPost:Bool = false
    @State var selectedImage:UIImage = .stockImage
    @Namespace var animation
    var currentUser:User{
        get{
            return self.mainStates.userAcc.user
        }
    }
    
    func mainImg() -> UIImage{
        if let url = self.mainStates.userAcc.user.photoURL, url != self.IMD.url{
            self.IMD.getImage(url: url)
        }
        return self.IMD.image ?? .stockImage
    }
    
    var trailingNVButton: some View{
        Group{
            if self.imagePicker{
                Button(action:{
                    self.imagePicker.toggle()
                },label:{
                    MainText(content: "Done", fontSize: 15,color: .white)
                        .padding(.bottom)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
                })
            }else{
                self.editButton
            }
        }.padding(.vertical)
        
    }
    
    var editButton:some View{
        Image(systemName: "pencil")
            .resizable()
            .frame(width: 10, height: 10, alignment: .center)
            .foregroundColor(.white)
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
            .onTapGesture(count: 1, perform: {
                self.editForm.toggle()
                print("editForm : ",self.editForm)
            })
    }
    
    var imgURL:String{
        get{
            return self.currentUser.photoURL ?? ""
        }
    }
    
    var mainBody:some View{
        ScrollView(showsIndicators: false){
            UserViewHeader(user: self.mainStates.userAcc.user, image: mainImg(), editForm: self.$editForm)
            Spacer().frame(height:75)
            UVPosts(selectedPost: self.$selectedPost,showPost:self.$showPost,selectedImage:self.$selectedImage,animation:self.animation)
            Spacer().frame(height: 150)
            
        }.edgesIgnoringSafeArea(.vertical)
        .onAppear(perform: {
            self.IMD.getImage(url: self.currentUser.photoURL ?? "")
        })
        .onChange(of: self.imgURL) { (value) in
            self.IMD.getImage(url: self.imgURL)
        }
        .onReceive(self.IMD.$image) { (img) in
            self.mainStates.loading = false
        }
        
    }
    
    func updateAfterEdit(_ latestImage:UIImage?,_ user:User){
        if let img = latestImage{
            self.IMD.image = img
        }
        self.updateUser(user, latestImage)
        self.mainStates.showTab = true
        
    }
    
    func updateUser(_ user:User, _ latestImage:UIImage?){
        print("Updating the userDetails!")
        self.mainStates.userAcc.prev_user = self.currentUser
        self.mainStates.userAcc.user.username = user.username
        self.mainStates.userAcc.user.firstName = user.firstName
        self.mainStates.userAcc.user.lastName = user.lastName
        print(self.mainStates.userAcc.user)
        self.mainStates.userAcc.updateProfile(image: latestImage?.pngData())
    }
    
    
    var v2:some View{
            ZStack{
                self.mainBody
                NavigationLink(
                    destination: EditForm(currentUser: self.mainStates.userAcc.user, editForm: self.$editForm, img: self.IMD.image ?? .stockImage,imagePicker: self.$imagePicker){(latestImage,user) in
                        self.updateAfterEdit(latestImage, user)
                    },
                    isActive: self.$editForm,
                    label: {
                        Text("")
                    }).hidden()
                if self.showPost{
                    UVDetail(profilePic: .stockImage, userName: "krish_venkat11", post: self.selectedPost, showPost: self.$showPost)
                        .matchedGeometryEffect(id: self.selectedPost.id, in: self.animation)
                        .background(Color.white)
                }
        }.edgesIgnoringSafeArea(.all)
        .onChange(of: self.imagePicker, perform: { value in
            self.mainStates.showTab = !value
        })
        .onChange(of: self.showPost, perform: { value in
            if !self.mainStates.showTab{
                self.mainStates.showTab = true
            }
        })
        
    }
    
    var body:some View{
            self.v2
            
        
    }
}


struct EditForm:View{
    var currentUser:User
    @Binding var editForm:Bool
    @State var u_name:String = ""
    @State var f_name:String = ""
    @State var l_name:String = ""
    @State var img:UIImage
    @Binding var imagePicker:Bool
    @State var imagePicked:UIImage?
    @State var actionSheet:Bool = false
    @State var selectedImages:[IDImage] = []
    var updateUser : (UIImage?,User) -> Void
    
    func loadImage(){
        if let safeIP = self.imagePicked{
            print("Updated self.img!")
            self.img = safeIP
            //            self.updateImage(safeIP)
        }
    } 
    //    @Environment (\.presentationMode) var presentationMode
    func textField(_ placeholder:String, _ S:Binding<String>,pass:Bool = false) -> some View{
        return Group{
            if pass{
                SecureField(placeholder, text: S)
            }else{
                TextField(placeholder, text: S)
            }
        }.foregroundColor(.black)
        .frame(width:AppWidth - 100)
        .padding()
        .background(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.gray, lineWidth: 2))
        
    }
    
    var form:some View{
        VStack(alignment: .center){
            Image(uiImage: self.img)
                .resizable()
                .aspectRatio(UIImage.aspectRatio(img: self.img), contentMode: .fill)
                .frame(width: 150,height:150, alignment: .center)
                .clipShape(Circle())
                .onTapGesture(perform: {
                    self.actionSheet.toggle()
                })
                .padding(.vertical,25)
            self.textField("First Name", self.$f_name)
            self.textField("Last Name", self.$l_name)
            self.textField("UserName", self.$u_name)
            MainText(content: "Save", fontSize: 20,color: .white)
                .padding()
                .background(RoundedRectangle(cornerRadius: 25.0).fill(Color.red))
                .onTapGesture(count: 1, perform: {
                    //                    self.updateUser()
                    self.updateUser(self.imagePicked,User(id: self.currentUser.id, firstName: self.f_name, lastName: self.l_name, username: self.u_name, emailID: self.currentUser.emailID, photoURL: self.currentUser.photoURL, friends: self.currentUser.friends, followers: self.currentUser.followers, postsCount: self.currentUser.postsCount, following: self.currentUser.following))
                    self.editForm.toggle()
                })
        }
    }
    
    func updateImages(){
        if let safeImage = self.selectedImages.first?.image{
            self.imagePicked = safeImage
            self.loadImage()
        }
    }
    
    var doneButton:some View{
//        HStack {
//            Spacer()
            Button(action: {
                self.imagePicker.toggle()
                print("self.imagePicker : ",self.imagePicker)
                self.updateImages()
            }, label: {
                MainText(content: "Done", fontSize: 10,color:.white)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
            }).padding()
//        }.padding()
    }
    
    var pickerView:some View{
        VStack {
//            InstaImagePicker(.single,self.$imagePicker,selectedImages: self.$selectedImages){
//                print("Done")
//            }
        }.frame(width: totalWidth, alignment: .center)
        .animation(.spring())
        .background(Color.mainBG)
        .navigationBarItems(trailing: self.doneButton)
    }
    
    var body: some View{
        ZStack {
            VStack(alignment:.center)
            {
                Spacer().frame(height:75)
                self.form
                Spacer()
            }
            .animation(.spring())
            .edgesIgnoringSafeArea(.all)
            .frame(width:totalWidth,height:totalHeight)
            .actionSheet(isPresented: self.$actionSheet, content: { () -> ActionSheet in
                
                ActionSheet(title: Text("Select Image"), message: Text("Please select an Image or capture Image!"), buttons: [
                    
                    ActionSheet.Button.default(Text("Photo Library"), action: {
                        self.imagePicker.toggle()
                        
                    }),
                    .cancel()
                    
                ])
            })
            .onAppear(perform: {
                self.f_name = self.currentUser.firstName ?? ""
                self.l_name = self.currentUser.lastName ?? ""
                self.u_name = self.currentUser.username ?? ""
            })
            NavigationLink(destination: self.pickerView, isActive: self.$imagePicker) {
                Text("")
            }.hidden()
            .navigationTitle("")

        }.animation(.spring()).edgesIgnoringSafeArea(.top)
        .edgesIgnoringSafeArea(.horizontal)
    }
}



struct UserViewHeader:View{
    var user:User
    var image:UIImage
    @Binding var editForm:Bool
    
    var fullName:String{
        get{
            var f =  self.user.firstName ?? ""
            var l = self.user.lastName ?? ""
            return f + " " + l
        }
    }
    
    var userImgURL:String{
        get{
            return self.user.photoURL ?? ""
        }
    }
    
    var userDetails:some View{
        VStack{
            VStack(alignment:.center){
                MainText(content: self.fullName, fontSize: 15, color: .white, fontWeight: .bold)
                MainText(content: "@\(self.user.username ?? "No username")", fontSize: 22.5, color: .white, fontWeight: .bold)
            }.padding(.horizontal)
            self.userInfo
        }
    }
    
    var userInfo:some View{
        func section(_ name:String, _ value:Int) -> some View{
            return VStack{
                MainText(content: String(format: "%.0f",value), fontSize: 15, color: .black, fontWeight: .bold)
                MainText(content: name, fontSize: 11.25, color: .black, fontWeight: .regular)
            }.padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.mainBG), alignment: .center)
        }
        
        return HStack{
            section("Followers", self.user.followers ?? 0)
                .padding()
            Divider().frame(width:2.5)
            section("Posts", self.user.postsCount ?? 0)
                .padding()
            Divider().frame(width:2.5)
            section("Following", self.user.following ?? 0)
                .padding()
        }.frame(width:totalWidth).padding(.horizontal)
    }
    
    var v1:some View{
        Image(uiImage: self.image)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(img: self.image), contentMode: .fill)
            .frame(width:totalWidth,height: totalHeight * 0.45, alignment: .center)
            .edgesIgnoringSafeArea(.horizontal)
            .blur(radius: 10)
            .cornerRadius(25.0)
            .overlay(
                VStack(alignment: .center){
                    Spacer()
                    HStack{
                        Spacer()
                        Image(systemName: "wand.and.rays")
                            .resizable()
                            .frame(width: 20,height:20)
                            .padding()
                            .background(Circle().fill(Color.gray.opacity(0.35)))
                            .onTapGesture(count: 1, perform: {
                                self.editForm.toggle()
                            })
                    }.frame(width:AppWidth).padding(.horizontal)
                    VStack(alignment: .center){
                        Image(uiImage: self.image)
                            .resizable()
                            .aspectRatio(UIImage.aspectRatio(img: self.image), contentMode: .fill)
                            .frame(width:totalHeight * 0.2,height: totalHeight*0.2)
                            .clipShape(Circle())
                        self.userDetails
                    }
                    Spacer()
                }
            )
    }
    
    var editButton:some View{
        HStack{
            Spacer()
            Image(systemName: "wand.and.rays")
                .resizable()
                .frame(width: 20,height:20)
                .padding()
                .background(Circle().fill(Color.gray.opacity(0.35)))
                .onTapGesture(count: 1, perform: {
                    self.editForm.toggle()
                })
        }.frame(width:AppWidth).padding(.horizontal)
    }
    
    var userInfoView:some View{
        VStack(alignment: .center){
            Image(uiImage: self.image)
                .resizable()
                .aspectRatio(UIImage.aspectRatio(img: self.image), contentMode: .fill)
                .frame(width:totalHeight * 0.2,height: totalHeight*0.2)
                .clipShape(Circle())
            self.userDetails
        }
    }
    
    var v3:some View{
        VStack(alignment: .center){
            Spacer().frame(height:35)
            self.editButton
            self.userInfoView
        }.background(
            Image(uiImage: self.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:totalWidth, alignment: .center)
                .frame(maxHeight: totalHeight * 0.75)
                .blur(radius: 10)
                .cornerRadius(25.0)
        )

    }
    
    
    
    var body: some View{
        self.v3
    }
}


struct UVMain_Previews: PreviewProvider {
    static var previews: some View {
        UVMain()
    }
}

//
//  PPVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/24/20.
//

import SwiftUI

struct PPVMain: View {
    @EnvironmentObject var mainStates : AppStates
    @State var dismiss:Bool = false
    @State var selectedImage:IDImage = .init(id:0)
    @State var selectedImages:[IDImage] = []
    @State var type:IIPModes = .single
    @State var mode:String = "camera"
    @State var capturedPicture:UIImage?
    @State var nextPage:Bool = false
    
    var finalPostImage:UIImage?{
        get{
            if self.mode == "camera", let safeImg = self.capturedPicture{
                return safeImg
            }else if self.mode == "library"{
                if self.type == .single, let safeImg = self.selectedImages.last?.image{
                    return safeImg
                }
            }
            return nil
        }
    }
    var tabs:[String] = ["Camera","Library"]
    var exitButton:some View{
        MainText(content: "Cancel", fontSize: 10,color:.black)
            .onTapGesture(count: 1, perform: {
                self.mainStates.tab = "home"
                self.mainStates.showTab = true
            })
    }
    
    var nextButton:some View{
        Button(action: {
            print("Next Button was clicked!")
            if self.finalPostImage != nil{
                self.nextPage.toggle()
            }
            
        }, label: {
            MainText(content: "Next", fontSize: 10,color: .black)
        })
        
    }
    
    var tabView:some View{
        HStack(spacing:25){
            ForEach(self.tabs,id:\.self){tab in
                Spacer(minLength: 0)
                MainText(content: tab , fontSize: 10, color: self.mode == tab.lowercased() ? Color.black : Color.gray, fontWeight: .bold)
                    .onTapGesture(count: 1, perform: {
                        self.mode = tab.lowercased()
                    })
                Spacer(minLength: 0)
                
            }
            
        }.frame(width:totalWidth/1.5)
    }
    
    var body: some View{
        NavigationView{
            VStack{
                if self.mode == "camera"{
                    ImagePicker(image: self.$capturedPicture, showIP: self.$dismiss) {
                        if let safeImage = self.capturedPicture{
                            print("You have taken an Image !")
                        }
                    }
                }
                if self.mode == "library"{
                    VStack {
                        InstaImagePicker(.single,selectedImages: self.$selectedImages){
                            print("Done")
                        }
                    }.frame(width: totalWidth, alignment: .center)
                    .animation(.spring())
                    .background(Color.mainBG)
                    //                    .navigationBarItems(trailing: self.doneButton)
                }
                self.tabView
                
                NavigationLink("", destination: PostFinalizer(image: self.finalPostImage), isActive: self.$nextPage)
                Spacer()
            }
            .frame(width:totalWidth)
            .navigationTitle("")
            .navigationBarItems(leading: self.exitButton,trailing: self.nextButton)
            .navigationBarTitleDisplayMode(.inline)
            
        }.edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            self.mainStates.showTab = false
            self.mainStates.loading = false
        })
        
    }
}

struct PostFinalizer:View{
    @EnvironmentObject var mainStates: AppStates
    var image:UIImage?
    @State var caption:String = ""
    
    var imageView:some View{
        Image(uiImage: self.image!)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(img: self.image), contentMode: .fill)
            .frame(width:AppWidth,height:totalHeight/3)
            .cornerRadius(25.0)
    }
    
    var nextButton:some View{
        Button(action: {
            print("Next Button was clicked!")
            if let img = self.image{
                self.mainStates.userAcc.addImagePosts(images: [img], caption: self.caption){
                    self.mainStates.showTab = true
                    self.mainStates.tab = "home"
                }
            }
        }, label: {
            MainText(content: "Next", fontSize: 10,color: .black)
        })
        
    }
    
    var PostView:some View{
        VStack{
            if self.image != nil{
                VStack(alignment:.center,spacing: 25){
                    self.imageView
                    TextField("Add a caption this post", text: self.$caption)
                    Spacer()
                }.padding()
            }
        }        
    }
    
    var body:some View{
        ScrollView(.vertical){
            //            Spacer().frame(height:150)
            self.PostView
                .navigationBarTitle("")
                .navigationBarItems(trailing: self.nextButton)
        }
    }
}


struct PPVMain_Previews: PreviewProvider {
    static var previews: some View {
        PPVMain()
    }
}

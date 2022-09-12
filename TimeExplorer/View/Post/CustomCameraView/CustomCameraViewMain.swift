//
//  CustomCameraViewMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/12/2020.
//

import SwiftUI
import AVFoundation

struct CameraView:View{
    @State var mode:CameraMode = .photo
    @State var photo:UIImage? = nil
    @State var mainPhoto:UIImage? = nil
    @State var capturedPhoto:Bool = false
    @State var tabName:String = "camera"
    @State var selectedImages:[IDImage] = []
    @State var latestImageFromLibrary:UIImage? = nil
    @EnvironmentObject var mainStates:AppStates
    @State var addCaption:Bool = false
    @State var caption:String = ""
    @State var edittingCaption:Bool = false
    @State var videoURL:URL? = nil
    @State var readyToPlay:Bool = true
    
    func processVideo(){
        if let url = self.videoURL{
            print("Url : \(url.absoluteString)")
        }
    }
    
    
    func processImage(){
        guard let safeImage = self.photo else {return}
        self.mainPhoto = safeImage
        self.photo = nil
    }
    
    var loadlastImage:UIImage?{
        get{
            return self.mainStates.photosManager.images.last?.image
        }
    }
    
    var imagePicker:some View{
        VStack(alignment: .center){
            Spacer().frame(height: 15)
//            InstaImagePicker(.single, selectedImages: self.$selectedImages,lastImage: self.$latestImageFromLibrary){
//                withAnimation(.easeInOut) {
//                    print("Done Button Pressed !")
//                    if let safeImage = self.selectedImages.last?.image{
//                        self.mainPhoto = safeImage
//                    }
//                    self.tabName = "camera"
//                }
//                
//            }
        }.padding(.top)
    }

    func closeCameraView(){
        withAnimation(.easeInOut) {
            self.mainStates.tab = "home"
        }
    }
    
    var imageViewButtons:some View{
        HStack{
            TextField("Add a caption", text: self.$caption) { (state) in
                if state{
                    self.edittingCaption = state
                }
            } onCommit: {
                if self.edittingCaption{
                    self.edittingCaption.toggle()
                }
                print("Commit the post!")
            }.padding()
            .foregroundColor(.white)
            .background(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.white, lineWidth: 2))

            Button {
                if let mainPhoto = self.mainPhoto, self.mode == .photo{
                    var images = [mainPhoto]
                    DispatchQueue.global(qos: .background).async {
                        self.mainStates.userAcc.addImagePosts(images: images, caption: self.caption) {
                            print("Image Post Fin.")
                        }
                    }
                }else if self.mode == .video, let url = self.videoURL{
                    DispatchQueue.global(qos: .background).async {
                        self.mainStates.userAcc.addVideoPosts(videoURL: url, caption: caption) {
                            print("Video Post Fin.")
                        }
                    }
                }
                self.selectedImages = []
                self.closeCameraView()
                
                
            } label: {
                MainText(content: "Post", fontSize: 10,color: .black)
                    .padding()
                    .background(Capsule().fill(Color.white))
            }
        }.padding(.horizontal)
    }
    
    var xMarkClose:some View{
        GeometryReader{g in
            VStack(alignment:.leading){
                HStack{
                    Button {
                        withAnimation(.easeInOut)
                        {
                            if mode == .photo{
                                if self.selectedImages.count > 0 {
                                    self.selectedImages = []
                                }
                                self.mainPhoto = nil
                                
                            }else if mode == .video{
                                guard let videoURL = self.videoURL else {return}
                                do{
                                    try FileManager.default.removeItem(at: videoURL)
                                    print("Removed Video Successfully !")
                                }catch{
                                    print("There was an error !")
                                }
                                self.videoURL = nil
                            }
                        }
                        
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 20, height: 20, alignment: .center)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white)
                            .padding()
                            .background(BlurView(style: .regular).clipShape(Circle()))
                    }.buttonStyle(PlainButtonStyle())
                    .padding(.vertical)

                    
                    Spacer()
                }.frame(width:g.size.width)
                Spacer()
            }.background(Color.clear)
        }
        
    }
    
    
    var imageView:some View{
        VStack{
            Spacer().frame(height:50)
            
            GeometryReader{g in
                var width: CGFloat = g.frame(in: .local).width
                var height:CGFloat = g.frame(in: .local).height
                ZStack{
                    Image(uiImage: self.mainPhoto!)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width,height: height)
                        .cornerRadius(25)
                    self.xMarkClose
                    .frame(height: height)
                }
            }.frame(width:totalWidth,height:self.edittingCaption ? totalHeight*0.4 : totalHeight * 0.8)
            self.imageViewButtons.padding()
            Spacer()
        }.frame(height:totalHeight)
    }
    

    
    var videoView:some View{
        
        return VStack{
            Spacer().frame(height:50)
            GeometryReader{g in
                var width: CGFloat = g.frame(in: .local).width
                var height:CGFloat = g.frame(in: .local).height
                ZStack(alignment: .top){
                    PlayerView(videoURL: self.videoURL,CGRect(x: 0, y: 0, width: width, height: height))
//                        .padding(.horizontal)
                        .cornerRadius(25)
                        .onTapGesture {
                            self.readyToPlay.toggle()
                        }
                    self.xMarkClose
                        .frame(height: height)
                }.frame(width:width,height: height)
            }.frame(width: totalWidth, height:self.edittingCaption ? totalHeight*0.4 : totalHeight * 0.8)
            self.imageViewButtons.padding()
            Spacer()
        }.frame(height:totalHeight)
    }
    
    
    
    var body: some View{
        ZStack{
            Color.black
            if mode == .photo && mainPhoto != nil{
                self.imageView
            }else if mode == .video && self.videoURL != nil{
                self.videoView
            }else{
                if self.tabName == "camera"{
                    CustomCameraView(image: self.$photo, didTapCapture: self.$capturedPhoto, tabName: self.$tabName,cameraMode: self.$mode, videoURL: self.$videoURL, latestImage: self.loadlastImage,onClose:self.closeCameraView)
                }else if self.tabName == "library"{
                    self.imagePicker
                }
                
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            if self.mainStates.showTab{
                self.mainStates.showTab = false
            }
        })
        .onDisappear(perform: {
            if !self.mainStates.showTab{
                self.mainStates.showTab = true
            }
        })
        .onChange(of: self.photo, perform: { (photo) in
            if photo != nil{
                self.processImage()
                print("Took Image")
            }
        })
        .onChange(of: self.videoURL) { (url) in
            self.processVideo()
        }
    }
    
}

struct CustomCameraView: View {
    
    @Binding var image: UIImage?
    @Binding var didTapCapture: Bool
    @Binding var tabName:String
    @State var cameraView:TypeCamera = .back
    @State var showGrid:Bool = false
    @Binding var cameraMode:CameraMode
    @Binding var videoURL:URL?
    var allCameraModes : [CameraMode] = [.photo,.video]
    var latestImage:UIImage? = nil
    var onClose: () -> Void
    
    var recentImageView:some View{
        Group{
            if self.latestImage != nil{
                Image(uiImage: self.latestImage!)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .aspectRatio(UIImage.aspectRatio(img: self.latestImage),contentMode: .fit)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .background(RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.white,lineWidth: 2.5))
                
            }else{
                MainText(content: "Photos", fontSize: 15,color: .white)
            }
        }.onTapGesture {
            withAnimation(.easeInOut) {
                self.tabName = "library"
            }
            
        }
        
        
    }
    
    var swapCameraView:some View{
        Image(systemName: "camera.rotate.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 25, height: 25)
            .padding()
            .background(Circle().fill(Color.gray.opacity(0.35)))
            .foregroundColor(.white)
            .onTapGesture(count: 1) {
                withAnimation(.easeInOut) {
                    self.cameraView = self.cameraView == .back ? .front : .back
                    print("Changing the cameraView : \(self.cameraView)")
                }
                
            }
    }
    
    var CameraOptionsView:some View{
        HStack(alignment:.center){
            Spacer()
            VStack{
                Spacer()
                Button {
                    print("Clicked show Grid")
                    withAnimation(.easeInOut) {
                        self.showGrid.toggle()
                    }
                } label: {
                    Image(systemName: "grid")
                        .resizable()
                        .frame(width: 20, height: 20, alignment: .center)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.white)
                        .padding()
                        .background(Circle().fill(Color.gray.opacity(0.35)))
                }
                Spacer()
            }.frame(width:50).padding()
            
        }
    }
    
    var gridView : some View {
            ZStack {
                HStack {
                    Spacer()
                    Divider()
                    Spacer()
                    Divider()
                    Spacer()
                }

                VStack {
                    Spacer()
                    Divider()
                    Spacer()
                    Divider()
                    Spacer()
                }
            }
        }
    
    var closeView:some View{
        HStack{
            Button {
                withAnimation(.easeInOut,{
                    self.onClose()
                })
                
            } label: {
                MainText(content: "Cancel", fontSize: 7.5, color: .black, fontWeight: .semibold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
            }
            Spacer()
            HStack(spacing:10){
                ForEach(self.allCameraModes, id: \.rawValue) { (mode)  in
                    var selected = self.cameraMode == mode
                    MainText(content: mode.rawValue.capitalized , fontSize: 15, color: selected ? .black : .white, fontWeight: .regular)
                        .padding()
                        .background(Capsule().fill(selected ? Color.white : Color.clear))
                        .onTapGesture {
                            if self.cameraMode != mode{
                                self.cameraMode = mode
                            }
                        }
                }
            }.background(BlurView(style: .regular).cornerRadius(25))
            Spacer()
        }.padding()
    }
    
    var VideoButton:some View{
        var radius:CGFloat = self.didTapCapture ? 25 : 50
        var circleview = Circle()
            .fill(Color.red)
            .frame(width: radius,height:radius)
            .animation(.easeInOut)
        
        var bgView = Circle()
            .stroke(Color.white, lineWidth: 2)
            .frame(width:55,height:55)
        
        var view = ZStack(alignment: .center){
            bgView
            circleview
        }
        return view.fixedSize().padding(.vertical).animation(.easeInOut)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black
            VStack{
                Spacer().frame(height:50).padding(.horizontal)
                CustomCameraRepresentable(image: self.$image, didTapCapture: $didTapCapture, swapCamera: self.$cameraView, captureMode: self.$cameraMode, videoURL: self.$videoURL).frame(height:totalHeight * 0.8).cornerRadius(25)
                    .overlay(
                        ZStack{
                            VStack{
                                self.closeView
                                Spacer()
                            }
                            self.CameraOptionsView
                            if self.showGrid{
                                self.gridView
                            }
                        }
                        
                    )
                Spacer()
            }.frame(height:totalHeight)
        

            HStack(alignment:.center){
                self.recentImageView
                Spacer()
                HStack{
                    if self.cameraMode == .photo{
                        CaptureButtonView()
                    }else if self.cameraMode == .video{
                        VideoButton
                    }
                }.padding(.vertical)
                .gesture(TapGesture(count: 1)
                    .onEnded({
                        self.didTapCapture.toggle()
                    })
                )
                Spacer()
                self.swapCameraView
            }.padding(.bottom).padding(.horizontal)
        }
    }
    
}

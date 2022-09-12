//
//  InstaImagePicker.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/21/20.
//

import SwiftUI
import Photos

//struct IDImage{
//    var id:Int
//    var image:UIImage? = nil
//    var asset:PHAsset? = nil
//
//}

class IDImage:ObservableObject{
    var id:Int = 0
    @Published var image:UIImage? = nil
    var asset:PHAsset? = nil

    init(id:Int,asset:PHAsset? = nil) {
        self.id = id
        self.asset = asset
    }

    func getImage(){
        guard let asset = self.asset else {return}
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        PHCachingImageManager.default().requestImage(for: asset, targetSize: .init(width: 400, height: 400), contentMode: .aspectFill, options: options) { (image, _) in
            guard let safeImage = image else {return}
            DispatchQueue.main.async {
                self.image = safeImage
            }
        }
    }
}

enum IIPModes:String{
    case single = "Single"
    case multiple = "Multiple"
}

struct InstaImagePicker: View {
    @EnvironmentObject var mainStates:AppStates
    var mode:IIPModes
//    @State var images:[IDImage] = []
    @Binding var selectedImages:[IDImage]
    @Binding var dismiss:Bool
    var previewImage:UIImage = .init()
    @State var xOffset:CGFloat = 0.0
    @State var yOffset:CGFloat = 0.0
    @State var scale:CGFloat = 1.0
    @Binding var lastImage:UIImage?
//    @State var images:[IDImage] = []
    var onDone: () -> Void
    init(_ mode:IIPModes = .single, _ dismiss:Binding<Bool>? = nil, selectedImages : Binding<[IDImage]>? = nil, lastImage: Binding<UIImage?>? = nil,handler: @escaping () -> Void){
        self.mode = mode
        if let safeSI = selectedImages{
            self._selectedImages = safeSI
        }else{
            var empty:[Int:IDImage] = [:]
            self._selectedImages = Binding.constant([IDImage]())
        }
        if let dis = dismiss{
            self._dismiss = dis
        }else{
            self._dismiss = Binding.constant(false)
        }
        if let LI = lastImage{
            self._lastImage = LI
        }else{
            self._lastImage = Binding.constant(.init())
        }
        self.onDone = handler
    }

    var images:[IDImage]{
        get{
            return self.mainStates.photosManager.images.reversed()
        }
    }
    
    func updateSelectedImages(_ image:IDImage){
        
        if self.mode == .single{
            self.selectedImages = []
            self.selectedImages.append(image)
        }else if self.mode == .multiple{
            if self.selectedImages.count < 6{
                self.selectedImages.append(image)
            }
        }
        self.xOffset = 0
        self.yOffset = 0
    }
        
    func imageGrid() -> some View{
        let cols = [GridItem.init(.flexible(), spacing: 0,alignment: .center),GridItem.init(.flexible(), spacing: 0, alignment: .center),GridItem.init(.flexible(), spacing: 0, alignment: .center)]
        var view = LazyVGrid(columns:cols,spacing:0){
            ForEach(self.images,id: \.id){image in
                Button(action:{
                    self.updateSelectedImages(image)
                },label:{
                    //GridImage(image)
                })
                
            }
        }.frame(width:totalWidth)
        
        return view
    }
    
    var pickerView: some View{
        VStack {
            Spacer().frame(height:150)
            HStack {
                Spacer()
                Button(action: {
                    self.dismiss.toggle()
                    print("self.imagePicker : ",self.dismiss)
                }, label: {
                    MainText(content: "Done", fontSize: 15)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
                })
            }
            self.imageGrid()
        }.frame(width: totalWidth, alignment: .center)
        .animation(.spring())
        .background(Color.mainBG)
//        .onReceive(self.mainStates.photosManager.$images) { (images) in
//            self.images = images
//        }
    }
    
    var photoGrid:some View{
        ScrollView(.vertical,showsIndicators:false){
            if !self.images.isEmpty{
                self.imageGrid()
            }
        }
    }
    
    var firstImage:UIImage?{
        get{
            return self.selectedImages.last?.image
//                ?? self.images.first?.image ?? UIImage(named: "AttractionStockImage")!
        }
    }
    
    func onChanged(value:DragGesture.Value){
        self.xOffset = value.translation.width
        self.yOffset = value.translation.height
    }
    
    func onEnded(value:DragGesture.Value){
        var dimension = UIImage.dimension(img: self.firstImage)
        var _x = value.translation.width
        var _y = value.translation.height
        var initHeight = totalHeight * 0.25
        var initWidth = totalWidth * 0.5
        var imgWidth = dimension.width > totalWidth ? dimension.width * 0.75 : dimension.width * 0.5
        var imgHeight = dimension.height > totalHeight * 0.5 ? dimension.height * 0.75 : dimension.height * 0.5
        var moveWidth = _x < 0 ? initWidth - _x : initWidth + _x
        var moveHeight = _y < 0 ? initHeight - _y : initHeight + _y
        print("moveWidth: \(moveWidth) and imgWidth: \(imgWidth)")
        print("moveHeight: \(moveHeight) and imgHeight: \(imgHeight)")
        if moveWidth > imgWidth{
            self.xOffset = 0
        }
        if moveHeight > imgHeight{
            self.yOffset = 0
        }
    }
    
    var IMGView:some View{
        Image(uiImage: self.firstImage!)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(img: self.firstImage), contentMode: .fill)
//                .frame(width:totalWidth,height:totalHeight * 0.5)
            .frame(height:totalHeight * 0.5)
            .clipped()
            .gesture(DragGesture()
                        .onChanged({ (value) in
                            self.onChanged(value: value)
                        })
                        .onEnded({ (value) in
                            self.onEnded(value: value)
                        })
            )
            .gesture(MagnificationGesture()
                        .onChanged({ (value) in
                            self.scale = value
                        })
                        .onEnded({ (value) in
                            if value.magnitude < 1{
                                self.scale = 1
                            }else{
                                self.scale = value.magnitude
                            }
                            print(value.magnitude)
                        })
            
            )
            .scaleEffect(self.scale)
            .offset(x: self.xOffset, y: self.yOffset)
    }
    
    var imageZoomView:some View{
        ZStack(alignment:.center){
            self.IMGView
                .clipShape(Rectangle())
            VStack{
                HStack{
                    Spacer()
                    MainText(content: "Done", fontSize: 10, color: .white, fontWeight: .bold)
                        .padding()
                        .background(RoundedRectangle(cornerRadius:20).fill(Color.red))
                        .onTapGesture(count: 1) {
                            self.onDone()
                        }
                }.padding(.horizontal)
                Spacer()
            }.frame(width:totalWidth).padding()
//                Circle()
//                    .stroke(Color.white, lineWidth: 5)
//                    .frame(height: totalHeight * 0.45, alignment: .center)
//                    .shadow(radius: 10)
//                    .padding(.all)
        }.frame(height:totalHeight * 0.5)
    }
    
    var body: some View {
        VStack(spacing:0){
            if self.firstImage != nil{
                self.imageZoomView.frame(height:totalHeight * 0.5)
            }
            
            self.photoGrid
        }.frame(width:totalWidth)
        .statusBar(hidden: true)
    }
}
//
//struct GridImage:View{
//    @ObservedObject var imgAsset:IDImage = .init(id: 0)
////    @ObservedObject var IMD: ImageDownloader = .init()
//    var width:CGFloat = 0
//    var height:CGFloat = 0
//    init(_ imgAsset:IDImage,_ width:CGFloat = totalWidth/3,_ height:CGFloat = 125){
//        self.imgAsset = imgAsset
//        self.width = width
//        self.height = height
//    }
//
//    var body: some View{
//        var image = self.imgAsset.image ?? .stockImage
//        return Image(uiImage: image)
//            .resizable()
//            .aspectRatio(UIImage.aspectRatio(img:image), contentMode: .fill)
//            .frame(width:width,height:height)
//            .clipped()
//            .edgesIgnoringSafeArea(.horizontal)
//            .onAppear {
//                if self.imgAsset.image == nil{
//                    self.imgAsset.getImage()
//                }
//            }
//    }
//}

//struct InstaImagePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        TestIIP()
//    }
//}

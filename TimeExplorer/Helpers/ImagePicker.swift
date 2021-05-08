//
//  ImagePicker.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/17/20.
//

import SwiftUI
import Photos

class Coordinator:NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    var parent:ImagePicker
    
    init(parent:ImagePicker){
        self.parent = parent
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            self.parent.image = image
        }
        self.parent.showIP.toggle()
        self.parent.onDismiss()
        //        self.parent.presentationMode.wrappedValue.dismiss()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.parent.showIP.toggle()
    }
    
    
}

struct ImagePicker:UIViewControllerRepresentable{
    @Environment (\.presentationMode) var presentationMode
    @Binding var image:UIImage?
    @Binding var showIP:Bool
    var onDismiss : () -> Void
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        //        if self.type == "camera"{
        picker.sourceType = .camera
        //        }
        //        picker.sourceType  = .photoLibrary
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
        
    }
}


class PhotoImages:ObservableObject{
    @Published var images:[IDImage] = []
    @Published var lastImage:UIImage? = nil
    init(){
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized && self.images.isEmpty{
                self.getImages()
            }else{
                print("No Authorizations!")
            }
        }
    }
    
    
    func getImages(){
        let opt = PHFetchOptions()
        opt.includeHiddenAssets = false
        opt.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let req = PHAsset.fetchAssets(with: .image, options: .none)
        
        DispatchQueue.global(qos: .background).async {            
            req.enumerateObjects { (asset, index, _) in
                self.images.append(IDImage(id: index, asset: asset))
            }
            
        }
    }
    
    static func getImage(asset: PHAsset?) -> UIImage{
        guard let safeAsset = asset else{return UIImage(named: "AttractionStockImage")!}
        var img: UIImage?
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.version = .original
        options.isSynchronous = true
        manager.requestImageData(for: safeAsset, options: options) { data, _, _, _ in
            
            if let data = data {
                img = UIImage(data: data)
            }
        }
        return img ?? UIImage(named: "AttractionStockImage")!
        
    }
    
}

class PHAssetImageLoader:ObservableObject{
    
}

class PhotoLoader:ObservableObject{
    @Published var image:UIImage = UIImage(named: "AttractionStockImage")!
    func getImage(asset:PHAsset?){
        guard let safeAsset = asset else{return}
        
        var image:UIImage? = nil
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        PHCachingImageManager.default().requestImage(for: safeAsset, targetSize: .init(width: 400, height: 400), contentMode: .aspectFill, options: options) { (img, _) in
            if let safeImg = img{
                DispatchQueue.global(qos: .background).async {
                    self.image = safeImg
                }
            }
        }
    }
}

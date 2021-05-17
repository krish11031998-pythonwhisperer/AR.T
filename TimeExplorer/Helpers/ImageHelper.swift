//
//  ImageHelper.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation
import SwiftUI
import Photos
import Combine
//var ImageCache = NSCache<NSString,NSData>()

protocol DictCache{
    subscript(_ url:URL) -> UIImage? { get set }
}

struct ImageCache:DictCache{
    private let cache:NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL,UIImage>()
        cache.countLimit = 100;
        cache.totalCostLimit = 1024 * 1024 * 200
        return cache
    }()
    static var cache = ImageCache()
    subscript(url: URL) -> UIImage? {
        get{
            var res : UIImage? = nil
            if let url = url as? NSURL{
                res = self.cache.object(forKey: url)
            }
            return res
        }
        set{
            guard let img = newValue, let url = url as? NSURL else {return}
            self.cache.setObject(img, forKey: url)
        }
    }
}


extension Image{
    
    static var bottomShadow = Image("bottomBackground")
    static var topShadow = Image("topBackground")
    static var userBG = Image("userBackground")
    
    static func templateImage(_ image:UIImage, _ width:CGFloat, _ height: CGFloat, _ aR:CGFloat? = nil,clipShape:Bool = true) -> some View{
        var aspectRatio:CGFloat = 1.0
        if let ar = aR{
            aspectRatio = ar
        }else{
            aspectRatio = UIImage.aspectRatio(img: image)
        }
        var cor1 = clipShape ? 15 : 0
        var cor2 = clipShape ? 30 : 0
        
        return Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width:width,height:height)
            .clipShape(Corners(rect: [.topLeft,.bottomRight], size: .init(width: cor1, height: cor1)))
            .clipShape(Corners(rect: [.topRight,.bottomLeft], size: .init(width: cor2, height: cor2)))
    }
//    static func aspectRatio(){
//        var image = self
//    }
}

extension UIImage{
    
    static var stockImage:UIImage = UIImage(named: "AttractionStockImage")!
    
    static func downloadImage(_ url:String) -> UIImage{
        var image:UIImage = UIImage(named: "AttractionStockImage")!
        if let _url = URL(string: url),let cachedImage = ImageCache.cache[_url]{
            image = cachedImage
        }else{
            guard let safeURL = URL(string:url) else {return image}
            URLSession.shared.dataTask(with: safeURL) { (data, resp, err) in
                guard let safeData = data , let safeImage = UIImage(data:safeData) else {
                    if let err = err{
                        print(err)
                    }
                    return
                    
                }
                ImageCache.cache[URL(string: url)!] = safeImage
                
                DispatchQueue.main.async {
                    image = safeImage
                }
                
                
            }.resume()
        }
        return image
    }
    
    func cropToBounds(width: CGFloat, height: CGFloat,alignment:Alignment? = nil) -> UIImage {
        
        let image = self
        let cgimage = image.cgImage!
        let contextImage: UIImage = UIImage(cgImage: cgimage)
        let contextSize: CGSize = contextImage.size
        var posX: CGFloat = 0.0
        var posY: CGFloat = 0.0
        var cgwidth: CGFloat = width
        var cgheight: CGFloat = height

        // See what size is longer and create the center off of that
        
        if contextSize.width > contextSize.height {
            posX = ((contextSize.width - contextSize.height) / 2)
            posY = 0
            cgwidth = contextSize.height
            cgheight = contextSize.height
        } else {
            posX = 0
            posY = ((contextSize.height - contextSize.width) / 2)
            cgwidth = contextSize.width
            cgheight = contextSize.width
        }
                

        let rect: CGRect = CGRect(x: posX, y: posY, width: cgwidth, height: cgheight)

        // Create bitmap image from context using the rect
        let imageRef: CGImage = cgimage.cropping(to: rect)!

        // Create a new image based on the imageRef and rotate back to the original orientation
        let cropped_image: UIImage = UIImage(cgImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        
        return cropped_image
    }
    

    static func loadImageFromCache(_ url:String?) -> UIImage?{
        var image:UIImage? = nil
        if let url = url,let _url = URL(string: url),let cachedImage = ImageCache.cache[_url]{
            image = cachedImage
        }
        return image
    }
    
    static func loadImageFromCache(_ url:String?) -> UIImage{
        var image:UIImage = UIImage(named: "AttractionStockImage")!
        if let url = url,let _url = URL(string: url),let cachedImage = ImageCache.cache[_url]{
            image = cachedImage
        }
        return image
    }
    
    static func aspectRatio(name:String? = nil, img:UIImage? = nil) -> CGFloat{
        var aR:CGFloat = 1.5
        var dimension = UIImage.dimension(name: name, img: img)
        aR = dimension.width/dimension.height
        return aR
    }
    
    func aspectRatio() -> CGFloat{
        var img = self
        var aR:CGFloat = 1.5
        var dimension = UIImage.dimension(name: nil, img: img)
        aR = dimension.width/dimension.height
        return aR
    }
    
    static func dimension(name:String? = nil,img:UIImage? = nil) -> (width:CGFloat,height:CGFloat){
        var res:(width:CGFloat,height:CGFloat) = (width:0,height:0)
        if let safeImg = name != nil ? UIImage(named: name!) : img, let cgImage = safeImg.cgImage{
            res.height = CGFloat(cgImage.height)
            res.width = CGFloat(cgImage.width)
        }
        return res
        
    }
    
    func resizeImage() -> UIImage?{
        let image = self
        let dimensions = UIImage.dimension(img: image)
        let ARatio:CGFloat = dimensions.width/dimensions.height
        let maxWidth:CGFloat = 1024
        let maxHeight = ARatio * maxWidth
        let compressedQuality: CGFloat = 0.75
        
        _ = dimensions.width <= maxWidth ? 0 : dimensions.width - maxWidth
        _ = dimensions.height <= maxHeight ? 0 : dimensions.height - maxHeight
        let rect : CGRect = .init(x: 0, y: 0, width: maxWidth, height: maxHeight)
        UIGraphicsBeginImageContext(rect.size)
        image.draw(in: rect)
        guard let img : UIImage = UIGraphicsGetImageFromCurrentImageContext(), let imgData : Data = img.jpegData(compressionQuality: compressedQuality) else {return nil}
        UIGraphicsEndImageContext()
        return UIImage(data: imgData)
        
    }
    
    
    static func thumbnailImage(videoURL:URL?,completion: @escaping ((UIImage?) -> Void)){
        guard let url = videoURL else {return}
        let asset = AVAsset(url: url)
        let avAssetImageGenerator = AVAssetImageGenerator(asset: asset)
        avAssetImageGenerator.appliesPreferredTrackTransform = true
        let thumbnailtime = CMTimeMake(value: 2, timescale: 1)
        do{
            let cgThumbImage = try avAssetImageGenerator.copyCGImage(at: thumbnailtime, actualTime: nil)
            DispatchQueue.main.async {
                completion(UIImage(cgImage: cgThumbImage))
            }
        }catch{
            print("Error trying to generate thumbnail Image!")
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

class ImageDownloader:ObservableObject{
    var url:String = ""
    var asset:PHAsset? = nil
    @Published var image:UIImage = UIImage(named: "AttractionStockImage")!
    @Published var images:[String : UIImage] = [:]
    @Published var loading:Bool = true
    @Published var mode:String = "single"
    var cancellable = Set<AnyCancellable>()
    static var shared:ImageDownloader = .init()
    
    
    var aspectRatio:CGFloat{
        get{
            return UIImage.aspectRatio(img: self.image)
        }
    }
    
    
    func parseImage(data: Data,url safeURL:URL){
        guard let safeImage = UIImage(data: data) else {return}
        ImageCache.cache[URL(string: safeURL.absoluteString)!] = safeImage
        if mode == "single"{
            self.image = safeImage
            
        }else if mode == "multiple"{
            self.images[safeURL.absoluteString] = safeImage
        }
        self.loading = false
    }
    
    func checkData(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        guard let resp = response as? HTTPURLResponse, resp.statusCode >= 200 && resp.statusCode < 300 else{
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    func downloadImg(url safeURL:URL,mode:String = "single",crop:Bool=false,bounds:CGSize? = nil){
        guard let img = UIImage.stockImage.pngData() else {return}
        URLSession.shared.dataTaskPublisher(for: safeURL)
//            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .tryMap(self.checkData(output:))
            .sink(receiveCompletion: { completion in
            }, receiveValue: { [weak self] data in
                self?.parseImage(data: data, url: safeURL)
            })
            .store(in: &self.cancellable)
            
    }
    
    func getImage(url:String,mode:String = "single",crop:Bool=false,bounds:CGSize? = nil){
        self.url = url
        self.mode = mode
        if let _url = URL(string: url),let cachedImage = ImageCache.cache[_url]{
//        if let cachedData = ImageCache.object(forKey: url as NSString), let cachedImage = UIImage(data: cachedData as Data){
            DispatchQueue.main.async {
                if mode == "single"{
                    self.image = cachedImage
                }else if mode == "multiple"{
                    self.images[url] = cachedImage
                }
                self.loading = false
//                print("Loaded from the cache")
            }
        }else{
            
            guard let safeURL = URL(string:url) else {print("Something wrong with the url : \(url)");return}
//            DispatchQueue.global().async {
            self.downloadImg(url: safeURL, mode: mode, crop: crop, bounds: bounds)
//            }

        }
    }
    
    func getImages(urls:[String]){
        urls.forEach { (url) in
            self.getImage(url: url, mode: "multiple")
        }
    }
    
}

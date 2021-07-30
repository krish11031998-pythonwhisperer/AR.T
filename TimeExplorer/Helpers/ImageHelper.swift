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

enum JPEGQuality: CGFloat {
    case lowest  = 0
    case low     = 0.25
    case medium  = 0.5
    case high    = 0.75
    case highest = 1
}

protocol DictCache{
    subscript(_ url:URL) -> UIImage? { get set }
}

struct ImageCache:DictCache{
    private let cache:NSCache<NSURL, UIImage> = {
        let cache = NSCache<NSURL,UIImage>()
        cache.countLimit = 500;
        cache.totalCostLimit = 1024 * 1024 * 500
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
    
    static var stockImage:UIImage = UIImage(named: "stockImage")!
    
    static func downloadImage(_ url:String) -> UIImage{
        var image:UIImage = UIImage(named: "AttractionStockImage")!
        if let _url = URL(string: url),let cachedImage = ImageCache.cache[_url]{
            image = cachedImage
        }else{
            guard let safeURL = URL(string:url) else {return image}
            URLSession.shared.dataTask(with: safeURL) { (data, resp, err) in
                guard let safeData = data , let safeImage = UIImage(data:safeData) else {
                    if let err = err{
//                        print(err)
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
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
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
    
    func png() -> Data?{
        return pngData()
    }
}

class ImageDownloader:ObservableObject{
    var url:String = ""
    var asset:PHAsset? = nil
    var b_images:[String:UIImage] = [:]
    @Published var image:UIImage?
    @Published var images:[String : UIImage] = [:]
    @Published var loading:Bool = false
    @Published var mode:String = "single"
    var cancellable = Set<AnyCancellable>()
    static var shared:ImageDownloader = .init()
    var quality:JPEGQuality
    
    
    init(url:String? = nil,urls:[String]? = nil,mode:String = "single",quality:JPEGQuality = .lowest){
        self.mode = mode
        self.quality = quality
        if let safeURL = url{
            self.getImage(url: safeURL)
        }
        if let safeURLS = urls{
            self.getImages(urls: safeURLS)
        }
        
    }
    
    var aspectRatio:CGFloat{
        get{
            return UIImage.aspectRatio(img: self.image)
        }
    }
    
    func publishImage(url:String,safeImage:UIImage){
        if self.mode == "single"{
            DispatchQueue.main.async {
                self.image = safeImage
                self.loading = false
            }
        }else if self.mode == "multiple"{
//            self.b_images[url] = safeImage
            DispatchQueue.main.async {
                self.images[url] = safeImage
            }
        }
    }
    
    func parseImage(data: Data,url safeURL:URL,bound:CGSize? = nil){
        guard let safeData = UIImage(data: data)?.jpeg(self.quality), let safeImage = UIImage(data: safeData) else {return}
        ImageCache.cache[URL(string: safeURL.absoluteString)!] = safeImage
        self.publishImage(url: safeURL.absoluteString, safeImage: safeImage)
        
    }
    
    func checkData(output: URLSession.DataTaskPublisher.Output) throws -> Data{
        let (data,response) = output
        guard let resp = response as? HTTPURLResponse, resp.statusCode >= 200 && resp.statusCode < 300 else{
            throw URLError(.badServerResponse)
        }
        return data
    }
    
    func downloadImg(url safeURL:URL,mode:String = "single",crop:Bool=false,bounds:CGSize? = nil){
        URLSession.shared.dataTaskPublisher(for: safeURL)
            .subscribe(on: DispatchQueue.global(qos: .userInteractive))
            .receive(on: DispatchQueue.global(qos:.userInteractive))
            .tryMap(self.checkData(output:))
            .sink(receiveCompletion: { completion in
            }, receiveValue: { [weak self] data in
                self?.parseImage(data: data, url: safeURL,bound: bounds)
            })
            .store(in: &self.cancellable)
            
    }
    
    func getImage(url:String,crop:Bool=false,bounds:CGSize? = nil){
        DispatchQueue.main.async {
            if !self.loading {self.loading = true}
        }
        guard let _url = URL(string:url) else  {print("Something wrong with the url : \(url)");return}
        if let cachedImage = ImageCache.cache[_url]{
            self.publishImage(url: _url.absoluteString, safeImage: cachedImage)
        }else{
            self.downloadImg(url: _url, mode: mode, crop: crop, bounds: bounds)
        }
    }
    
    func getImages(urls:[String]){
        let last = urls.count - 1
        for i in 0...last{
            self.getImage(url: urls[i])
            if i == last{
                DispatchQueue.main.async {
                    self.loading = false
                }
            }
            
        }
    }
    
}

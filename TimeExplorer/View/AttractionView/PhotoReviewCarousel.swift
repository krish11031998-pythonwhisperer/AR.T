//
//  PhotoReviewCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/28/20.
//

import SwiftUI


struct ReviewModel:Identifiable{
    var id:Int
    var attraction:AttractionModel
    var image:UIImage
}


struct PhotoReviewCarousel: View {
    @ObservedObject var SP:swipeParams = .init()
    var incomingData:[AMID]
    //    var incomingData:[ReviewModel]
    
    
    static func formatData(data:[AMID]) -> [ReviewModel]{
        var result:[ReviewModel] = []
        if data.count > 0{
            result = data.map({ (amid) -> ReviewModel in
                var id = amid.id
                var att = amid.attraction
                var image = UIImage(named: "10d")!
                if let url = att.photo?.images?.original?.url{
                    image = UIImage.downloadImage(url)
                }
                return ReviewModel(id: id, attraction: att, image: image)
            })
        }
        return result
    }
    
    var splitData:(left:[AMID],right:[AMID]){
        get{
            var length = self.incomingData.count
            var l = Array(self.incomingData[0..<self.SP.swiped])
            //            var m = self.incomingData[self.SP.swiped]
            var r = Array(self.incomingData[self.SP.swiped + 1..<length])
            return (left:l,right:r)
        }
    }
    
    func getOffset(index:Int) -> CGFloat{
        var swiped = self.SP.swiped
        //        var diff = index > swiped ? index - swiped : swiped - index
        var diff = index - swiped
        var factor:CGFloat = 10.0
        var defaultOff = diff < 3 && diff > -3  ? CGFloat(diff) * factor : 2 * factor
        return defaultOff
    }
    
    func onChanged(value:CGFloat){
        if value < 0{
            if self.SP.swiped != self.incomingData.last!.id{
                self.SP.extraOffset = value
            }
        }else if value > 0{
            if self.SP.swiped != 0{
                self.SP.extraOffset = value
            }
        }
    }
    
    func onEnded(value:CGFloat){
        if value < 0{
            if -value > 20 && self.SP.swiped != self.incomingData.last!.id{
                self.SP.swiped += 1
                self.SP.extraOffset = 0
            }else{
                self.SP.extraOffset = 0
            }
        }else{
            if self.SP.swiped > 0{
                if value > 20{
                    self.SP.extraOffset = 0
                    self.SP.swiped -= 1
                }else{
                    self.SP.extraOffset = 0
                }
            }
        }
    }
    
    func getAR(id:Int) -> CGFloat{
        let swipedID = id - self.SP.swiped
        var diff = CGFloat(swipedID) * 0.025
        return swipedID > 2 ? 0.8 : (1.0 - diff)
    }
    
        var leftCarousel: some View{
            ZStack{
                ForEach(self.splitData.left){d in
                    PhotoReviewCard(review: d)
                        .offset(x: self.getOffset(index: d.id))
                }
            }
        }
    
        var rightCarousel: some View{
            ZStack{
                ForEach(self.splitData.right.reversed()){d in
                    PhotoReviewCard(review: d)
                        .offset(x: self.getOffset(index: d.id))
                }
            }
        }
    
    
        var backGroundStack:some View{
            HStack(spacing:0){
                self.leftCarousel.frame(width:totalWidth/2.5)
//                Spacer().frame(width:totalWidth/2.5)
                self.rightCarousel.frame(width:totalWidth/2.5)
            }.animation(.easeInOut).frame(width:totalWidth).padding()
    
        }
    
    var mainStack:some View{
        ZStack{
            ForEach(self.incomingData.reversed()){d in
                PhotoReviewCard(review: d)
                    .offset(x: self.getOffset(index: d.id))
                    .gesture(DragGesture()
                                .onChanged({ (value) in
                                    withAnimation(.easeInOut, {
                                        self.onChanged(value: value.translation.width)
                                    })
                                    
                                })
                                .onEnded({ (value) in
                                    withAnimation (.easeInOut,{
                                        self.onEnded(value: value.translation.width)
                                    })
                                    
                                })
                    )
                    .scaleEffect(1.5)
                    .offset(x: self.SP.swiped == d.id ? self.SP.extraOffset : 0)
            }
        }
    }
    
    var mainCard:some View{
        PhotoReviewCard(review: self.incomingData[self.SP.swiped])
            .gesture(DragGesture()
                        .onChanged({ (value) in
                            withAnimation(.easeInOut, {
                                self.onChanged(value: value.translation.width)
                            })
                            
                        })
                        .onEnded({ (value) in
                            withAnimation (.easeInOut,{
                                self.onEnded(value: value.translation.width)
                            })
                            
                        })
            )
            .scaleEffect(1.5)
            .offset(x: self.SP.extraOffset)
        //                .animation(.easeInOut)
    }
    
    var body: some View {
        ZStack(alignment: .center){
            self.backGroundStack
            //            self.rightCarousel
            self.mainCard.animation(.easeInOut)
//            self.mainStack.animation(.easeInOut)
            
        }.frame(width:totalWidth)
        .padding(.bottom,100)
    }
}

struct PhotoReviewCard: View{
    var review:AMID
    var width:CGFloat = 0.0
    var height:CGFloat = 0.0
    var aspectRatio:CGFloat = 1.0
    var url:String = ""
    @ObservedObject var ImD:ImageDownloader = .init()
    @State var _image:UIImage?
    //    @State var imageLoaded:Bool = false
    init(review:AMID){
        self.review = review
        if let img = review.attraction.images?.original , var height = img.height , var width = img.width, let url = img.url{
            self.height = CGFloat(Float(height) ?? 1.0)
            self.width = CGFloat(Float(width) ?? 1.0)
            self.aspectRatio = self.width/self.height
            self.url = url
        }
        //        self.getImage()
    }
    
    
    var image:UIImage{
        get{
            if let safeData = ImageCache.object(forKey: self.url as NSString), let safeImage = UIImage(data: safeData as Data){
                return safeImage
            }else{
                self.ImD.getImage(url: url)
                return self.ImD.image
            }
        }
    }
    
    var body: some View{
        //        Image(uiImage: UIImage.downloadImage(self.url))
        //        Image(uiImage: self.ImD.image)
        Image(uiImage: image)
            .resizable()
            .aspectRatio(self.aspectRatio,contentMode:.fill)
            .frame(width:200,height:150)
            .clipped()
            .cornerRadius(25.0)
    }
}

struct PhotoReviewCarousel_Previews: PreviewProvider {
    static var previews: some View {
        ZStack{
            Color.black
            //            PhotoReviewCarousel(incomingData: PhotoReviewCarousel.formatData(data:reviewData))
            PhotoReviewCarousel(incomingData: reviewData)
        }
        
    }
}

//
//  VerticalPhotoReview.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/30/20.
//

import SwiftUI

struct ReviewCard:View{
    var review:AMID
    var aspectRatio:CGFloat = 1.0
    var userImg:String = ""
    var mainImg:String = ""
    var image:UIImage = UIImage(named: "10d")!
    
    static var width:CGFloat = (totalWidth - 50)/1.5
    @StateObject var mainImgD:ImageDownloader = .init()
    @StateObject var userImgD:ImageDownloader = .init()
    init(review:AMID,image:UIImage? =  nil){
        self.review = review
        if let safeImage = review.attraction.images?.original, let url = safeImage.url ,let w = safeImage.width, let h = safeImage.height, let uI = review.attraction.user?.avatar?.small{
            var width = CGFloat(Float(w) ?? 1.0)
            var height = CGFloat(Float(h) ?? 1.0)
            self.userImg = uI.url ?? ""
            self.mainImg = url
            self.aspectRatio = width/height
        }
    }
    
    
    func mainImageView() -> some View{
        if self.mainImgD.url != self.mainImg{
            self.mainImgD.getImage(url: self.mainImg)
        }
        return Image(uiImage: self.mainImgD.image ?? UIImage(named: "10d")!)
            .resizable()
            .aspectRatio(self.aspectRatio,contentMode:.fill)
            .frame(width:ReviewCard.width,height: 150)
            .cornerRadius(25.0)
    }

    
    var reviewDetail:(rating:String,comment:String){
        get{
            var result:(rating:String,comment:String) = (rating:"1",comment:"")
            if let review = self.review.attraction.linked_reviews?.first{
                result.rating = review.rating ?? ""
                result.comment = review.title ?? ""
            }
            return result
        }
    }
    
    func imgHeader() -> some View{
        if self.userImgD.url != self.userImg{
            self.userImgD.getImage(url: self.userImg)
        }
        var view = HStack{
            Image(uiImage: self.userImgD.image ?? UIImage(named: "10d")!)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width:30,height: 30)
                .clipShape(Circle())
                .padding(.leading,7.5)
            Spacer()
        }
        return view
    }
    
    func ratingView(rating:String) -> some View{
        var _rating = Int(rating ?? "0") ?? 0
        var view = VStack{
            HStack{
                ForEach(1..<6){rating in
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(rating <= _rating ? .orange : .white)
                }
                Spacer()
            }
        }
        return view
    }
    
    
    var imgComments:some View{
        VStack(alignment: .leading){
            self.ratingView(rating: self.reviewDetail.rating)
            MainText(content: self.reviewDetail.comment, fontSize: 7.5, color: .white, fontWeight: .bold)
        }.padding(.leading)
        
    }
    
    var body: some View{
        self.mainImageView()
            .overlay(
                VStack(alignment:.leading){
                    self.imgHeader()
                    Spacer()
                    self.imgComments
                }.padding(.vertical)
                .background(Color.black.opacity(0.35).cornerRadius(25.0))
            )
            .onAppear(perform: {
                self.mainImgD.getImage(url: self.mainImg)
                self.userImgD.getImage(url: self.userImg)
            })
        
        
    }
}

struct VerticalPhotoReview_Previews: PreviewProvider {
    static var previews: some View {
//        VerticalPhotoReview(reviews: reviewData)
        ReviewCard(review: reviewData.last!)
    }
}

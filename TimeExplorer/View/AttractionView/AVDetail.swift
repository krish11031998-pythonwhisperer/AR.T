//
//  AVDetail.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/22/20.
//

import SwiftUI

struct AVDetail: View {
    var attraction:AttractionModel
    @StateObject var ImD:ImageDownloader = .init()
    var url:String = ""
    var frame:(width:CGFloat,height:CGFloat) = (width: 0.0,height:0.0)
    var aspectRatio:CGFloat = 1.0
    @Binding var showAttraction:Bool
    @ObservedObject var photosReview:PhotoReviewSearch = .init(location:"",test:false)
    @ObservedObject var SP:swipeParams = .init()
    init(attraction:AttractionModel,showAttraction:Binding<Bool>){
        self.attraction = attraction
        if let image = attraction.photo?.images?.large,let url = image.url,let width = image.width,let height = image.height{
            self.url = url
            self.frame.height = CGFloat(Float(height) ?? 0.0)
            self.frame.width = CGFloat(Float(width) ?? 0.0)
            self.aspectRatio = self.frame.width/self.frame.height
        }
        self._showAttraction = showAttraction
        self.photosReview.location_id = attraction.location_id ?? ""
        
    }
    
    var details:(name:String,des:String){
        get{
            var res:(name:String,des:String) = (name:"",des:"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.")
            res.name = self.attraction.name ?? "No Name"
            if let description = self.attraction.description, description != ""{
                res.des = description
            }
            return res
        }
    }
    
    func addressHStack(name:String,value:String) -> some View{
        var image = Image(systemName: name)
        var view = HStack{
            image
                .resizable()
                .frame(width: 15, height: 15)
                .foregroundColor(.black)
            MainText(content: value, fontSize: 17.5, color: .white, fontWeight: .regular)
        }
        return view
    }
    
    var addressView: some View{
        HStack {
            VStack(alignment: .leading){
                if self.attraction.location_string != nil{
                    self.addressHStack(name: "location.fill", value: self.attraction.location_string!)
                }
                if self.attraction.phone != nil{
                    self.addressHStack(name: "phone.fill", value: self.attraction.phone!)
                }
                if self.attraction.offer_group?.lowest_price != nil{
                    self.addressHStack(name: "dollarsign.circle.fill", value: String(format: "%.1f",self.attraction.offer_group!.lowest_price!))
                }
            }.padding(.leading,10)
            Spacer()
        }.frame(width:totalWidth - 20).padding(.all)
        .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.15)).frame(width:totalWidth - 20).shadow(color: Color.black.opacity(0.35), radius: 5, x: 1, y: 1))
    }
    
    var detailsView:some View{
        VStack(alignment:.leading){
            //            Spacer().frame(height:50)
            //            self.addressView.padding(.all)
            VStack(alignment:.leading,spacing:10){
                MainText(content: "Description", fontSize: 25, color: .black, fontWeight: .semibold)
                MainText(content: self.details.des, fontSize: 15, color: .black, fontWeight: .regular)
                    .fixedSize(horizontal: false, vertical: true)
                self.mapView.padding(.top)
                    .frame(width: totalWidth - 25,height: 250)
                    .padding(.vertical)
            }.padding(.horizontal)
        }.frame(width:totalWidth)
        .background(Color.clear)
        //        .edgesIgnoringSafeArea(.vertical)
    }
    
    func ratingView() -> some View{
        var _rating = Int(self.attraction.rating ?? "0") ?? 0
        var view =
//            VStack{
            HStack{
                ForEach(1..<6){rating in
                    Image(systemName: "star.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(rating <= _rating ? .orange : .white)
                }
                Spacer()
            }.frame(width:totalWidth).padding(.leading)
//        }
        return view
    }
    
    var mapView:some View{
        VStack(alignment: .leading){
            MainText(content: "Location", fontSize: 25, color: .black, fontWeight: .bold)
            BasicMap(attraction: self.attraction).cornerRadius(25)
        }
    }
    
    var mainHeadingDetails:some View{
        VStack(alignment: .leading,spacing:10){
            HStack{
                Spacer()
            }
                MainText(content: self.details.name, fontSize: 35, color: .white, fontWeight: .bold)
                if self.attraction.location_string != nil{
                    self.addressHStack(name: "location.fill", value: self.attraction.location_string!)
                }
//                Spacer().frame(height: 60)
        }.frame(width: totalWidth - 20).padding(.leading).padding(.bottom,60)
    }
    
    func mainImg() -> some View{
        
        
        return Image(uiImage: self.ImD.image ?? .stockImage)
            .aspectRatio(self.aspectRatio,contentMode: .fill)
            .frame(width : totalWidth - 20, height: totalHeight * 0.45)
//            .cornerRadius(25)
            .overlay(
                ZStack {
                    Color.black.opacity(0.35)
                    VStack(alignment: .leading){
                        HStack{
                            TabBarButtons(bindingState: self.$showAttraction)
                            Spacer()
                        }.padding()
                        
                        Spacer()
                        self.mainHeadingDetails
                    }
                }.padding(.leading) .frame(width : totalWidth - 20).cornerRadius(25)
            )
            .clipShape(ArcCorners(corner: .bottomRight, curveFactor: 0.1, cornerRadius: 30, roundedCorner: .allCorners))
    }
    
    var reviewView: some View{
        VStack(alignment:.leading){
            MainText(content: "Reviews", fontSize: 25, color: .black, fontWeight: .semibold)
                .padding(.leading)
//            PhotoZoomCarousel(incomingData: reviewData).padding(.vertical)
        }
    }
    
    var v3: some View{
        ScrollView(.vertical,showsIndicators:false){
//            Spacer().frame(height:40)
//            self.mainImg()
            StickyHeaderImage(w: totalWidth, h: totalHeight * 0.4, url: self.url, curvedCorner: true)
            self.detailsView
            self.reviewView
            Spacer().frame(height:200)
        }
    }
    
    var body: some View{
        ZStack{
            Color.mainBG
            self.v3
        }.edgesIgnoringSafeArea(.all)
        .gesture(DragGesture()
                    .onChanged({ (value) in
                        var width = value.translation.width
                        self.SP.extraOffset = width
                    })
                    .onEnded({ (value) in
                        var width = value.translation.width
                        if width > 50{
                            self.showAttraction.toggle()
                        }
                    })
        )
        
        .navigationBarBackButtonHidden(true)
    }
}

//struct AVDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        AVDetail(attraction: attractionExample.first!)
//    }
//}

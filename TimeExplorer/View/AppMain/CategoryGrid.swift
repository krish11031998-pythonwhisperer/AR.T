//
//  CategoryGrid.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/3/20.
//

import SwiftUI

struct CategoryGrid: View {
    
    var attr:String
    var nightlif:String
    var res:String
    var shopping:String
    var activities:String
    @State var active:Int = 0
//    @State var time:Int
    let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
    @State var tabNum:Int = 0
    init(attr:String = "0",nightLif:String = "0",res:String = "0",shopping:String = "0",activities:String = "0"){
        self.attr = attr
        self.nightlif = nightLif
        self.res = res
        self.shopping = shopping
        self.activities = activities
        
    }
    
    var cols:[(name:String,image:String,amount:String,color:Color)]{
        get{
            return [(name:"Attractions",image:"AttractionStockImage",amount: self.attr,color:Color.yellow),(name:"NightLife",image:"NightLifeStockImage",amount:self.nightlif,color: .red),(name:"Restaurant",image:"RestaurantStockImage",amount:self.res,color:.blue),(name:"Activities",image:"ActivitiesStockImage",amount:self.activities,color:.green)]
        }
    }
    
    var colLayout = [
        GridItem(.flexible(minimum: 150),spacing: 10),
        GridItem(.flexible(minimum: 150),spacing: 10)
    ]
    
//    func timer(){
//        var time:Int = 0
//        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
//            time += 1
//            if time != 0 && time%10 == 0{
//                self.active = self.active < self.cols.count - 1 ? self.active + 1 : 0
//            }
//        }
//    }
    
    var v3:some View{
        CategoryMainCard(value: Int(self.cols[self.active].amount) ?? 0, name: self.cols[self.active].name, image: self.cols[self.active].image)
            .animation(.easeInOut)
            .onAppear(perform: {
//                self.timer()
            })
    }
    
    var v4:some View{
        TabView(selection: self.$tabNum){
            ForEach(0..<self.cols.count){i in
                Image(self.cols[i].image)
                    .resizable()
                    .aspectRatio(contentMode:.fill)
                    .tag(i)
                    .overlay(ZStack{
                        Color.gray.opacity(0.5)
                        VStack(alignment:.trailing){
                            Spacer()
                            MainText(content: "\(self.cols[i].amount) \(self.cols[i].name) ", fontSize: 20, color: .white, fontWeight: .bold).frame(alignment:.trailing)
                                .padding(.bottom)
                        }.padding()
                    })
            }
        }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding()
        .frame(width:totalWidth * 0.9,height:totalHeight * 0.175)
        .onReceive(timer) { _ in
            self.tabNum = self.tabNum < self.cols.count ? self.tabNum + 1 : 0
        }
        
    }
    
    var v5:some View{
        LazyVGrid(columns: colLayout, alignment: .center, spacing: 10) {
            ForEach(self.cols,id:\.name){col in
                ColoredCategoryCard(name: col.name, color: col.color, image: col.image, amt: col.amount)
                    .frame(height: 150)
            }
        }.padding(.horizontal)
    }
    
    var body: some View{
        self.v5
    }
}

struct ColoredCategoryCard:View{
    var name:String
    var color:Color
    var image:String
    var amt:String
    
    var amtView:some View{
        HStack{
            MainText(content: "\(self.amt)", fontSize: 15, color: .white, fontWeight: .bold)
                .padding()
                .background(Circle().fill(Color.gray.opacity(0.35)))
            Spacer()
        }
//
    }
    
    
    var bgColor:UIColor{
        get{
            return UIColor(self.color)
        }
    }
    
    var body:some View{
            HStack{
                VStack(alignment: .center) {
                    self.amtView
                    Spacer()
                    MainText(content: self.name, fontSize: 20, color: .white, fontWeight: .semibold)
                }.padding(.horizontal)
                Spacer()
            }.padding(.vertical)
            .background(RoundedRectangle(cornerRadius: 25).fill( Color.linearGradient(colorOne: self.bgColor, colorTwo: .black)))
    }
}

struct CategoryCard: View{
    var name:String
    var image:String
    var amount:String
    var height:CGFloat = 150
    var width:CGFloat = totalWidth/2.5
    
    
//    var height: CGFloat{
//        get{
//            return self.width/self.aspectRatio
//        }
//    }
    
    var aspectRatio:CGFloat{
        get{
            var aR:CGFloat = 1.5
            if let image = UIImage(named: self.image)?.cgImage{
                var height = image.height
                var width = image.width
                aR = CGFloat(width)/CGFloat(height)
            }
            return aR
        }
    }
    
    var body: some View{
        VStack(alignment:.center,spacing:0){
            Image(self.image)
                .resizable()
                .aspectRatio(self.aspectRatio, contentMode: .fill)
                .frame(width:self.width,height:self.height,alignment: .center)
                .clipShape(Corners(rect: [.topLeft,.topRight], size: .init(width: 25, height: 25)))
//
            VStack{
                MainText(content: self.name, fontSize: 10, color: .black, fontWeight: .regular)
                MainText(content: self.amount, fontSize: 12.5, color: .black, fontWeight: .bold)
            }.padding(.vertical)
//            }.padding(.all).background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
        }.background(RoundedRectangle(cornerRadius: 25).fill(Color.white))
    }
}

struct CategoryMainCard:View{
    var value:Int
    var name:String
    var image:String
    
    var body: some View{
        Image(self.image)
            .resizable()
            .aspectRatio(UIImage.aspectRatio(name: self.image),contentMode: .fill)
            .frame(width: totalWidth - 35, height: 150)
            .clipped()
            .cornerRadius(25)
            .overlay(
                ZStack(alignment:.bottom){
                    Spacer()
                    Color.black.opacity(0.45)
                    HStack{
                        Spacer()
                        MainText(content: "\(self.value)", fontSize: 35, color: .white, fontWeight: .bold).animation(.linear)
                        MainText(content:"\(self.name) Spots", fontSize: 15, color: .white, fontWeight: .regular).animation(.linear)
                        Spacer().frame(width:10)
                    }.padding(.bottom)
                }.cornerRadius(25)
            )
    }
    
}

struct CategoryGrid_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            CategoryGrid(attr: "35153", nightLif: "531351", res: "990", shopping: "809709", activities: "873892")
//            CategoryMainCard(value:43541,name: "Attractions", image: "AttractionStockImage")
        }
    }
}

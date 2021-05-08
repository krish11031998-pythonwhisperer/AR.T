//
//  AMMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/26/20.
//
var defaultCoords = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
import SwiftUI
import MapKit
struct AMMain: View {
    //    @StateObject var LS:LocationSearch = .init(place:"",test:true)
    @State var city:AttractionModel = .init()
    @State var attractions:[AMID] = []
    @State var categoriesData:(attr:String,nightLif:String,res:String,shopping:String,activities:String) = (attr:"0",nightLif:"0",res:"0",shopping:"0",activities:"0")
    @StateObject var ImgD:ImageDownloader = .init()
    @State var expandedInfo:Bool = false
    @EnvironmentObject var mainStates:AppStates
    @State var homeTab:String = "Map"
    @State var hideOverview:Bool = false
    @State var chosenSection:String = ""
    @State var showSection:Bool = false
    @Namespace var animation
    
    init(){
        self._showSection = State(initialValue: false)
    }
    
    var homeTabs:[String] = ["Blogs","Tours","Attractions","Map"]
    var coordinates:CLLocationCoordinate2D{
        get{
            return self.mainStates.coordinates
        }
    }
    
    var loading:Bool{
        get{
            return self.mainStates.loading
        }
        set{
            self.mainStates.loading = newValue
        }
    }
    
    var aspectRatio:CGFloat{
        get{
            var ar:CGFloat = 1.0
            if let BG = self.city.photo?.images?.large, let width = BG.width, let height = BG.height {
                ar = CGFloat(Float(width) ?? 1.0)/CGFloat(Float(height) ?? 1.0)
            }
            return ar
        }
    }
    
    func attractionCategory() -> some View{
        let view = VStack(alignment:.leading){
            AVQuickMenu(coordinates: self.coordinates, attr: self.attractions)
        }
        return view
    }
    
    
    var cityDetails:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: self.city.name ?? "No City", fontSize: 25, color: .black, fontWeight: .semibold)
            MainText(content: self.city.geo_description ?? "No desc", fontSize: 12, color: .black, fontWeight: .regular).fixedSize(horizontal: false, vertical: true)
        }.padding(.leading).padding(5).frame(width:totalWidth)
    }
    
    
    var HomeTabs:some View{
        HStack(alignment:.top){
            Spacer()
            ForEach(self.homeTabs,id:\.self){tab in
                Button(action: {
                    self.homeTab = tab
                }, label: {
                    VStack{
                        MainText(content: "\(tab)", fontSize: 15, color: .black, fontWeight: self.homeTab == tab ? .semibold : .regular)
                        if self.homeTab == tab{
                            Circle().fill(Color.red).frame(width:10)
                        }
                    }
                }).padding(.horizontal,5)
            }
            Spacer()
        }.frame(width:AppWidth,alignment: .center)
    }
    
    func categoryCircle(_ name:String,_ value:String, _ color:Color,_ width:CGFloat) -> some View{
        return VStack(alignment: .center, spacing: 5){
            MainText(content: name, fontSize: 12.5, color: .orange, fontWeight: .regular)
            MainText(content: value, fontSize: 20, color: .white, fontWeight: .regular)
        }.padding().frame(width:width).background(BlurView(style: .systemThinMaterialDark).clipShape(RoundedRectangle(cornerRadius: 25)))
    }
    
    
    var header:some View{
        let mainView = GeometryReader{g in
            let width  = g.frame(in: .local).width
            let height  = g.frame(in: .local).height
            
            
            ZStack(alignment: .top) {
                if self.city.photo != nil{
                    StickyHeaderImage(w: width, h: height,url: self.city.photo?.images?.original?.url, image:nil)
                }
                lightbottomShadow.clipShape(Corners(rect: [.bottomRight,.bottomLeft], size: .init(width: 30, height: 30))).offset(y:-20)
                VStack(alignment:.leading){
                    HStack{
                        VStack(alignment: .leading, spacing: 10){
                            MainText(content: "Let's Explore : ", fontSize: 25, color: .white, fontWeight: .semibold, style: .normal)
                            MainText(content: "Dubai", fontSize: 35, color: .white, fontWeight: .semibold, style: .normal)
                        }
                        Spacer()
                        LottieView(filename: "traveller",loopMode: .loop).frame(width: width * 0.3, height: height * 0.3, alignment: .center).padding()
                    }.padding(.horizontal,10).frame(width:width)
                    
                    MainText(content: self.city.geo_description ?? "", fontSize: 12.5, color: .white, fontWeight: .medium)
                        .padding()
                }
                .frame(width: width, height: height - 20, alignment: .center)
            }
        }.frame(width: totalWidth, height: totalHeight * 0.4, alignment: .center)
        .edgesIgnoringSafeArea(.top)
        
        return mainView
        
    }
    
    func setupData(_ data:[LocationSearchData]){
        self.city = LocationSearchData.extractCityInfo(data)
        self.attractions = LocationSearchData.parseLSD_to_AMID(data)
        self.categoriesData = LocationSearchData.extractCategoriesData(city)
    }
    
    
    func sections(heading:String,type:String) ->  some View{
        return VStack(alignment: .center, spacing: 25){
            HStack{
                MainText(content: heading, fontSize: 25, color: .black, fontWeight: .bold,style: .heading)
//                    .padding(.leading,25)
                Spacer()
            }.frame(width:AppWidth)
            if(type == "Posts"){
                TopPostView (animation: self.animation){
                    withAnimation(.hero) {
                        self.chosenSection = "posts"
                        self.showSection = true
                    }
                    
                }
            }
            if(type == "Blogs"){
                QuickBlogsView {
                    self.chosenSection = "blogs"
                    self.showSection = true
                }
            }
            if(type == "Landmarks"){
                self.attractionCategory()
            }
            
        }
    }
    
    
    var scrollViewContent:some View{
        VStack(alignment: .leading, spacing: 25){
            
            self.sections(heading: "Top Blogs", type: "Blogs")
                .padding().frame(width:AppWidth,height: 500)
            self.sections(heading: "Top Landmarks", type: "Landmarks")
                .padding().frame(width:AppWidth,height: 500)
            self.sections(heading: "Top Posts", type: "Posts")
                .padding(.vertical)
            
            Spacer().frame(height:100)
        }
    }
    
    var mainView: some View {

        ScrollView(.vertical, showsIndicators: false){
            
            VStack(alignment:.center,spacing:20){
                self.header
                self.scrollViewContent
            }

        }.padding(.top,20)
        .frame(width: totalWidth).edgesIgnoringSafeArea(.all)
        .onAppear(perform: {
            if self.mainStates.LS.result.isEmpty{
                self.mainStates.LS.getLocation {
                    print("Got Data!")
                }
            }
        })
        .onReceive(self.mainStates.LS.$result) { (result) in
            if !result.isEmpty{
                self.setupData(result)
                if let BG = self.city.photo?.images?.original,let url = BG.url{
                    self.ImgD.getImage(url: url)
                }
                self.mainStates.loading = false
            }

        }
        .navigationTitle("")
        .navigationBarHidden(true)
    }
    
    var chosenSectionView:some View{
        VStack{
            if self.chosenSection == "posts"{
                Color.clear.overlay(
                    PVMain(cityName: "", showPost: .constant(false), tabstate: .constant(false), show: self.$showSection).matchedGeometryEffect(id: "postsViewMain", in: self.animation,properties: .position,anchor: .top)
                ).transition(.modal)
                
            }
            
            if self.chosenSection == "blogs"{
                TabBlogViewMain(tabstate: .constant(false), show: self.$showSection)
            }
        }
    }
    
    
    var body: some View{
        GeometryReader{ g in
            var minY = g.frame(in: .local).minY
            ZStack(alignment: .center) {
                self.mainView
                if self.showSection{
                    self.chosenSectionView
                        .offset(y: -minY)
                        .background(Color.white)
                        
                }
            }
        }.onChange(of: self.showSection, perform: { (val) in
            if !val && self.chosenSection != ""{
                self.chosenSection = ""
            }
        })
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        .animation(.spring())
        
    }
    
}



struct AMMain_Previews: PreviewProvider {
    @State static var loading:Bool  = false
    @State static var coord:CLLocationCoordinate2D =  .init()
    static var previews: some View {
        //        AMMain(loading: AMMain_Previews.$loading,coordinates: AMMain_Previews.$coord)
        AMMain()
    }
}

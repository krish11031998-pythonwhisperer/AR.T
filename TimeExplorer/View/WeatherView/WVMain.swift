////
////  WVMain.swift
////  TimeExplorer
////
////  Created by Krishna Venkatramani on 9/18/20.
////
//
//import SwiftUI
//import MapKit
////import SwiftUICharts
////import Charts
//var ITmaxHeight:CGFloat = 500
//
//
//
//struct WVMain: View {
//    @EnvironmentObject var mainStates:AppStates
//    @State var expandTab:Bool = false
//    @StateObject var WM:WeatherAPI = .init()
//    @StateObject var ImgD: ImageDownloader = .init()
//    @Binding var hideOverView:Bool
//    var handler:(((name:String,temp:String,desc:String)) -> Void)?
//    var attractions:[AMID] = []
//    init(attr:[AMID]? = nil,handler:(((name:String,temp:String,desc:String)) -> Void)? = nil,hO:Binding<Bool>? = nil){
//        if let Sattr = attr{
//            self.attractions = Sattr
//        }
//        if let safeHandler = handler{
//            self.handler = safeHandler
//        }
//        if let hO = hO{
//            self._hideOverView = hO
//        }else{
//            self._hideOverView = Binding.constant(true)
//        }
//    }
//    
//    func absDiff(x:Float,y:Float) -> Float{
//        return x >= y ? x - y : y - x
//    }
//    
//    var coordinates:CLLocationCoordinate2D{
//        get{
//            return self.mainStates.coordinates
//        }
//    }
//    
//    func getData(){
//        self.WM.coordinate = self.coordinates
//        self.WM.getWeatherInfo {
////            self.mainStates.loading = false
//            print("Got Data")
//        }
//    }
//    
//    
//    var data:WeatherData{
//        get{
//            return self.WM.result ?? example
//        }
//    }
//    
//    var cityInfo:(name:String,temp:String,desc:String){
//        get{
//            var name = self.data.timezone.components(separatedBy: "/")[1]
//            var temp = String(format:"%.0f",(self.data.current.temp ?? 273) - 273)
//            var description = self.data.current.weather.first?.description.capitalized ?? "Clear"
//            return (name:name ?? "",temp:temp,desc:description)
//        }
//    }
//    
//
//    var hourlyTemps:[CGFloat]{
//        get{
//            return self.data.hourly.map { (wp) -> CGFloat in
//                return CGFloat(wp.temp - 273)
//            }
//        }
//    }
//
//    
//    var v4:some View{
//        var fiveHoursTemp = Array(self.data.hourly[0...5]).map({Double($0.temp)})
//        var weather = self.data.current
//        let min = fiveHoursTemp.min() ?? Double(0.0)
//        let max = fiveHoursTemp.max() ?? Double(1.0)
//        var hourlyTemp = fiveHoursTemp.map { (val) -> Double in
//            return (val - min)/(max - min)
//        }
//        var lineChart = Chart(data: hourlyTemp)
//            .chartStyle(
//                LineChartStyle(.quadCurve, lineColor: .blue, lineWidth: 5)
//            )
//        var res = [(name:"Temp",value: (weather.temp - 273).toString(),symbol:"C",img:"001-thermometer"),(name:"Clouds",value:weather.clouds.toString(),symbol:"%",img:"009-cloud"),(name:"Wind",value:weather.wind_speed.toString(),symbol:"mph",img:"024-wind")]
//        
//        func weatherStack(_ data:(name:String,value:String,symbol:String,img:String)) -> some View{
//            var view = GeometryReader{g in
//                var width = g.frame(in: .local).width
//                var height = g.frame(in: .local).height
//                
//                HStack(alignment:.top){
//                    Image(data.img)
//                        .resizable()
//                        .aspectRatio(contentMode: .fit)
//                        .frame(width:width * 0.4)
//                    VStack(alignment:.leading,spacing:7.5){
//                        MainText(content: data.name, fontSize: 15, color: .orange, fontWeight: .medium)
//                        HStack(alignment:.center){
//                            MainText(content: "\(data.value)", fontSize: 17.5, color: .white, fontWeight: .regular)
//                            MainText(content: "\(data.symbol)", fontSize: 10, color: .white, fontWeight: .regular)
//                        }
//                    }
//                }
//            }
//            return view
//        }
//        
//        
//        var view =
//            GeometryReader{ g in
//                VStack(alignment: .center){
//                    var width = g.frame(in: .local).width
//                    var height = g.frame(in: .local).height
//                    HStack(alignment: .top,spacing: 20){
//                        ForEach(res,id:\.name){col in
//                            weatherStack(col)
//                                .frame(width:width * 0.3)
//                        }
//                    }
//                    if self.hideOverView{
//                        VStack(alignment:.leading,spacing:10){
//                            MainText(content: "Weather Forecast", fontSize: 25, color: .white, fontWeight: .regular)
//                            MainText(content: "Min: \(Float(min - 273).toString()) C  Max: \(Float(max - 273).toString()) C", fontSize: 15, color: .white, fontWeight: .regular)
//                            lineChart
//                                .frame(width: width - 25, height: height * 0.5, alignment: .center)
//                                .padding()
//                        }
//                    }
//                }
//            }.padding()
//            .background(BlurView(style: .systemThinMaterialDark).cornerRadius(25))
//    
//        return view
//        
//    
//    }
//    
//    var body: some View {
//        VStack(alignment:.center,spacing:20){
////            self.additionInfo(weather: self.data.current).animation(.easeInOut)
////            self.v3
//            Button(action: {
//                self.expandTab.toggle()
//                self.hideOverView.toggle()
//            }, label: {
//                self.v4
//            })
//            
//        }.animation(.easeInOut).padding(.vertical)
//        .onChange(of: self.mainStates.coordinates.latitude, perform: { value in
//            self.getData()
//        })
//        .onAppear(perform: {
//            self.getData()
//        })
//    }
//}
//
//struct WVMain_Previews: PreviewProvider {
//    static var previews: some View {
//        WVMain()
//    }
//}

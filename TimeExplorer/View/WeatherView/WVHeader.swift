//
//  WVHeader.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI
import MapKit
struct WVHeader: View {
    var weatherData:WeatherData
    @State var showToday:Bool = false
    @Binding var coordinates:CLLocationCoordinate2D
    var _CityInfo:(name:String,temp:String,desc:String)? = nil
    var cityInfo:(name:String,temp:String,desc:String){
        get{
            if let safeCityInfo = self._CityInfo{
                return safeCityInfo
            }
            var name = self.weatherData.timezone.components(separatedBy: "/")[1]
            var temp = String(format:"%.0f",self.weatherData.current.temp - 273)
            var description = self.weatherData.current.weather.first?.description.capitalized ?? "Clear"
            return (name:name,temp:temp,desc:description)
        }
    }
    
    func additionInfo() -> some View{
        var weather = self.weatherData.current
        func smallWeatherinfo(tag:String,value:Float,symbol:String = "%") -> some View{
            return VStack(alignment:.center){
                MainText(content: tag, fontSize: 15,color: .white).fixedSize(horizontal: false, vertical: true)
                MainText(content: "\(String(format:"%.1f",value)) \(symbol)", fontSize: 20,color: .purple)
            }.padding()
        }
        
        func hStacks(values:[(name:String,value:Float,symbol:String)],width:CGFloat) -> some View{
            return HStack{
                ForEach(0..<values.count){i in
                    smallWeatherinfo(tag: values[i].name, value: values[i].value,symbol: values[i].symbol).frame(width: width/2.1)
                }
            }
        }
        
        
        var view =
            GeometryReader{g in
                VStack(alignment:.center){
                    hStacks(values: [(name:"Clouds",value:weather.clouds,symbol:"%"),(name:"Dew Point",value:weather.dew_point,symbol:"C")], width: g.frame(in:.local).width)
                    hStacks(values: [(name:"UVI",value:weather.uvi ?? 0.0,symbol:"%"),(name:"Wind Speed",value:weather.wind_speed,symbol:"mph")], width: g.frame(in:.local).width)
                    hStacks(values: [(name:"Humidity",value:Float(weather.humidity),symbol:"%"),(name:"Pressure",value:Float(weather.pressure/1000),symbol:"bar")], width: g.frame(in:.local).width)
                }
            }.frame(width:AppWidth - 100,height:275).aspectRatio(contentMode: .fill).background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
        return view
    }
    
    var v1: some View {
        VStack {
            HStack{
                VStack(alignment:.leading){
                    MainText(content: self.cityInfo.name, fontSize: 25, color: .purple, fontWeight: .medium)
                    MainText(content: self.cityInfo.desc, fontSize: 12.5, color: .black, fontWeight: .regular)
                }
                Spacer()
                MainText(content: self.cityInfo.temp, fontSize: 30, color: .purple, fontWeight: .bold)
            }
            if self.showToday{
                self.additionInfo().animation(.easeInOut)
            }
        }.padding(.all)
        .frame(width:AppWidth - 20)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(color: Color.black.opacity(0.5), radius: 5, x: 1, y: 1))
        .onTapGesture(count:1,perform: {
            self.showToday.toggle()
        })
        .animation(.easeInOut)
    }
    
//    var v2:some View{
//        ZStack(alignment:.top){
//            MapView(coordinate: self.$coordinates).cornerRadius(25)
//                .aspectRatio(0.85, contentMode: .fit)
//                .animation(.easeInOut)
////                .clipShape(Corners(rect: [.bottomLeft,.bottomRight], size: .init(width: 50, height: 50)))
//            VStack{
//                HStack{
//                    VStack(alignment:.leading){
//                        MainText(content: self.cityInfo.name, fontSize: 25, color: .purple, fontWeight: .medium)
//                        MainText(content: self.cityInfo.desc, fontSize: 12.5, color: .black, fontWeight: .regular)
//                    }
//                    Spacer()
//                    MainText(content: self.cityInfo.temp, fontSize: 30, color: .purple, fontWeight: .bold)
//                }
//            }.padding(.all).background(Color.white.opacity(0.75).cornerRadius(25))
//        }.edgesIgnoringSafeArea(.all)
//    }
    
    
    var body: some View{
        self.v1
    }
}

struct WVHeader_Previews: PreviewProvider {
    @State static var coordinate:CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
    static var previews: some View {
        WVHeader(weatherData: example,coordinates: WVHeader_Previews.$coordinate)
    }
}

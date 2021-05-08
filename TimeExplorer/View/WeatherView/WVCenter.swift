//
//  WVCarousel.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI

var days:[String] = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]

struct WVCenter: View {
    var weatherData:WeatherData
    var cityInfo:(name:String,temp:String,desc:String)
    init(weatherData:WeatherData){
        self.weatherData = weatherData
        self.cityInfo = self.weatherData.getCityInfo()
    }
    var body: some View {
        VStack(alignment: .center, spacing: 5){
            MainText(content: "Weather Forecast (next 10 Days)" , fontSize: 20, color: .orange, fontWeight: .regular)
            Divider().frame(width:AppWidth - 150)
            WeatherForecastCarousel(daily: self.weatherData.daily)
        }.padding(.all).background(RoundedRectangle(cornerRadius: 20).fill(Color.white).shadow(color: Color.black.opacity(0.5), radius: 5, x: 1, y: 1).frame(width:totalWidth - 20))
    }
}

struct WeatherForecastCarousel: View{
    var daily:[DailyWeatherParameters]
    @State var selected:Int = -1
    
    func onChange(index:Int){
        self.selected = self.selected == index ? -1 : index
    }
    
    func smallWeatherCard(index:Int) -> some View{
        var day = self.daily[index]
        var dayName = index > 6 ? days[index - 6] : days[index]
        var dayTemp = String(format:"%.0f", day.feels_like.day! - 273 ?? 0.0)
        
        return VStack{
            MainText(content: dayName, fontSize: 15, color: self.selected == index ? .white :  .purple)
            Image(uiImage: WeatherAPI.getWeatherIcons(day.weather.first?.icon ?? "10d"))
                .resizable()
                .frame(width:25,height: 25)
            MainText(content: "\(dayTemp) C", fontSize: 20, color: .black, fontWeight: .semibold)
            
        }.padding(.all).background(RoundedRectangle(cornerRadius: 20).fill(self.selected == index ? Color.purple : Color.orange)).onTapGesture(count: 1, perform: {
            self.onChange(index: index)
        }).animation(.easeInOut)
    }
    
    func additionInfo(index:Int) -> some View{
        var weather = self.daily[index]
        func Temp(index:Int) -> some View{
            var day = self.daily[index].temp
            var dayTemp = 273.0
            if let d = day.day, let e = day.eve, let m = day.morn, let n = day.night{
                dayTemp = Double((d + e + m + n)/4.0)
            }
            var view = HStack{
                MainText(content: "Avg :\(String(format: "%.0f", (dayTemp) - 273)) C", fontSize: 12.5, color: .white, fontWeight: .regular)
                MainText(content: "Max : \(String(format: "%.0f", (day.max ?? 0.0) - 273)) C", fontSize: 12.5, color: .white, fontWeight: .regular)
                MainText(content: "Min : \(String(format: "%.0f",(day.min ?? 0.0) - 273)) C", fontSize: 12.5, color: .white, fontWeight: .regular)
            }.padding().background(RoundedRectangle(cornerRadius: 20).fill(Color.purple))
            return view
        }
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
                VStack(alignment:.leading){
                    Temp(index: index).frame(width:g.frame(in: .local).width).padding(.top)
                    hStacks(values: [(name:"Clouds",value:weather.clouds,symbol:"%"),(name:"Dew Point",value:weather.dew_point,symbol:"C")], width: g.frame(in:.local).width)
                    hStacks(values: [(name:"UVI",value:weather.uvi ?? 0.0,symbol:"%"),(name:"Wind Speed",value:weather.wind_speed,symbol:"mph")], width: g.frame(in:.local).width)
                    hStacks(values: [(name:"Humidity",value:Float(weather.humidity),symbol:"%"),(name:"Pressure",value:Float(weather.pressure/1000),symbol:"bar")], width: g.frame(in:.local).width)
                }
            }.frame(width:AppWidth - 100,height:350).background(RoundedRectangle(cornerRadius: 20).fill(Color.orange))
        return view
    }
    
    var carousel: some View{
        ScrollView(.horizontal, showsIndicators: false){
            HStack{
                ForEach(0..<self.daily.count){(x) in
                    self.smallWeatherCard(index: x)
                }
            }
        }
    }
    
    var body: some View{
        VStack{
            self.carousel
            if self.selected != -1{
                self.additionInfo(index: self.selected).animation(.easeInOut)
            }
        }.padding()
        
        .animation(.easeInOut)
    }
}


struct WVCarousel_Previews: PreviewProvider {
    static var previews: some View {
        WVCenter(weatherData: example)
    }
}

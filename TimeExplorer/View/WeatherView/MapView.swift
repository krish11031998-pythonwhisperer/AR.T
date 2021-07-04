//
//  MapView.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI
import MapKit

struct StaticMapView: View{
    var width:CGFloat
    var coordinates:CLLocationCoordinate2D
    init(_ coord:CLLocationCoordinate2D, width w:CGFloat = 100){
        self.coordinates = coord
        self.width = 100
    }
    
    var body:some View{
        StaticMKView(self.coordinates)
            .frame(width: self.width, height: self.width, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            .cornerRadius(25)
    }
    
    
}


struct StaticMKView:UIViewRepresentable{
    
    var coord:CLLocationCoordinate2D
    init(_ coord:CLLocationCoordinate2D){
        self.coord = coord
    }
    
    func makeUIView(context: UIViewRepresentableContext<StaticMKView>) -> MKMapView {
        var mapview = MKMapView()
        let centerRegion = MKCoordinateRegion(center: self.coord, latitudinalMeters: 100, longitudinalMeters: 100)
        mapview.region = centerRegion
        var point = MKPointAnnotation()
        point.coordinate = self.coord
        mapview.addAnnotation(point)
        return mapview
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }

}


struct MapView: View {
    @State var manager = CLLocationManager()
    @State var alert = false
//    @Binding var coordinate:CLLocationCoordinate2D
    @EnvironmentObject var mainStates:AppStates
    var body: some View {
//        MKView(manager: self.$manager, alert: self.$alert, coordinate: self.$coordinate).alert(isPresented: self.$alert) { () -> Alert in
//            Alert(title: Text("Please Enable your location services"))
        MKView(manager: self.$manager, alert: self.$alert).alert(isPresented: self.$alert) { () -> Alert in
            Alert(title: Text("Please Enable your location services"))
        }
    }
}

struct MKView:UIViewRepresentable{
    @Binding var manager:CLLocationManager
    @Binding var alert:Bool
    @EnvironmentObject var mainStates:AppStates
//    var mainStates:AppStates
//    @Binding var coordinate:CLLocationCoordinate2D
    let map = MKMapView()
    
    
    var coordinate:CLLocationCoordinate2D{
        get{
            return self.mainStates.coordinates
        }
        set{
            self.mainStates.coordinates = newValue
        }
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(self)
    }
    
    func makeUIView(context: UIViewRepresentableContext<MKView>) -> MKMapView  {
        let center = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
        let region = MKCoordinateRegion(center: center, latitudinalMeters: 1000, longitudinalMeters: 1000)
        self.map.region = region
        self.manager.requestWhenInUseAuthorization()
        self.manager.delegate = context.coordinator
        self.manager.startUpdatingLocation()
        return map
    }
    
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
    }
}

class MapCoordinator:NSObject,CLLocationManagerDelegate{
    var parent: MKView
    
    init(_ parent:MKView){
        self.parent = parent
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .denied{
            self.parent.alert.toggle()
        }
    }
    
    func absDiff(x:Float,y:Float) -> Float{
        return x >= y ? x - y : y - x
    }
    
    func updateCoordinate(coor:CLLocationCoordinate2D){

        if CLLocationCoordinate2D.hasChanged(self.parent.mainStates.coordinates, coor){
            self.parent.mainStates.coordinates = coor
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let point = MKPointAnnotation()
        
        let geocoder = CLGeocoder()
        if let SL = location{
            geocoder.reverseGeocodeLocation(SL) { (places, err) in
                guard let safePlaces = places else {
                    print("There was an error at MapView")
                    if let err = err?.localizedDescription{
                        print(err)
                    }
                    return
                }
                let place = safePlaces.first?.locality
                point.title = place
                point.subtitle = "Current"
                point.coordinate = SL.coordinate
                self.parent.map.removeAnnotations(self.parent.map.annotations)
                self.parent.map.addAnnotation(point)
                self.updateCoordinate(coor: SL.coordinate)
//                self.parent.coordinate = SL.coordinate
                let region = MKCoordinateRegion(center: SL.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                self.parent.map.region = region
            }
        }
    }
}

struct BasicMap:View{
    var attraction:AttractionModel
    
    var coordinates:CLLocationCoordinate2D{
        get{
            var result:CLLocationCoordinate2D = .init(latitude: 0.0, longitude: 0.0)
            if let lat = self.attraction.latitude, let lon = self.attraction.longitude{
                result.latitude = .init(Float(lat) ?? 0.0)
                result.longitude = .init(Float(lon) ?? 0.0)
            }
            return result
        }
    }
    
    
    var body:some View{
        BMView(title: self.attraction.name ?? "", coordinate: coordinates)
    }
}

struct BMView:UIViewRepresentable{
    
    var title:String
    var coordinate:CLLocationCoordinate2D
    var map = MKMapView()
    
    init(title:String,coordinate:CLLocationCoordinate2D){
        self.title = title
        self.coordinate = coordinate
//        print(self.coordinate)
    }
    
    func makeUIView(context: UIViewRepresentableContext<BMView>) -> MKMapView {
        print("Printing from makeUIView for BMView : \(self.coordinate)")
        let region = MKCoordinateRegion(center: self.coordinate, latitudinalMeters: .init(1000), longitudinalMeters: .init(1000))
        self.map.region = region
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        annotation.title = self.title
        self.map.addAnnotation(annotation)
        return self.map
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        let region = MKCoordinateRegion(center: self.coordinate, latitudinalMeters: .init(1000), longitudinalMeters: .init(1000))
        uiView.region = region
        let annotation = MKPointAnnotation()
        annotation.coordinate = self.coordinate
        annotation.title = self.title
        uiView.addAnnotation(annotation)
    }
    
    
}

//struct MapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MapView()
//    }
//}

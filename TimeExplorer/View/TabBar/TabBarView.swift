//
//  TabBarView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/19/20.
//

import SwiftUI

struct TabBarView: View {
    var tabs:[(name:String,icon:String)] = [(name:"home",icon:"house.fill"),(name:"blogs",icon:"newspaper"),(name:"feed",icon:"play.tv"),(name:"attractions",icon:"globe"),(name:"profile",icon:"person.fill")]
    @EnvironmentObject var mainStates:AppStates
    @State var tabMidPoints:[String:CGFloat] = [:]
    @Namespace var animation
    var tab:String{
        get{
            return self.mainStates.tab
        }

        set{
            self.mainStates.tab = newValue
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
    
    func selected(index:Int) -> Bool{
        return self.tabs[index].name == self.tab
    }
    
    var largeAddButton:some View{
        Button {
            self.mainStates.tab = "post"
        } label: {
            Image(systemName: "plus")
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .foregroundColor(.white)
                .padding()
                .background(
                    BlurView(style: .regular)
                        .background(Color.red)
                        .clipShape(Circle())
                        
                )
        }

        
        
    }
    
    func tabButton(name:String,icon:String,isSelected:Bool) -> some View{
        return GeometryReader{g -> AnyView in
            let midX = g.frame(in: .global).midX
            DispatchQueue.main.async {
                if !self.tabMidPoints.keys.contains(name){
                    self.tabMidPoints[name] = midX
                }
            }
            
            return AnyView(
                Button(action: {
                    withAnimation(.interactiveSpring(response: 0.6, dampingFraction: 0.6, blendDuration: 0.5)) {
                        self.mainStates.tab = name
                        self.mainStates.loading = true
                    }
                }, label: {
                    Image(systemName: icon)
                        .foregroundColor(isSelected ? .black : .white)
                        .frame(width: 10, height: 10, alignment: .center)
                        .padding()
                        .background(
                            ZStack{
                                Color.clear
                                if isSelected{
                                    Circle()
                                        .fill(Color.white)
                                        .matchedGeometryEffect(id: "highlight" , in: self.animation,properties: .position)
                                        .aspectRatio(contentMode: .fit)
                                }
                            }
                        )
                })
                
                
            )
            
        }.frame(width: AppWidth/5  - 20, height: 30, alignment: .center)
    }
    
    func getCurvePoint() -> CGFloat{
        let value = self.tabMidPoints[self.tab] ?? 10
        print("value : \(value)")
        return value 
    }
    
    var Tabs:some View{
        VStack {
            Spacer()
            HStack(spacing: 0){
                Spacer()
                ForEach(0..<self.tabs.count){i in
                    let isSelected = self.selected(index: i)
                    self.tabButton(name: self.tabs[i].name, icon: self.tabs[i].icon, isSelected: isSelected)
                        .padding(10)
                }
                Spacer()
            }
            .padding(.horizontal)
            .padding(.bottom,50)
            .frame(width: totalWidth)
        }
        .frame(width: totalWidth,height: totalHeight)
        .animation(.easeInOut)
    }
    
    var body: some View {
        self.Tabs
        
    }
}

//struct TabBarView_Previews: PreviewProvider {
////    @State static var loading:Bool = false
////    @State static var tab:String = ""
//    static var previews: some View {
//        TabBarView(tab: TabBarView_Previews.tab, loading: TabBarView_Previews.loading)
//    }
//}

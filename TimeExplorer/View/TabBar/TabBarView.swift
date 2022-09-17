//
//  TabBarView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/19/20.
//

import SwiftUI
import SUI

struct TabBarView: View {
    var tabs:[(name:String,icon:String)] = [(name:"home",icon:"house.fill"),(name:"blogs",icon:"newspaper"),(name:"feed",icon:"play.tv"),(name:"attractions",icon:"globe"),(name:"profile",icon:"person.fill")]
    @EnvironmentObject var mainStates:AppStates
//    @State var tabMidPoints:[String:CGFloat] = [:]
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
    
    func selected(_ name: String) -> Bool{
        return name == self.tab
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
		return Image(systemName: icon)
			.foregroundColor(isSelected ? .black : .white)
			.frame(size: .init(squared: 20))
			.padding(10)
			.background(isSelected ? Color.white : Color.gray.opacity(0.15))
			.clipShape(Circle())
			.fixedSize()
			.buttonify {
				self.mainStates.tab = name
				self.mainStates.loading = true
			}
	}
    
    var Tabs:some View{
		HStack(alignment: .center, spacing: 15) {
			ForEach(tabs, id: \.name){ tab in
				let isSelected = self.selected(tab.name)
				self.tabButton(name: tab.name, icon: tab.icon, isSelected: isSelected)
			}
		}
		.frame(alignment: .center)
		.padding()
		.background(BlurView(style: .dark))
		.clipShape(Capsule())
		.padding(.bottom, .safeAreaInsets.bottom)
		.fillWidth(alignment: .center)
		.fillHeight(alignment: .bottom)
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

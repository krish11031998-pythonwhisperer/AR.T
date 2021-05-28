//
//  TabBarButtons.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/4/20.
//

import SwiftUI

struct TabBarButtons: View {
    @Binding var bindingState:Bool
    var buttonName:String
    init(bindingState:Binding<Bool>,name:String = "arrow.turn.up.left"){
        self._bindingState = bindingState
        self.buttonName = name
    }
    var button:some View{
        Button {
            
            withAnimation(.easeInOut) {
                self.bindingState.toggle()
                print("Clicked the back button")
            }
        } label: {
            Image(systemName: self.buttonName)
                .resizable()
                .frame(width:15,height:15)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.white)
                .padding()
                .background(BlurView(style: .systemThinMaterialDark).clipShape(Circle()))
        }

        
    }
    var body: some View {
        
        self.button
        
    }
}

//struct TabBarButtons_Previews: PreviewProvider {
//    static var previews: some View {
//        TabBarButtons()
//    }
//}

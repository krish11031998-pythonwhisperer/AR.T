//
//  SVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/10/20.
//

import SwiftUI

struct SVMain: View {
    var stories:[String:[IPDNode]]
    @State var show:Bool = false
    @State var selected_stories:[IPDNode] = []
    var body: some View {
//        NavigationView{
        SVRows(stories: self.stories,show: self.$show,s_posts: self.$selected_stories)
//                .navigationBarHidden(true)
//                .navigationTitle("")

            .sheet(isPresented: self.$show, content: {
                /*@START_MENU_TOKEN@*//*@PLACEHOLDER=Content@*/Text("Sheet Content")/*@END_MENU_TOKEN@*/
            })
//        }
    }
}

struct SVMain_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            SVMain(stories: ["travelBerlin":IPDexamples])
//            Spacer()
        }
    }
}

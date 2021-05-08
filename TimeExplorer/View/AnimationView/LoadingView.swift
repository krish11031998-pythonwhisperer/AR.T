//
//  LoadingView.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/8/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack{
//            Color.clear.blur(radius: 10)
            BlurView(style: .regular)
            VStack(alignment: .center) {
                LottieView(filename: "loading").frame(width: 150, height: 150).padding(.all).background(RoundedRectangle(cornerRadius: 20).fill(Color.white))
            }
        }.edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}



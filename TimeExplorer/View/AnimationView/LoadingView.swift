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
            BlurView(style: .regular)
            LottieView(filename: "loading").frame(width: 150, height: 150)
        }.edgesIgnoringSafeArea(.all)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}



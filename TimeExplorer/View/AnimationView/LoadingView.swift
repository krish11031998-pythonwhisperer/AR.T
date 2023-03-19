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
            Color.black
            ProgressView()
                .frame(width: 100, height: 100, alignment: .center)
                //.progressViewStyle(.circular)
            
        }
        .edgesIgnoringSafeArea(.all)
        .fillFrame(alignment: .center)
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}



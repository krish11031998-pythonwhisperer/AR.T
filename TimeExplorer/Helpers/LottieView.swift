//
//  LottieView.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/7/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation
import SwiftUI
import Lottie

struct LottieView:UIViewRepresentable{
    typealias UIViewType = UIView
    var filename:String
    var loopMode:LottieLoopMode = .autoReverse
    
    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        var view = UIView(frame: .zero)
        let animatedView = AnimationView()
        let animation = Animation.named(filename)
        animatedView.animation = animation
        animatedView.contentMode = .scaleAspectFit
        animatedView.play()
        animatedView.loopMode = self.loopMode
        animatedView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(animatedView)
        NSLayoutConstraint.activate([
        
            animatedView.widthAnchor.constraint(equalTo: view.widthAnchor),
            animatedView.heightAnchor.constraint(equalTo: view.heightAnchor)
        ])
        return view

    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {
        
    }
    
    
    
    
    
    
}

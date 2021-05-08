//
//  YTView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 04/04/2021.
//

import SwiftUI

struct YTView: View {
    
    var size:CGSize
    @StateObject var playerState:YouTubeControlState = .init()
    @State var showVideoControl:Bool = false
    @State var videoState:ViewFrameType = .play
    
    init(size:CGSize){
        self.size = size
    }
    
    func videoControls_onEnded(width:CGFloat){
        var abs_width = abs(width)
        if abs_width > 50{
            if width > 0{
                print("Seeking backwards!")
                self.playerState.backward()
                self.videoState = .backward
            }else if width < 0{
                print("Seeking forwards")
                self.playerState.forward()
                self.videoState = .forward
            }
            self.showVideoControl.toggle()
        }
    }
    
    var body: some View {
        YouTubeView(playerState: self.playerState)
            .aspectRatio(contentMode: .fill)
            .frame(width: self.size.width, height: self.size.height, alignment: .center)
            .gesture(DragGesture()
                        .onEnded({ (value) in
                            var width = value.translation.width
                            self.videoControls_onEnded(width: width)
                        }))
            .gesture(TapGesture(count: 1)
                        .onEnded({
                            self.playerState.playPauseButtonTapped()
                            self.videoState = self.videoState == .play ? .pause : .play
                            self.showVideoControl.toggle()
                        }))
            .overlay(
                ZStack{
                    if self.showVideoControl{
                        LikeView($showVideoControl, self.$videoState)
                    }
                }
            )
    }
}

struct YTView_Previews: PreviewProvider {
    static var previews: some View {
        YTView(size: .init(width: totalWidth, height: totalHeight))
    }
}

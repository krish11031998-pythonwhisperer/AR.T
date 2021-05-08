//
//  YoutubePlayerHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 09/01/2021.
//

import SwiftUI
import Foundation
import UIKit
import AVFoundation
import AVKit
import YouTubePlayer


enum playerCommandToExecute:String {
    case loadNewVideo = "loadNewVideo"
    case play = "play"
    case pause = "pause"
    case forward = "forward"
    case backward = "backward"
    case stop = "stop"
    case idle = "idle"
    case mute = "mute"
    case unmute = "unmute"
}

class YouTubeControlState: ObservableObject {
  
    // 3
    @Published var videoID: String? // = "qRC4Vk6kisY"
    {
        // 4
        didSet {
            self.executeCommand = .loadNewVideo
        }
    }
  
    // 5
    @Published var videoState: playerCommandToExecute = .loadNewVideo
    
    @Published var audioState: playerCommandToExecute = .unmute
    
    // 6
    @Published var executeCommand: playerCommandToExecute = .idle
    
    // 7
    func playPauseButtonTapped() {
        if videoState == .play {
            pauseVideo()
        } else if videoState == .pause {
            playVideo()
        } else {
            print("Unknown player state, attempting playing")
            playVideo()
        }
    }
    
    // 8
    func playVideo() {
        executeCommand = .play
    }
    
    func pauseVideo() {
        executeCommand = .pause
    }
    
    func forward() {
        executeCommand = .forward
    }
    
    func backward() {
        executeCommand = .backward
    }
}



struct YouTubeView: UIViewRepresentable {
    // 2
    typealias UIViewType = YouTubePlayerView
    
    // 3
    @ObservedObject var playerState: YouTubeControlState
  
    // 4
    init(playerState: YouTubeControlState) {
        self.playerState = playerState
    }
        
    
    func makeCoordinator() -> Coordinator {
        Coordinator(playerState: self.playerState)
    }
    // 5
    func makeUIView(context: Context) -> UIViewType {
        let playerVars: [String:Any] = ["playsinline": 1]
        let ytVideo = YouTubePlayerView()
//        ytVideo.
        ytVideo.delegate = context.coordinator
        ytVideo.playerVars = playerVars as YouTubePlayerView.YouTubePlayerParameters
        
        return ytVideo
    }
      
    // 6
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
        guard let videoID = playerState.videoID else { return }
        //        uiView.loadVideoID(videoID)
        
        if self.playerState.executeCommand != .idle && uiView.ready{
            
            switch self.playerState.executeCommand{
                case .loadNewVideo:
                    self.playerState.executeCommand = .idle
                    uiView.loadVideoID(videoID)
                    
                case .play:
                    uiView.play()
                    
                case .pause:
                    uiView.pause()
                case .mute:
                    uiView.mute()
                case .unmute:
                    uiView.unMute()
                case .forward,.backward:
                    var condition = self.playerState.executeCommand == .forward
                    var seektime:Float = condition ? 10 : -10
                    uiView.getCurrentTime { (time) in
                        guard let time = time else {return}
                        uiView.seekTo(Float(time) + seektime, seekAhead: true)
                        
                    }
                default:
                    print("\(playerState.executeCommand) not yet implemented")
                
            }
            if self.playerState.executeCommand != .idle{
                self.playerState.executeCommand = .idle
            }
            
        }else if !uiView.ready{
            uiView.loadVideoID(videoID)
        }
    }
    
    class Coordinator:NSObject,YouTubePlayerDelegate{
        @ObservedObject var playerState: YouTubeControlState
        
        init(playerState: YouTubeControlState){
            self.playerState = playerState
            super.init()
        }
        
        func playerReady(_ videoPlayer: YouTubePlayerView) {
            videoPlayer.play()
            if self.playerState.audioState == .mute{
                videoPlayer.mute()
            }
            else if self.playerState.audioState != .mute{
                videoPlayer.unMute()
            }
            self.playerState.videoState = .play
            
            
        }
        
        func playerStateChanged(_ videoPlayer: YouTubePlayerView, playerState: YouTubePlayerState) {
            switch playerState{
                case .Playing:
                    self.playerState.videoState = .play
                case .Paused,.Buffering,.Unstarted:
                    self.playerState.videoState = .pause
                case .Ended:
                    self.playerState.videoState = .stop
                    self.playerState.videoID = nil
                default:
                    print("\(playerState) not implemented")
            }
        }

    }
}


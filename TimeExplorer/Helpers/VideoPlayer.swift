//
//  VideoPlayer.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/12/2020.
//

import Foundation
import UIKit
import AVFoundation
import AVKit
import SwiftUI
import XCDYouTubeKit

enum VideoStates{
    case play
    case pause
    case idle
    case seekBack
    case seekForward
    case ready
}

enum VideoQuality{
    case high
    case low
}

protocol VideoDict{
    subscript (_ vid:String) -> AVAsset? {get set}
}

struct VideoCache:VideoDict{
    let cache:NSCache<NSString,AVAsset> = {
        let cache = NSCache<NSString,AVAsset>()
        cache.countLimit = 100;
        cache.totalCostLimit = 1024 * 1024 * 200
        return cache
    }()
    
    subscript(vid: String) -> AVAsset? {
        get{
            guard let asset = self.cache.object(forKey: vid as NSString) else{return nil}
            return asset as AVAsset
        }
        
        set{
            guard let asset = newValue else {return}
            self.cache.setObject(asset, forKey: vid as NSString)
        }
    }
    
    static var shared:VideoCache = .init()
}

class AVPlayerObj:ObservableObject{
    @Published var videoState:VideoStates = .idle{
        didSet{
            self.updateVideoState(state: self.videoState)
        }
    }
    @Published var quality:VideoQuality = .high
    @Published var player:AVPlayer? = nil
    @Published var video_url:String?{
        didSet{
            self.initPlayer()
        }
    }
    @Published var video_id:String?{
        didSet{
            self.getVideo()
        }
    }

    func updateVideoState(state:VideoStates){
        switch(state){
            case .play:
                self.play()
            case .pause:
                self.pause()
            case .seekBack, .seekForward:
                self.seek()
            default:
                print("default !")
                break
        }
    }
    
    func initPlayer(){
        guard let vid_url = self.video_url, let url = URL(string: vid_url) else {return}
        var asset:AVAsset? = nil
        if let _asset = VideoCache.shared[vid_url]{
            asset = _asset
        }else{
            asset = AVAsset(url: url)
            VideoCache.shared[vid_url] = asset
        }
        DispatchQueue.main.async {
            guard let asset = asset else {return}
            self.player = .init(playerItem: .init(asset: asset))
            print("Got the Video from Firebase!")

        }
        
       
    }
    
    func getVideo(){
        guard let id = self.video_id else {return}
        if let asset = VideoCache.shared[id]{
            print("Got the URL from videoCache !")
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                self.player = .init(playerItem: .init(asset: asset))
                self.videoState = .ready
            }
        }else{
            XCDYouTubeClient.default().getVideoWithIdentifier(id) { (video, err) in
                guard let video = video, let streamURL = self.quality == .high ? video.streamURL : video.streamURLs[XCDYouTubeVideoQualityHTTPLiveStreaming] ?? video.streamURLs[XCDYouTubeVideoQuality.medium360.rawValue] ?? video.streamURLs[XCDYouTubeVideoQuality.small240.rawValue] else {return}
                DispatchQueue.main.async {
                    let asset = AVAsset(url: streamURL)
                    VideoCache.shared[streamURL.absoluteString] = asset
                    self.player = .init(playerItem: .init(asset: asset))
                    self.videoState = .ready
                }
            }
        }
    }
    
    func seek(handler:((VideoStates) -> Void)? = nil){
         if self.player != nil, let seconds = self.player?.currentTime().seconds{
            let curr_time = Float64(seconds)
            let diff = Float64(self.videoState == .seekBack ? -10 : 10)
            self.player!.seek(to: CMTimeMakeWithSeconds(curr_time + diff, preferredTimescale: 1),toleranceBefore: .zero,toleranceAfter: .zero)
            self.videoState = .play
        }
    }
    
    func play(){
        self.player?.play()
    }
    
    func pause(){
        self.player?.pause()
    }
}



struct PlayerView : UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    private var videoURL:URL?
    private var playVideo:Bool = true
    var player:AVPlayer? = nil
    var playerLayer:AVPlayerLayer? = nil
    var player_frame:CGRect? = nil
    
    init(videoURL:URL?, _ frame:CGRect = .init(x: 0, y: 0, width: 100, height: 100)) {
        self.videoURL = videoURL
        self.player_frame = frame
        if let asset = self.asset{
            self.player = self.setupAVPlayer()
            self.playerLayer = .init(player: self.player)
            self.player_frame = frame
        }
        
    }
    
    var vid_url:URL{
        get{
            return self.videoURL ?? URL(string: "") as! URL
        }
        set{
            self.videoURL = newValue
            if let asset = self.asset{
                self.player = self.setupAVPlayer()
                self.playerLayer = .init(player: self.player)
            }
        }
    }
    
    var changeStatus:Bool {
        get{
            return self.playVideo
        }
        set{
            self.playVideo = newValue
        }
    }
    
    var asset:AVAsset?{
        get{
            var asset:AVAsset? = nil
            guard let url = self.videoURL else {return asset}
            asset = AVAsset(url: url)
            return asset
        }
    }
    
    func stopVideo(){
        self.player?.rate = 0.0
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        var playerView = AVPlayerViewController()
        playerView.showsPlaybackControls = false
        if let player = self.player, let frame = self.player_frame{
            playerView.player = player
            playerView.view.frame = frame
            playerView.videoGravity = .resizeAspectFill
        }
        return playerView
    }
    
    
    func setupAVPlayer() -> AVPlayer?{
        var player:AVPlayer? = nil
//        if let asset = self.asset{
//            player = .init(playerItem: .init(asset: asset))
//            player?.volume = 50
//        }
        if let url = self.videoURL{
            player = .init(url: url)
        }
//        player = .init(url: self.videoURL)
        return player
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if !self.playVideo{
//            print("playVideo at updateUIViewController : \(self.playVideo)")
            uiViewController.player?.pause()
        }else{
            uiViewController.player?.play()
        }
    }
    
    
    class Coordinator:NSObject,AVPlayerViewControllerDelegate{
        
        var parent : PlayerView
        
        init(_ parent:PlayerView){
            self.parent = parent
            super.init()
            self.playerObserver()
        }
        
        func playerObserver(){
            if self.parent.player == nil {
                return
            }
            self.parent.player!.addObserver(self, forKeyPath: "status", options: [.old, .new], context: nil)
            if #available(iOS 10.0, *) {
                self.parent.player!.addObserver(self, forKeyPath: "timeControlStatus", options: [.old, .new], context: nil)
            } else {
                self.parent.player!.addObserver(self, forKeyPath: "rate", options: [.old, .new], context: nil)
            }
        }
        
        override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
            if let player = object as? AVPlayer, let key = keyPath{
                if key == "status"{
                    if player.status == .readyToPlay{
                        player.play()
                    }
                }
                if key == "timeControlStatus"{
                    if player.timeControlStatus == .paused && self.parent.changeStatus && player.rate > 0{
                        player.play()
                    }else if player.timeControlStatus == .playing{
//                        print("video is playing!")
                    }
                }
            }
        }
    }
}

struct SimpleVideoPlayer: UIViewControllerRepresentable{
    
    @Binding var playerState:VideoStates
    var player:AVPlayer
    var frame:CGRect
    init(player:AVPlayer,videoState:Binding<VideoStates>,frame:CGRect){
        self.player = player
        self._playerState = videoState
        self.frame = frame
    }
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerView = AVPlayerViewController()
        playerView.showsPlaybackControls = false
        playerView.player = self.player
        playerView.view.frame = self.frame
        playerView.videoGravity = .resizeAspect
        return playerView
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        switch(self.playerState){
            case .play:
                self.player.play()
            case .pause:
                self.player.pause()
            default:
                break
        }
    }
    
    
}




//
//  LargeVideoPlayerCard.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/09/2021.
//

import SwiftUI

struct LargeVideoPlayerCard: View {
    @StateObject var playerObject:AVPlayerObj = .init()
    var buttonName:String = ""
    var vid_url:String?
    @State var showButton:Bool = false
    var close:() -> Void
    init(vid_url:String? = nil,close:@escaping () -> Void){
        self.vid_url = vid_url
        self.close = close
    }
    
    var size:CGSize = .init(width: totalWidth, height: totalHeight)
    

    func onAppear(){
        if let vid_url = self.vid_url{
            self.playerObject.video_url = vid_url
        }
    }
    
    func onChanged(videoState:VideoStates){
        print("Video State: ",videoState)
        if videoState == .play && self.showButton{
            self.showButton = false
        }
    }
    
    
    func TogglePlayPause(){
        print("DEBUG Tap is being called!")
        DispatchQueue.main.async {
            print("DEBUG : VideoState before Tap : [\(self.playerObject.videoState)]")
            if self.playerObject.videoState == .play{
                self.playerObject.pause()
            }else{
                self.playerObject.play()
            }
            print("DEBUG : VideoState after Tap : [\(self.playerObject.videoState)]")
        }
        self.showButton = true
    }
    
    func onEnded(value:DragGesture.Value){
        let width = value.translation.width
        let abs_w = abs(width)
        if abs_w < 100 {return}
        print("DEBUG Width : ",width);
        DispatchQueue.main.async {
            self.playerObject.videoState = width < 0  ? .seekBack : .seekForward
        }
    }
    
    
    func closePlayer(){
        if self.playerObject.videoState != .pause{
            self.playerObject.pause()
        }
        
        self.close()
    }
    
    var buttonType:String{
        var buttonName:String;
        switch(self.playerObject.videoState){
            case .play:
                buttonName = "play.fill"
            case .pause:
                buttonName = "pause.fill"
            case .seekForward:
                buttonName = "forward.fill"
            case .seekBack:
                buttonName = "backward.fill"
            default:
                buttonName = "question"
        }
        print("DEBUG \(buttonName) : [\(self.playerObject.videoState)]");
        return buttonName
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.black
            if let player = self.playerObject.player{
                SimpleVideoPlayer(player: player, videoState: self.$playerObject.videoState, frame: .init(origin: .zero, size: self.size))
            }else{
                BlurView(style: .dark)
            }
            
            
            VStack(alignment: .center, spacing: 10) {
                SystemButton(b_name: "xmark", b_content: "", color: .white, haveBG: true,size: .init(width: 15, height: 15), bgcolor: .black, action: self.closePlayer).padding(20).padding(.vertical,50).frame(width: self.size.width, alignment: .leading)
                Spacer()
                if self.showButton{
                    SystemButton(b_name: self.buttonType, b_content: "",color: .white, haveBG: true, size: .init(width: 15, height: 15), bgcolor: .black) {
                        print("")
                    }.frame(width: self.size.width, alignment: .center)
                }
                Spacer()
                
            }.frame(width: self.size.width, height: self.size.height, alignment: .center)
            
        }.frame(width: self.size.width, height: self.size.height, alignment: .center)
        .onTapGesture(perform: self.TogglePlayPause)
        .gesture(DragGesture().onEnded(self.onEnded(value:)))
//        .onChange(of: self.playerObject.videoState, perform: self.onChanged(videoState:))
        .onAppear(perform: self.onAppear)
        
        
    }
}

//struct LargeVideoPlayerCard_Previews: PreviewProvider {
//    static var previews: some View {
//        LargeVideoPlayerCard()
//    }
//}

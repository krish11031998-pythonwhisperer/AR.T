//
//  ArtViewElements.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 14/04/2021.
//

import SwiftUI
import AVKit
struct ArtViewTab:View{
    var w:CGFloat
    var h:CGFloat
    var heading:String? = nil
    @Binding var tabNum:String
    var data:[(heading:String,detail:String,key:String?)]? = nil
    @Binding var playState:VideoStates
    init(w:CGFloat,h:CGFloat,heading:String?=nil,tabNum:Binding<String>? = nil,data:[(heading:String,detail:String,key:String?)]? = nil,playState:Binding<VideoStates>? = nil){
        self.w = w
        self.h = h
        self.heading = heading
        self._tabNum = tabNum ?? .constant("")
        self.data = data
        self._playState = playState ?? .constant(.idle)
    }
    var body: some View{
        let r_h = h
        return VStack(spacing:10){
            
            if self.heading != nil{
                MainText(content: self.heading! , fontSize: 25,color: .white,fontWeight: .semibold,addBG: true)
                    .padding()
                    .frame(width: w,height: 50, alignment: .topLeading)
            }
            if data != nil{
                TabView(selection: $tabNum){
                    ForEach(Array(data!.enumerated()), id: \.offset){ _d in
                        let d = _d.element
                        let key = d.key ?? String(describing: _d.offset)
                        FactCard(q: d.heading, ans: d.detail, width: w, height: r_h)
                            .tag(key)
                    }
                }.frame(width: w, height: r_h, alignment: .center)
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
            if data == nil{
                MainText(content: "No Info", fontSize: 20)
            }
            
        }.frame(width: w, height: h, alignment: .center)
    }
}

struct FactCard: View{
    var question:String
    var answer:String
    var width:CGFloat
    var height:CGFloat
    var vid_url:String?
    var mainCard:Bool
    @StateObject var synthesizer:SpeechModel
    @State var startedSpeaking:Bool = false
    @StateObject var playerObj:AVPlayerObj = .init()
    @State var showVideo:Bool = false
    @State var currentSentence:String = ""
    @State var currentSentCount:Int = 0
    var hasVideo:Bool
    
    init(q:String,ans:String,width:CGFloat,height:CGFloat,mainCard:Bool = false,vid_url:String? = nil){
        self._synthesizer = StateObject(wrappedValue: .init())
        self.question = q
        self.answer = ans
        self.width = width - 30
        self.height = height - 30
        self.hasVideo = vid_url != nil
        self.vid_url = vid_url
        self.mainCard = mainCard
    }
    
    var isSpeaking:Bool{
        print("isSpeaking:  \(self.synthesizer.isSpeaking)")
        return self.synthesizer.isSpeaking
    }
    
    func onAppear(){
        if let url_str = self.vid_url, let url = URL(string: url_str){
//            DispatchQueue.global(qos:.background).async {
                self.playerObj.video_url = url_str
//            }
        }
    }
    
    var sentence:[String]{
        var words:[String] = []
        var wordSet = Array<String>()
        var count = 0
        self.answer.components(separatedBy: " ").forEach { word in
            if count == 0 || count%10 != 0{
                wordSet.append(word)
                count += 1
            }else if count%10 == 0{
                words.append(wordSet.reduce("", { $0 + " " + $1}))
                wordSet.removeAll()
                count = 0
            }
        }
        return words
    }
    
    func playSpeechSynthesizer(){
        self.synthesizer.speak(speechText: self.answer)
//        print(self.isSpeaking)
    }
    
    func speechToggle(){
//        DispatchQueue.main.async {
        if self.startedSpeaking{
            if self.isSpeaking{
                
                self.synthesizer.pause()
                print("self.synthesizer.isSpeaking (pause): ",self.synthesizer.isSpeaking)
            }else{
                self.synthesizer.continueSpeaking()
                print("self.synthesizer.isSpeaking (continue): ",self.synthesizer.isSpeaking)
            }
        }else{
            self.playSpeechSynthesizer()
            self.startedSpeaking = true
        }
//        }
    }
    
    var speechPlayer:some View{
//        var buttonName =  self.isSpeaking ? "pause.fill" : "play.fill"
        print("self.synthesizer.isSpeaking  at speechPlayerView : ",self.synthesizer.isSpeaking)
        return SystemButton(b_name: self.synthesizer.isSpeaking ? "pause.fill" : "play.fill", b_content: "",action: self.speechToggle)
            
    }
    
    var videoPlayerButton:String{
        var res:String
        switch(self.playerObj.videoState){
            case .play,.seekBack,.seekForward:
                res = "pause.fill"
            case .ready,.pause,.idle:
                res = "play.fill"
            default:
                res = "pause.fill"
        }
        return res
    }
    
    func onChangeVideoState(state:VideoStates){
        switch(state){
        case .seekBack,.seekForward:
            self.playerObj.seek()
        case .play:
            self.playerObj.play()
        case.pause:
            self.playerObj.pause()
        default:
            self.playerObj.pause()
        }
    }
    
    func getCurrentSentence(word : String){
        let count = self.currentSentCount/10
        if self.currentSentCount%10 == 0 && count < self.sentence.count{
            self.currentSentence = self.sentence[count]
        }
        self.currentSentCount += 1
    }
    
    var videoPlayerControls:some View{
        return HStack(alignment: .center, spacing: 3) {
            SystemButton(b_name: "gobackward.10", b_content: "", color: .white,haveBG: true) {
                print("Seek Backwards !")
                DispatchQueue.main.async {
                    self.playerObj.videoState = .seekBack
                }
                
            }
            SystemButton(b_name: self.videoPlayerButton, b_content: "", color: .white,haveBG: true) {
                DispatchQueue.main.async {
                    self.playerObj.videoState = self.playerObj.videoState == .play ? .pause : .play
                }
            }
            SystemButton(b_name: "goforward.10", b_content: "", color: .white, haveBG: true) {
                print("Seek Forwards !")
                DispatchQueue.main.async {
                    self.playerObj.videoState = .seekForward
                }
            }
        }
    }
    
    var videoPlayBackControlView:some View{
        HStack(alignment: .center, spacing: 10) {
            MainText(content: self.question, fontSize: mainCard ? 25 : 15, color: .white, fontWeight: .semibold, style: .normal)
            if !self.mainCard{
                Spacer()
                
                if self.hasVideo{
                    self.videoPlayerControls
                }
                if !self.hasVideo{
                    SystemButton(b_name: self.synthesizer.isSpeaking ? "pause.fill" : "play.fill", b_content: "",action: self.speechToggle)
                }
                
            }
        }.padding()
        .frame(width: width, alignment: .topLeading)
//        .background(Color.red)
        .background(Color.clear)
        .animation(.easeInOut)
    }
    
    var videoPlayerView:some View{
        ZStack{
            if self.playerObj.player == nil{
                BlurView(style: .dark)
            }
            if self.playerObj.player != nil{
                SimpleVideoPlayer(player: self.playerObj.player!, videoState: self.$playerObj.videoState, frame: .init(x: 0, y: 0, width: width, height: height * 0.9))
            }
        }
        
    }
    
    var cardInfoBox:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: self.currentSentence, fontSize: mainCard ? 15 : 17 , color: .white, fontWeight: .regular, style: .normal)
                .padding()
                .padding(.vertical,10)
                .frame(width: self.width, alignment: .leading)
        }
        .frame(width: width, alignment: .topLeading)
        
    }
    
    var body: some View{
        
        VStack(alignment: .leading, spacing: 0) {
            if self.hasVideo{
                self.videoPlayerView
            }
            
            self.videoPlayBackControlView
            
            if !self.hasVideo{
                self.cardInfoBox
            }
        }
        .frame(width: self.width, height: self.height, alignment: .topLeading)
        .background(BlurView(style: .dark))
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .shadow(radius: 5)
        .padding()
        .animation(.easeInOut)
        .onAppear(perform: self.onAppear)
        .onChange(of: self.playerObj.videoState, perform: self.onChangeVideoState(state:))
//        .onReceive(self.synthesizer.$currentWord) { word in
//            let count = self.currentSentCount/10
//            if self.currentSentCount%10 == 0 && count < self.sentence.count{
//                self.currentSentence = self.sentence[count]
//            }
//            self.currentSentCount += 1
//        }

        .onReceive(self.synthesizer.$currentWord, perform: self.getCurrentSentence(word:))
        
    }
}

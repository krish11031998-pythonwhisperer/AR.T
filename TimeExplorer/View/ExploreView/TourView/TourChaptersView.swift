//
//  TourChaptersView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 08/01/2021.
//

import SwiftUI
import AVFoundation

struct TourChaptersView: View {
    var animation:Namespace.ID
    var tourChapter:HistoryChapters
    var synthesizer:AVSpeechSynthesizer = .init()
    @State var startedSpeaking:Bool = false
    @Binding var viewChapter:Bool

    init(_ tour:HistoryChapters, _ animation:Namespace.ID, _ view:Binding<Bool>){
        self.tourChapter = tour
        self.animation = animation
        self._viewChapter = view
    }
    
    func playSpeechSynthesizer(_ speechText:String){
        let utterance = AVSpeechUtterance(string: speechText)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        utterance.rate = 0.5

        synthesizer.speak(utterance)
    }
    
    func speechToggle(){
        if self.startedSpeaking{
            if self.synthesizer.isSpeaking{
                self.synthesizer.pauseSpeaking(at: .immediate)
            }else{
                synthesizer.continueSpeaking()
            }
        }else{
            if let speechText = self.tourChapter.speechText{
                self.playSpeechSynthesizer(speechText)
            }
            self.startedSpeaking.toggle()
            
        }
        
    }
    
    var img:String{
        get{
            return self.tourChapter.images?.first ?? self.tourChapter.image ?? ""
        }
    }
        
    var body: some View {
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            
            ZStack(alignment: .bottom) {
                ImageView(self.img, w, h, .fill)
                    .frame(alignment:.center)
//                    .matchedGeometryEffect(id: "img-\(self.tourChapter.title!)", in: self.animation)
                bottomShadow
                VStack(alignment: .leading, spacing: 10) {
                    HStack{
                        TabBarButtons(bindingState: self.$viewChapter)
                        Spacer()
                    }.padding(.top,25)
                    Spacer()
                    MainText(content: self.tourChapter.title ?? "", fontSize: 25, color: .white, fontWeight: .regular, style: .normal)
                    HStack{
                        Button {
                            withAnimation(.easeInOut) {
                                self.speechToggle()
                            }
                            
                        } label: {
                            var buttonName = self.synthesizer.isSpeaking ? "pause.fill" : "play.fill"

                            Image(systemName: buttonName)
                                .resizable()
                                .frame(width: 25, height: 25, alignment: .center)
                                .foregroundColor(.white)
                                .padding()
                                .background(Circle().stroke(Color.white, lineWidth: 2))
                                .animation(.easeInOut)
                        }
                    }
                }.padding(25).frame(width: w, height: h, alignment: .center)
            }
        }.frame(width: totalWidth, height: totalHeight, alignment: .center)
        .matchedGeometryEffect(id: "history-\(tourChapter.title!)", in: animation)
        
    }
}

//struct TourChaptersView_Previews: PreviewProvider {
//    static var previews: some View {
//        TourChaptersView()
//    }
//}

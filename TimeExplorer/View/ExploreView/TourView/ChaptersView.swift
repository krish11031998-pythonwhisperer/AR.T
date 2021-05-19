import SwiftUI
import AVFoundation
import ARKit
import SceneKit
import RealityKit
import SceneKit.ModelIO

struct ChapterView: View {
    @Environment (\.modalTransitionPercent) var pct:CGFloat
    var tourChapter:HistoryChapters
    var synthesizer:AVSpeechSynthesizer = .init()
    @State var startedSpeaking:Bool = false
    @Binding var viewChapter:Bool
    @State var showTranscript:Bool = false
    @State var model:MDLAsset? = nil
    @State var showModel:Bool = false
    @State var showARModel:Bool = false
    
    func modalParams(w:CGFloat) -> (CGSize,CGSize,CGFloat){
        let cardParams = VCardConstraints.chapterCard
        let init_img_h = cardParams.imgTargetHeight
        let init_cap_h = cardParams.captionHeight
        let init_w = cardParams.targetWidth
        let final_img_h = totalHeight * (self.showTranscript ?  0.5 : 0.6)
        let final_cap_h = totalHeight - final_img_h
        let final_w = w
        
        let radius = 30 * pct
        
        let img_diff = CGSize(width: final_w - init_w, height: final_img_h - init_img_h)
        let cap_diff = CGSize(width: final_w - init_w, height: final_cap_h - init_cap_h)
        
        let imgGrowSize:CGSize = .init(width: init_w + img_diff.width * pct, height: init_img_h + img_diff.height * pct)
        let capGrowSize:CGSize = .init(width: init_w + cap_diff.width * pct, height: init_cap_h + cap_diff.height * pct)
        
        return (imgGrowSize,capGrowSize,radius)
    }
    
    
    init(tour:HistoryChapters, view:Binding<Bool>){
        self.tourChapter = tour
        self._viewChapter = view
    }
    
    var speechText:String{
        get{
            guard let text = self.tourChapter.speechText else {return "No narration provided!"}
            return text
        }
    }
    
    var img:String{
        get{
            return self.tourChapter.images?.first ?? self.tourChapter.image ?? ""
        }
    }
    
    // MARK: - Scene View
    
    var speechData:[String]{
        get{
            var res = [self.speechText]
            if let fun_fact = self.tourChapter.fun_fact{
                res.append(fun_fact)
            }
            return res
        }
    }
    
    func header(w:CGFloat,h:CGFloat) -> some View{
        HStack{
            SystemButton(b_name: "arrow.turn.up.left", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                self.viewChapter.toggle()
            }
            Spacer()
            MainText(content: self.tourChapter.title ?? "Title", fontSize: 15, color: .white, fontWeight: .semibold, style: .normal)
                .padding()
                .fixedSize(horizontal: false, vertical: true)
                .background(BlurView(style: .dark).clipShape(RoundedRectangle(cornerRadius: 20)))
                .frame(height:h * 0.05)
            Spacer()
            SystemButton(b_name: "cube", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                self.showARModel.toggle()
            }

        }.padding().padding(.top,25)
        .zIndex(100)
    }
    
    // MARK: - Image View
    func imgView(w:CGFloat,imgSize:CGSize,radius:CGFloat) -> some View{
        let tabView = GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            ZStack(alignment:.top){
                if !showARModel{
                    ImageView(url: self.img, width: w, height: h, contentMode: .fill)
                        .clipShape(RoundedRectangle(cornerRadius: radius))
                        .frame(width: w, height: h, alignment: .center)
                }
                
                if self.showARModel && self.viewChapter{
                    SceneModelView(w: w, h: h, name: "Śmierć_eng.usdz", url_str: "https://firebasestorage.googleapis.com/v0/b/trippin-89b8b.appspot.com/o/models%2FS%CC%81mierc%CC%81_eng.usdz?alt=media&token=8828b4eb-2177-4e22-9033-2d1b5b67ad36")
                        .clipShape(RoundedRectangle(cornerRadius: radius))
                }
            }.overlay(
                self.header(w: w, h: h),alignment:.topLeading
            )
        }.padding(10).frame(width: imgSize.width, height: imgSize.height, alignment: .center)
            
            
        return tabView
    }
    
    
    var v2:some View{
        GeometryReader{g in
            let w = g.frame(in: .local).width
            let h = g.frame(in: .local).height
            
            var model_h = h * (self.showTranscript ? 0.475 : 0.7)
            let (imgSize,cap_Size,radius) = self.modalParams(w: w)
            VStack(alignment: .center, spacing: 10) {
                Spacer().frame(height: h * 0.025)
                self.imgView(w: w,imgSize: imgSize,radius: radius)
                TabView {
                    ForEach(self.speechData,id:\.self) { (text) in
                        NarrationView(text, showTranscript: $showTranscript, w: w - 20, h: h * (self.showTranscript ? 0.4 : 0.2) - 20)
                            .padding(10)
                    }
                }.frame(width: cap_Size.width, height: cap_Size.height, alignment: .center)
                
            }.frame(width: imgSize.width, height: imgSize.height + cap_Size.height, alignment: .center)
            .background(Color.white)
            .opacity(Double(pct))
        }
        .frame(width: totalWidth, height: totalHeight, alignment: .center)
        
    }
    
    var body: some View{
        self.v2
    }
}


struct NarrationView:View{
    var speechText:String
    var width:CGFloat
    var height:CGFloat
//    var synthesizer:AVSpeechSynthesizer = .init()
    @StateObject var synthesizer:SpeechModel = .init()
    @State var startedSpeaking:Bool = false
    @Binding var showTranscript:Bool
    var isSpeaking:Bool{
        get{
            return self.synthesizer.isSpeaking
        }
    }
    
    init(_ text:String = "",showTranscript:Binding<Bool>,w:CGFloat = AppWidth,h:CGFloat = totalHeight * 0.3){
        self.speechText = text
        self.width = w
        self.height = h
        self._showTranscript = showTranscript
    }
    
    
    func playSpeechSynthesizer(){
        self.synthesizer.speak(speechText: self.speechText)
        print(self.isSpeaking)
    }
    
    func speechToggle(){
        if self.startedSpeaking{
            if self.isSpeaking{
                self.synthesizer.pause()
                print("self.synthesizer.isSpeaking (pause): ",self.synthesizer.isSpeaking)
//                self.isSpeaking.toggle()
            }else{
                self.synthesizer.continueSpeaking()
                print("self.synthesizer.isSpeaking (continue): ",self.synthesizer.isSpeaking)
//                self.isSpeaking.toggle()
            }
        }else{
            self.playSpeechSynthesizer()
            self.startedSpeaking = true
        }
        
    }
    
    var speechPlayer:some View{
        var buttonName =  self.isSpeaking ? "pause.fill" : "play.fill"
        return HStack(alignment: .center, spacing: 10) {
            Image(systemName: buttonName)
                .resizable()
                .frame(width: 25, height: 25, alignment: .center)
                .foregroundColor(.white)
                .padding()
                .animation(.easeInOut)
                .onTapGesture {
                    self.speechToggle()
                    self.showTranscript.toggle()
                }
            Spacer()
        }.padding(10)
        .padding(.vertical)
        
    }
    
    var body: some View{
        GeometryReader{g in
            var w = g.frame(in: .local).width
            var h = g.frame(in: .local).height
            
            
            VStack(alignment: .leading, spacing: 10) {
                if self.showTranscript{
                    ScrollView(.vertical, showsIndicators: false) {
                        MainText(content: self.speechText, fontSize: 14, color: .black, fontWeight: .semibold, style: .normal)
                            .fixedSize(horizontal: false, vertical: true)
                    }.padding(.horizontal,7.5).padding(.top, 25).frame(width: w, height: h * 0.8, alignment: .center)
                }
                self.speechPlayer.frame(width: w,height: h * (self.showTranscript ? 0.2 : 0.5), alignment: .center).background(Color.red)
            }.background(Color.white).clipShape(RoundedRectangle(cornerRadius: 30)).shadow(radius: 5)
            
        }.frame(width: self.width,height: self.height, alignment: .center)
//        .frame(maxHeight: self.height)
        
    }
    
    
}



//struct ChaptersView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChaptersView()
//    }
//}

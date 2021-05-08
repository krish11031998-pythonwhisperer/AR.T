//
//  LikeView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 13/12/2020.
//

import SwiftUI

enum ViewFrameType{
    case like
    case play
    case pause
    case forward
    case backward
    case idle
//    case videoControl
}

struct LikeView: View {
    @Binding var type:ViewFrameType
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Binding var showLoading:Bool
    let timeLimit = 1
    @State var time:Float = 0.0
    
    init(_ showLoading:Binding<Bool>, _ type:Binding<ViewFrameType>? = nil){
        self._showLoading = showLoading
        if let _type = type{
            self._type = _type
        }else{
            self._type = Binding.constant(.like)
        }
    }
    
    func checkTime(){
        if self.time < 1{
            self.time += 0.1
        }else if self.time >= 1.0{
            self.time = 0
            self.showLoading.toggle()
            self.timer.upstream.connect().cancel()
        }
    }
    
    var likeView:some View{
        return LottieView(filename: "heart").frame(width: 100, height: 100, alignment: .center)
            .onReceive(timer, perform: { _ in
                checkTime()
        })

    }
    
    var videoControlView: some View{
        var videoControlImg:String = ""
        switch(self.type){
            case .play:
                videoControlImg = "play.fill"
                break;
            case .pause:
                videoControlImg = "pause.fill"
                break
            case .forward:
                videoControlImg = "forward.fill"
                break
            case .backward:
                videoControlImg = "backward.fill"
                break
            default:
                break
        }
        return Image(systemName: videoControlImg).frame(width: 25, height: 25, alignment: .center).foregroundColor(.white).padding().background(BlurView(style: .systemMaterialDark).clipShape(Circle()))
            .onReceive(timer, perform: { _ in
                checkTime()
            })

    }
    
    var body: some View {
        VStack {
            Spacer()
            if self.type == .like{
                self.likeView
            }
            if self.type != .like{
                self.videoControlView
            }
            Spacer()
        }
    }
}

//struct LikeView_Previews: PreviewProvider {
//    static var previews: some View {
////        LikeView()
//    }
//}

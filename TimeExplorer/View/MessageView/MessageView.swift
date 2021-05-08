//
//  MessageView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 25/12/2020.
//

import SwiftUI
import Combine
struct MessageView: View {
    @EnvironmentObject var mainStates:AppStates
    @State var textMessage:String = ""
    @State var edittingText:Bool = false
    //    @ObservedObject var keyboardHeightHelper = KeyboardHeightHelper()
    @State var keyBoardHeight:CGFloat = 0
    @Binding var showMessage:Bool
    @State var sendText:Bool = false
    @State var allMessages:[MessageData]
    var otherUser:String?
    var topHeadingHeight:CGFloat = totalHeight/6
    
    init(_ messages:[MessageData],_ otherUser:String, _ showConvo:Binding<Bool>){
        self.otherUser = otherUser
        self._showMessage = showConvo
        self._allMessages = State(initialValue: messages)
    }
    
    func sendMessage(){
        guard let sender = self.mainStates.userAcc.user.emailID, let receiver = self.otherUser, sendText else {return}
        var newMessage = MessageData(content: self.textMessage, date: Date(), sender: sender, receiver: receiver, isRead: false)
        MessageAPI.shared.sendMessage(newMessage)
        self.allMessages.append(newMessage)
    }
    
    var MessageEditor:some View{
        
        GeometryReader{g in
            var width = g.frame(in: .local).width
            var height = g.frame(in: .local).height
            HStack{
                if !self.edittingText{
                    self.buttonView(name: "photo.fill",size: width * 0.15, color: .blue)
                        .frame(width:width * 0.15)
                    self.buttonView(name: "camera.fill",size: width * 0.15,color: .blue)
                        .frame(width: width * 0.15)
                }
                TextField("Send Message", text: $textMessage) { (state) in
                    if state{
                        self.edittingText = true
                    }
                } onCommit: {
                    if self.edittingText{
                        self.edittingText = false
                    }
                }.padding().background(Capsule().stroke(Color.black, lineWidth: 2))
                if self.edittingText || self.textMessage != ""{
                    Button {
                        self.sendText = true
                        self.sendMessage()
                    } label: {
                        MainText(content: "Send", fontSize: 12, color: .blue, fontWeight: .semibold)
                            .padding()
                            .background(BlurView(style: .regular).clipShape(Capsule()))
                    }
                    
                }
            }.animation(.easeInOut)
        }.padding().frame(width:totalWidth,height:75)
        
    }
    
    func buttonView(name:String,size:CGFloat = 15,color:Color = .white) -> some View{
        return Image(systemName: name)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: size/2, height: size/2)
            .foregroundColor(color)
            .padding()
    }
    
    var otherUserName:String{
        get{
            var names = self.otherUser?.split(separator: " ").reduce("", { (res, word) -> String in
                return res + "\n" + word
            })
            return names ?? ""
        }
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            Image.userBG
                .resizable()
            VStack{
                HStack(alignment: .center) {
                    TabBarButtons(bindingState: self.$showMessage).padding().background(Circle().fill(Color.gray.opacity(0.35)))
                    MainText(content: "\(self.otherUserName)", fontSize: 30, color: .white, fontWeight: .regular, style: .heading)
                    Spacer()
                    self.buttonView(name: "video.fill",size: 50)
                    self.buttonView(name: "phone.fill",size: 50)
                }.padding().frame(width:totalWidth,height:self.topHeadingHeight)
                Spacer()
            }.frame(width: totalWidth, height: totalHeight)
            VStack{
                Spacer().frame(height:self.topHeadingHeight)
                VStack{
                    ScrollView(.vertical, showsIndicators: false) {
                        ForEach(Array(self.allMessages.enumerated()),id: \.offset) { (message) in
                            MessageCell(isCurrentUser: self.mainStates.userAcc.user.emailID == message.element.sender, message: message.element)
                        }
                        Spacer().frame(height:125)
                    }.padding(.vertical)
                }
                .background(Color.white.clipShape(Corners(rect: [.topLeft,.topRight],size: .init(width: 50, height: 50))))
                
            }.frame(width: totalWidth, height: totalHeight)
            VStack{
                var textFieldPadding = self.keyBoardHeight/3 + 25
                Spacer()
                self.MessageEditor
                    .padding(.bottom,textFieldPadding)
                    .background(BlurView(style: .regular))
                    .clipShape(Corners(rect: [.topLeft,.topRight], size: .init(width: 25, height: 25)))
            }.frame(width: totalWidth, height: totalHeight)
            
        }.edgesIgnoringSafeArea(.all)
        .navigationTitle("")
        .navigationBarHidden(true)
//        .onChange(of: self.sendText) { (sendText) in
//            guard let sender = self.mainStates.userAcc.user.emailID, let receiver = self.otherUser, sendText else {return}
//            var newMessage = MessageData(content: self.textMessage, date: Date(), sender: sender, receiver: receiver, isRead: false)
//            MessageAPI.shared.sendMessage(newMessage)
//            self.allMessages.append(newMessage)
//        }
        .onReceive(Publishers.keyboardHeight, perform: {self.keyBoardHeight = $0})
        
    }
}


struct MessageCell:View{
    var currentUser:Bool
    var message:MessageData
    var width:CGFloat = totalWidth * 0.75
    
    init(isCurrentUser currentUser:Bool,message:MessageData){
        self.currentUser = currentUser
        self.message = message
    }
    
    
    var messageCorners: UIRectCorner{
        get{
            return self.currentUser ? [.topLeft,.topRight,.bottomLeft] : [.topLeft,.topRight,.bottomRight]
        }
    }
    
    var body: some View{
        HStack(alignment:.top){
            if self.currentUser{
                Spacer()
            }
            MainText(content: self.message.content ?? "", fontSize: 12.5, color: .white, fontWeight: .regular)
                .fixedSize(horizontal: false, vertical: true)
                .padding()
                .frame(maxWidth: width)
                .aspectRatio(contentMode: .fit)
                .background(self.currentUser  ? Color.blue : Color.gray)
                .clipShape(Corners(rect: self.messageCorners, size: .init(width: 15, height: 15)))
            if !self.currentUser{
                Spacer()
            }
        }.padding(.horizontal).frame(width:totalWidth)
    }
}


//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
////        MessageView()
//    }
//}

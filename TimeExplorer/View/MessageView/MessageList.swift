//
//  MessageList.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 24/12/2020.
//

import SwiftUI

struct MessageList: View {
    @EnvironmentObject var mainStates:AppStates
    @StateObject var MAPI:MessageAPI = .init()
    @State var messages:[String:MessageData] = [:]
    @State var selectedUser:String = ""
    @State var showMessageChat:Bool = false
    init(){
//        self.MAPI.currentUser = self.mainStates.userAcc.user.id
    }
    
    var messagelist:some View{
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .center, spacing: 5) {
                ForEach(Array(self.messages.values)) { message in
                    Button {
                        self.selectedUser = (self.mainStates.userAcc.user.emailID == message.sender ? message.receiver : message.sender) ?? ""
                        self.showMessageChat.toggle()
                    } label: {
                        MessageListCell(message: message,currentUser: self.mainStates.userAcc.user)
                    }
                    Divider().padding().frame(width:AppWidth)
                }
            }
        }.padding(.vertical)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10){
            Spacer().frame(height:50)
            MainText(content: "Messages", fontSize: 30, color: .orange, fontWeight: .regular, style: .heading)
            self.messagelist
                .onAppear {
                    if self.messages.isEmpty, let email = self.mainStates.userAcc.user.emailID{
                        self.MAPI.getRecentMessages(email)
                    }
                }
                .onReceive(self.mainStates.userAcc.$user, perform: { (user) in
                    if let email = user.emailID, self.messages.isEmpty{
                        self.MAPI.getRecentMessages(email)
                    }
                })
                .onReceive(self.MAPI.$userMessages) { (messages) in
                    if !messages.isEmpty{
                        print("received Messages ! \(messages)")
                        messages.keys.forEach { (key) in
                            self.messages[key] = messages[key]?.last ?? .init()
                        }
//                        self.MAPI.getMessageUsers(Array(messages.keys))
                    }
                    self.mainStates.loading = false
                }
                .padding(.top)
            NavigationLink(destination: MessageView(self.MAPI.userMessages[self.selectedUser] ?? [], self.selectedUser, self.$showMessageChat), isActive: $showMessageChat) {
                Text("Hidden")
            }.hidden()
        }.padding(.horizontal).frame(width: totalWidth,height: totalHeight)
        .edgesIgnoringSafeArea(.all)
        
            
    }
}



struct MessageListCell:View{
    
    var message:MessageData
    var currentUser:User
    @StateObject var IMD:ImageDownloader = .init()
    @State var otherUser:User? = nil
    init(message:MessageData, currentUser:User){
        self.message = message
        self.currentUser = currentUser
    }
    
    var timeSince:String{
        get{
            if let date = self.message.date{
                return Float(date.timeIntervalSince(date)/60*60).toString()
            }
            return ""
        }
    }
    var otherUserID:String{
        get{
            return self.message.sender == self.currentUser.emailID ? self.message.receiver ?? "" : self.message.sender ?? ""
        }
    }
    
    var body: some View{
        GeometryReader{g in
            var width = g.frame(in: .local).width
            var height = g.frame(in: .local).height
            var image = self.IMD.image
            var ar = UIImage.aspectRatio(img: image)
            VStack(alignment: .leading, spacing: 10){
                HStack(alignment: .center, spacing: 10) {
                    
                    Image(uiImage: image ?? .stockImage)
                        .resizable()
                        .aspectRatio(ar, contentMode: .fill)
                        .frame(width: width * 0.2, height: height ,alignment: .center)
                        .cornerRadius(25)
                    VStack(alignment: .leading, spacing: 10) {
                        HStack(alignment: .center, spacing: 10) {
                            MainText(content: self.otherUser?.fullName ?? "", fontSize: 15, color: .black, fontWeight: .medium)
                            Spacer()
                            MainText(content: self.timeSince, fontSize: 10, color: .black, fontWeight: .medium)
                        }
                        MainText(content: self.message.content ?? "", fontSize: 15, color: .black, fontWeight: .regular)
                    }.padding().frame(width: width * 0.7, height: height)
                    Spacer()
                }
            }.padding(1.5).frame(width: width, height: height, alignment: .leading)
            
        }.padding().frame(width:totalWidth,height:totalHeight * 0.1)
        .onAppear {
            if UserAPI.Cache.keys.contains(self.otherUserID){
                self.otherUser = UserAPI.Cache[self.otherUserID]
            }else{
                UserAPI.shared.getUser(self.otherUserID) { (user) in
                    self.otherUser = user
                }
            }
        }
        .onChange(of: self.otherUser?.photoURL) { (url) in
            if let url = url , self.IMD.url != url{
                print("PhotoURL : \(url)")
                self.IMD.getImage(url: url)
            }
        }
        
    }
    
    
    
    
}

struct MessageList_Previews: PreviewProvider {
    static var previews: some View {
        MessageList()
    }
}

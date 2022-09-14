//
//  LVLogin.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/16/20.
//

import SwiftUI

enum UserSigning:String{
    case signUp = "Sign Up"
    case signIn = "Sign In"
}



struct LVLogin: View {
    @State var type:UserSigning = .signIn
    @State var email:String = ""
    @State var pwd:String = ""
    @State var re_pwd:String = ""
    @State var showError:Bool = false
    @EnvironmentObject var mainStates:AppStates
    var handler: ((Bool) -> Void)
    func textField(_ placeholder:String, _ S:Binding<String>,pass:Bool = false) -> some View{
        return Group{
            if pass{
                SecureField(placeholder, text: S)
            }else{
                TextField(placeholder, text: S)
            }
        }.foregroundColor(.black)
            .frame(width:AppWidth - 50)
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).strokeBorder(Color.gray, lineWidth: 2))
        
    }
    
    var signIn:some View{
        VStack(spacing:20){
            self.textField("Email ID", self.$email)
            self.textField("Password", self.$pwd,pass: true)
        }
    }
    
    
    var signUp:some View{
        VStack(spacing:20){
            self.textField("Email ID", self.$email)
            self.textField("Password", self.$pwd,pass: true)
            self.textField("Re-Enter Password", self.$re_pwd,pass: true)
        }
    }
    
    var error:Bool{
        get{
            return self.mainStates.userAcc.error != ""
        }
    }
    
    func verify(){
        if type == .signIn{
            self.mainStates.userAcc.login(self.email, self.pwd){ value in
                if !value{
                    self.showError.toggle()
                }else{
                    self.handler(value)
                }
            }
        }else if type == .signUp{
            self.mainStates.userAcc.register("", self.email, self.pwd){value in
                if !value{
                    self.showError.toggle()
                }
            }
        }
    }
    
    var errorModal:some View{
        VStack(alignment:.leading,spacing:20){
            MainText(content: "Error", fontSize: 25, color: .black, fontWeight: .bold)
            MainText(content: self.mainStates.userAcc.error, fontSize: 17.5, color: .black, fontWeight: .regular)
            Button {
                self.showError.toggle()
                self.email = ""
                self.pwd = ""
                self.re_pwd = ""
                self.mainStates.userAcc.error = ""
            } label: {
                MainText(content: "Dismiss", fontSize: 10, color: .white, fontWeight: .bold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
            }
            
        }.padding().background(RoundedRectangle(cornerRadius: 25).fill(Color.white).shadow(radius: 15))
    }
    
    var pageText:String{
        get{
            return self.type != .signIn ? "Login" : "Register"
        }
    }
    
    var mainBody: some View {
        VStack(alignment:.center,spacing:25){
            Spacer().frame(height:75)
            HStack{
                Button(action: {
                    self.type = self.type == .signIn ? .signUp : .signIn
                    
                }, label: {
                    MainText(content: self.pageText, fontSize: 20, color: .red, fontWeight: .semibold)
                })
                
                Spacer()
            }.padding(.horizontal)
            Spacer()
            MainText(content: "\(self.type.rawValue)", fontSize: 25, color: .purple, fontWeight: .bold)
                .fixedSize(horizontal: false, vertical: true)
            if type == .signIn{
                self.signIn
            }
            if type == .signUp{
                self.signUp
            }
            Button {
                self.verify()
            } label: {
                MainText(content: self.type.rawValue, fontSize: 20, color: .white, fontWeight: .semibold)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.red))
            }
            Spacer()
        }.frame(height:totalHeight)
    }
    
    var body: some View{
        ZStack(alignment: .center){
			Color.white
            self.mainBody
            if self.showError{
                self.errorModal
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct LVLogin_Previews: PreviewProvider {
    @State static var uA:Bool = false
    static var previews: some View {
        //        LVLogin(userAuthenicated: LVLogin_Previews.$uA)
        LVLogin(){value in
//            print(value)
            
        }
    }
}

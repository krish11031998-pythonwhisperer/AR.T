//
//  BlogPostView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/23/20.
//

import SwiftUI

struct BlogPostView: View {
    @EnvironmentObject var mainStates:AppStates
    @State var showPicker:Bool = false
    @State var selectedImages:[IDImage] = []
    @State var selectedImage:UIImage = .init()
    @StateObject var BAPI:BlogAPI = .init()
    var pickerView:some View{
        InstaImagePicker(.single, self.$showPicker, selectedImages: self.$selectedImages) {
            print("Done!")
            if let firstImage = self.selectedImages.first?.image{
                self.selectedImage = firstImage
            }
            self.showPicker.toggle()
        }
    }
    
    func onCommit(images:[UIImage],title:String,summary:String,article:String){
        self.BAPI.newBlog(images, title: title, summary: summary, article: article, user: self.mainStates.userAcc.username){ status in
            print("The status of blogUpload : \(status)")
        }
    }
    
    var mainView:some View{
        ScrollView{
            BlogImagesView(selectedImage: self.$selectedImage,showPicker: self.$showPicker, onCommit: onCommit)
        }
    }
    
    var body: some View {
        ZStack{
            self.mainView
            NavigationLink(destination: InstaImagePicker(.single, self.$showPicker, selectedImages: self.$selectedImages) {
                print("Done!")
                if let firstImage = self.selectedImages.first?.image{
                    self.selectedImage = firstImage
                }
            }, isActive: self.$showPicker){
                Text("")
            }.hidden()
            .navigationTitle("Add New Blog!")
        }
    }
}

struct BlogImagesView:View{
    @State var images:[Int:UIImage] = [:]
    var colLayout = [GridItem.init(.flexible(minimum: 125, maximum: 125)),GridItem.init(.flexible(minimum: 125, maximum: 125))]
    @State var title:String = ""
    @State var summary:String = ""
    @State var article:String = ""
    @Binding var selectedImage:UIImage
    @State var selectedImageIndex:Int = -1
    @Binding var showPicker:Bool
    var onCommit: (([UIImage],String,String,String) -> Void)
    
    func imageGridItem(_ i:Int) -> some View{
        let image = self.images[i] ?? .init()
        let view = RoundedRectangle(cornerRadius: 25)
            .fill(Color.gray.opacity(0.15))
            .frame(width:125,height:200)
            .aspectRatio(contentMode: .fill)
            .overlay(
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width:125,height:200)
                    .cornerRadius(25.0)
            )
        return view
    }
    
    var ImageGrid:some View{
        ScrollView(.horizontal,showsIndicators: false, content: {
            HStack{
                ForEach(0..<6){index in
                    Button(action: {
                        self.selectedImageIndex = index
                        self.showPicker.toggle()
                    }, label: {
                        self.imageGridItem(index)
                    })
                }
            }.padding()
        }).frame(width:AppWidth)
    }
    
    func textField(_ title:String, _ S:Binding<String>,height:CGFloat = 100,lineLimit:Int = 2) -> some View{
        var view = TextEditor(text: S)
            .lineLimit(lineLimit)
            .frame(height: height, alignment: .top)
            .padding()
            .background(RoundedRectangle(cornerRadius: 25).fill(Color.white).shadow(radius: 5))
            .foregroundColor(.black)
            .onTapGesture {
                self.resignFirstResponder()
            }
        return view
    }
    
    func resignFirstResponder() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var blogForm:some View{
        VStack(alignment:.leading,spacing:50){
            self.textField("Add Title", self.$title,height:50,lineLimit: 1)
            self.textField("Add Summary", self.$summary,height:100,lineLimit: 3)
            self.textField("Add Article Piece", self.$article,height:250,lineLimit: 20)
            self.doneButton
            Spacer().frame(height:100)
        }.frame(width: AppWidth)
    }
    var doneButton:some View{
        HStack{
            Spacer()
            Button(action: {
                self.onCommit(Array(self.images.values),self.title,self.summary,self.article)
            }, label: {
                MainText(content: "Done", fontSize: 15, color: .black, fontWeight: .regular)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 25).fill(Color.gray.opacity(0.35)))
            })
            Spacer()
        }
    }
    
    var body: some View{
        VStack{
            self.ImageGrid.padding()
            self.blogForm
            
        }.onChange(of: self.selectedImage) { (image) in
            print("selectedImageIndex : \(self.selectedImageIndex)")
            self.images[self.selectedImageIndex] = image
        }
        .padding()
    }
}


struct BlogPostView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            BlogPostView()
        }
        
    }
}

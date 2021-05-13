//
//  InfoCard.swift
//  VerticalScroll
//
//  Created by Krishna Venkatramani on 13/05/2021.
//

import SwiftUI

let monaLisaDescription = "Mona Lisa, also called Portrait of Lisa Gherardini, wife of Francesco del Giocondo, Italian La Gioconda, or French La Joconde, oil painting on a poplar wood panel by Leonardo da Vinci, probably the world’s most famous painting. It was painted sometime between 1503 and 1519, when Leonardo was living in Florence, and it now hangs in the Louvre Museum, Paris, where it remained an object of pilgrimage in the 21st century. The sitter’s mysterious smile and her unproven identity have made the painting a source of ongoing investigation and fascination."

struct InfoCard: View {
    var data:ExploreData
    var width:CGFloat = totalWidth
    var height:CGFloat = totalHeight
    @Binding var selectedCard:Int
    
    init(data:ExploreData,selectedCard:Binding<Int>){
        self.data = data
        self._selectedCard = selectedCard
    }
    
    var info:(heading:String,subheadline:String,name:String,description:String)?{
        if let blog = self.data.data as? BlogData{
            return (heading:blog.headline ?? "No Headline",subheadline:"",name:blog.user ?? "No User",description: blog.articleText ?? "NO text")
        }else if let post = self.data.data as? PostData{
            return (heading: post.caption,subheadline:"",name:post.user ?? "", description: "")
        }else{
            return nil
        }
    }
    
    func validText(str:String,options:(design:Font.Design,size:CGFloat,weight:Font.Weight)) -> AnyView?{
        if str != ""{
            return AnyView(BasicText(content: str, fontDesign: options.design, size: options.size, weight: options.weight))
        }
        return AnyView(Color.clear.frame(width: 1, height: 1, alignment: .center))
    }
    
    var card: some View{
        VStack(alignment: .leading, spacing: 10) {
            HStack{
                self.validText(str: self.info!.heading, options: (design: .serif, size: 20, weight: .regular))
//                BasicText(content: self.info!.heading, fontDesign: .serif, size: 20, weight: .regular)
                Spacer()
                SystemButton(b_name: "xmark", b_content: "", color: .white, haveBG: true, bgcolor: .black) {
                    if self.selectedCard != -1{
                        self.selectedCard = -1
                    }
                }
            }
            self.validText(str: self.info!.subheadline, options: (design: .rounded, size: 15, weight: .regular))
            self.validText(str: "by \(self.info!.name)", options: (design: .serif, size: 10, weight: .medium))
            self.validText(str: self.info!.description, options: (design: .rounded, size: 12, weight: .regular))
            Spacer()
        }
        .padding()
        .frame(width: width, height: height * 0.325, alignment: .center)
        .background(BlurView(style: .regular))
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
            if self.info != nil{
                self.card
            }
            
        }.frame(width: width, height: height, alignment: .center)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.5))
    }
}

//struct InfoCard_Previews: PreviewProvider {
//    static var previews: some View {
//        InfoCard(width: totalWidth, height: totalHeight * 0.4, selectedCard: .constant(0))
//    }
//}

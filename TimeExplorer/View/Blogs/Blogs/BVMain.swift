//
//  BVMain.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 06/04/2021.
//

import SwiftUI

struct BVMain: View {
    @EnvironmentObject var mainStates:AppStates
    @State var selectedBlog:BlogData? = nil
    @StateObject var BAPI:BlogAPI = .init()
    
    var url_str:String?{
        get{
            return self.BAPI.blogs.first?.image?.first
        }
    }
    
    func getBlogs(){
        if self.BAPI.blogs.isEmpty{
            self.BAPI.getTopBlogs(limit: -1)
        }
    }
    
    var topBlog:some View{
        VStack(alignment: .leading, spacing: 10){
            MainText(content: "Top Blog", fontSize: 25, color: .black, fontWeight: .bold, style: .normal).frame(alignment: .topLeading)
            ImageView(url: self.url_str, width: AppWidth, height: totalHeight * 0.4, contentMode: .fill, testMode:true)
                .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    var remainingBlogs:some View{
        VStack(alignment: .center, spacing: 10){
            ForEach(Array(self.BAPI.blogs.enumerated()), id:\.offset) {  _blog in
                var blog = _blog.element
                FancyCard(data: blog.parseToFancyCardData(), constraints: .chapterCard,showImgOverlay: false) { (data) in
                    if let blogData = data as? BlogData{
                        self.selectedBlog = blogData
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false){
            MainText(content: "Blogs", fontSize: 35, color: .black, fontWeight: .bold, style: .heading)
                .padding(25)
                .frame(width:totalWidth,alignment: .topLeading)
                .padding(.top,50)
            if !self.BAPI.blogs.isEmpty{
                self.topBlog
                TrendingBlogs(blogs: self.BAPI.blogs, selectedBlog: .constant(.init()), showBlog: .constant(false), width: AppWidth, height: totalHeight * 0.8)
                    .padding(.vertical,10)
                self.remainingBlogs
            }
            Spacer().frame(height: 200)
            
        }.onAppear(perform: self.getBlogs)
        .onReceive(self.BAPI.$blogs, perform: { blogs in self.mainStates.loading = false})
        .navigationTitle("")
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea(.all)
        
    }
}

struct BVMain_Previews: PreviewProvider {
    static var previews: some View {
        BVMain()
    }
}

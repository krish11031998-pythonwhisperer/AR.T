//
//  RefreshScrollView.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 11/21/20.
//

import Foundation
import SwiftUI


struct RefreshScrollView:UIViewRepresentable{
    @EnvironmentObject var mainStates: AppStates
    
    var manager:PostAPI = .init()
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self, self.manager)
    }
    
    
    
    func makeUIView(context: Context) -> UIScrollView {
        var scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
        print("Updating the scrollView!")
    }
    
    class Coordinator:NSObject{
        var refreshingScrollView: RefreshScrollView
        var PAPI:PostAPI
        
        init(_ RSV:RefreshScrollView,_ PAPI:PostAPI){
            self.refreshingScrollView = RSV
            self.PAPI = PAPI
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl){
            sender.endRefreshing()
            if let postIds = self.refreshingScrollView.mainStates.userAcc.user.posts{
//                self.PAPI.getMoreData(posts: postIds)
            }
        }
    }
}


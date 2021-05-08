//
//  TimeExplorerApp.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 9/18/20.
//

import SwiftUI
import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TimeExplorerApp: App {
    @StateObject var mainStates:AppStates = .init()     
    init(){
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            AppView().environmentObject(mainStates)
        }
    }
}

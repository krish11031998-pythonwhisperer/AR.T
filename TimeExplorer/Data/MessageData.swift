//
//  MessageData.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 24/12/2020.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift


struct MessageData:Codable,Identifiable{
    @DocumentID var id:String?
    var content:String?
    var date:Date?
    var sender:String?
    var receiver:String?
    var isRead:Bool?
}


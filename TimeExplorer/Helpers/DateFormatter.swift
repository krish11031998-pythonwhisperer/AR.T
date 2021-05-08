//
//  DateFormatter.swift
//  MyExplorer
//
//  Created by Krishna Venkatramani on 9/4/20.
//  Copyright © 2020 Team Krish. All rights reserved.
//

import Foundation

extension Date{
    
    func stringDate() -> String{
        var formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM YYYY"
        return formatter.string(from: self)
    }
}

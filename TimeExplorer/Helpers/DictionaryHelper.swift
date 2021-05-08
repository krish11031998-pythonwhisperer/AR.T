//
//  DictionaryHelper.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/04/2021.
//

import Foundation

extension Dictionary{
    
    func findKey(for value:Any) -> Any?{
        var dict = self
        var key:Any? = nil
        dict.keys.forEach { (key) in
            if let val = dict[key] as? Any{
                if value == val{
                    
                }
            }
        }
    }
}

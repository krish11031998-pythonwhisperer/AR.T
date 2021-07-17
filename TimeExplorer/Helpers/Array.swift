//
//  Array.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 10/07/2021.
//

import Foundation

extension Array{
    mutating func appendToTop(arr:Array<Element>){
        let og = self
        self = arr
        og.forEach({self.append($0)})
    }
}

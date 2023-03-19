//
//  View.swift
//  TimeExplorer
//
//  Created by Krishna Venkatramani on 19/03/2023.
//

import Foundation
import SwiftUI

struct CustomDivider: View {
    
    let color: Color
    
    init(color: Color = .gray) {
        self.color = color
    }
    
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(height: 1)
    }
}

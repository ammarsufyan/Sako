//
//  Item.swift
//  Sako
//
//  Created by Ammar Sufyan on 26/03/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

//
//  TransactionCategory.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation
import SwiftData

@Model
class TransactionCategory {
    var name: String
    var emoji: String
    var type: TransactionType
    
    init(emoji: String, name: String, type: TransactionType) {
        self.emoji = emoji
        self.name = name
        self.type = type
    }
}

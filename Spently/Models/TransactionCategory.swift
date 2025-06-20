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
    var ordinal: Int
    
    init(emoji: String, name: String, type: TransactionType, ordinal: Int) {
        self.emoji = emoji
        self.name = name
        self.type = type
        self.ordinal = ordinal
    }
    
    var typeName: String {
        type.rawValue
    }
    
    static let defaultCategories: [TransactionCategory] = [
        .init(emoji: "💰", name: "Salary", type: .income, ordinal: 1000),
        .init(emoji: "💸", name: "Transfer", type: .income, ordinal: 1001),
        .init(emoji: "📈", name: "Investments", type: .income, ordinal: 1002),
        .init(emoji: "💡", name: "Other", type: .income, ordinal: 1003),
        
        .init(emoji: "🍔", name: "Food", type: .expense, ordinal: 1000),
        .init(emoji: "🏠", name: "Housing", type: .expense, ordinal: 1001),
        .init(emoji: "📊", name: "Insurance", type: .expense, ordinal: 1002),
        .init(emoji: "🍿", name: "Entertainment", type: .expense, ordinal: 1003),
        .init(emoji: "🛍️", name: "Shopping", type: .expense, ordinal: 1004),
        .init(emoji: "💊", name: "Health", type: .expense, ordinal: 1005),
        .init(emoji: "📚", name: "Education", type: .expense, ordinal: 1006),
        .init(emoji: "✈️", name: "Travel", type: .expense, ordinal: 1007),
        .init(emoji: "💸", name: "Loans", type: .expense, ordinal: 1008),
        .init(emoji: "💡", name: "Other", type: .expense, ordinal: 1009),
    ]
}

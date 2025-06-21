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
        
        .init(emoji: "🍔", name: "Food", type: .expense, ordinal: 2000),
        .init(emoji: "🏠", name: "Housing", type: .expense, ordinal: 2001),
        .init(emoji: "📊", name: "Insurance", type: .expense, ordinal: 2002),
        .init(emoji: "🍿", name: "Entertainment", type: .expense, ordinal: 2003),
        .init(emoji: "🛍️", name: "Shopping", type: .expense, ordinal: 2004),
        .init(emoji: "💊", name: "Health", type: .expense, ordinal: 2005),
        .init(emoji: "📚", name: "Education", type: .expense, ordinal: 2006),
        .init(emoji: "✈️", name: "Travel", type: .expense, ordinal: 2007),
        .init(emoji: "💸", name: "Loans", type: .expense, ordinal: 2008),
        .init(emoji: "💡", name: "Other", type: .expense, ordinal: 2009),
    ]
    
    static func startOrdinal(for type: TransactionType) -> Int {
        switch type {
        case .income: 1000
        case .expense: 2000
        }
    }
}

//
//  SampleObjects.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation
import SwiftData

struct SampleObjects {
    static let expenseCategory = TransactionCategory(emoji: "🛒", name: "Groceries", type: .expense, ordinal: 0)
    
    static let expenseRecord = TransactionRecord(amount: .init(floatLiteral: 123.45), currencyCode: "CNY", notes: "Some notes that is really long it will take more than one line, so it might look kinda weird", category: expenseCategory, timestamp: Calendar.current.startOfDay(for: .now))
    
    static let incomeCategory = TransactionCategory(emoji: "💰", name: "Salary", type: .income, ordinal: 0)
    
    static let incomeRecord = TransactionRecord(amount: .init(floatLiteral: 56.78), currencyCode: "CNY", notes: "For half a year", category: incomeCategory, timestamp: Calendar.current.date(byAdding: .day, value: -10, to: .now)!)
    
    private static let modelConfiguration = ModelConfiguration(isStoredInMemoryOnly: true)
    
    static let modelContainer = try? ModelContainer(for: TransactionRecord.self, configurations: modelConfiguration)
    
    @MainActor static let modelContext = modelContainer?.mainContext
    
    static var incomeCategories: [TransactionCategory] {
        get {
            (1...10).map { i in TransactionCategory(emoji: "❓", name: "Category \(i)", type: .income, ordinal: i) }
        }
    }
}

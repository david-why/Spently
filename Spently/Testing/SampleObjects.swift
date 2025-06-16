//
//  SampleObjects.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation

struct SampleObjects {
    static let expenseCategory = TransactionCategory(emoji: "🛒", name: "Groceries", type: .expense)
    
    static let expenseRecord = TransactionRecord(amount: .init(floatLiteral: 123.45), currency: .init("cny"), notes: "Some notes that is really long it will take more than one line, so it might look kinda weird", category: expenseCategory, timestamp: Calendar.current.startOfDay(for: .now))
    
    static let incomeCategory = TransactionCategory(emoji: "💰", name: "Salary", type: .income)
    
    static let incomeRecord = TransactionRecord(amount: .init(floatLiteral: 56.78), currency: .init("usd"), notes: "For half a year", category: incomeCategory, timestamp: Calendar.current.date(byAdding: .day, value: 10, to: .now)!)
}

//
//  TransactionType.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation

enum TransactionType: String, Codable, CaseIterable {
    case income = "income"
    case expense = "expense"

    var sign: String {
        switch self {
        case .income: "+"
        case .expense: "-"
        }
    }
    
    var displayName: String {
        switch self {
        case .income: "Income"
        case .expense: "Expense"
        }
    }
}

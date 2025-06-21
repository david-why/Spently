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
    
    var localizedName: String {
        switch self {
        case .income: String(localized: "Income")
        case .expense: String(localized: "Expense")
        }
    }
}

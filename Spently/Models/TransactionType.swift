//
//  TransactionType.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation

enum TransactionType: Int, Codable, CaseIterable {
    case income = 1000
    case expense = 2000

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

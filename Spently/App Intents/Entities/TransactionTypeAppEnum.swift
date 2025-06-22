//
//  TransactionTypeAppEnum.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation
import AppIntents

enum TransactionTypeAppEnum: String, AppEnum {
    case income
    case expense
    
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Type")
    
    static let caseDisplayRepresentations: [Self : DisplayRepresentation] = [
        income: "Income",
        expense: "Expense"
    ]
    
    init(from type: TransactionType) {
        switch type {
        case .income: self = .income
        case .expense: self = .expense
        }
    }
    
    var transactionType: TransactionType {
        switch self {
        case .income: .income
        case .expense: .expense
        }
    }
}

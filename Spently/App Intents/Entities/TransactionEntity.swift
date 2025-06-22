//
//  TransactionEntity.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import AppIntents
import SwiftData

struct TransactionEntity: AppEntity {
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Transaction", numericFormat: "\(placeholder: .int) transactions")
    }
    
    static let defaultQuery = TransactionEntityQuery()
    
    var id: UUID
    
    @Property var amount: Double
    
    @Property var notes: String

    @Property var categoryName: String
    
    @Property var categoryType: TransactionType.RawValue
    
    @Property var timestamp: Date
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(categoryType == TransactionType.expense.rawValue ? "-" : "+")\(amount)",
            subtitle: "\(categoryName)"
        )
    }
    
    init(transaction: TransactionRecord) {
        self.id = transaction.id
        self.amount = Double(truncating: transaction.amount as NSNumber)
        self.notes = transaction.notes
        self.categoryName = transaction.category.name
        self.categoryType = transaction.category.type.rawValue
        self.timestamp = transaction.timestamp
    }
}

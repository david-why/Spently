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
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction", numericFormat: "\(placeholder: .int) transactions")
    
    static let defaultQuery = TransactionEntityQuery()
    
    var id: UUID
    
    @Property var amount: Double
    
    @Property var notes: String

    @Property var category: CategoryEntity
    
    @Property var timestamp: Date
    
    var displayRepresentation: DisplayRepresentation {
        let currencyCode = UserDefaults.standard.string(forKey: "currency") ?? "USD"
        return DisplayRepresentation(
            title: "\(category.type.transactionType == TransactionType.expense ? "-" : "+")\(amount.formatted(.currency(code: currencyCode)))",
            subtitle: "\(category.emoji) \(category.name)"
        )
    }
    
    init(transaction: TransactionRecord) {
        self.id = transaction.id
        self.amount = Double(truncating: transaction.amount as NSNumber)
        self.notes = transaction.notes
        self.category = CategoryEntity(category: transaction.category)
        self.timestamp = transaction.timestamp
    }
}

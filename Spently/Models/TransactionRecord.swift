//
//  TransactionRecord.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import Foundation
import SwiftData

@Model
class TransactionRecord {
    var amount: Decimal
    var currency: Locale.Currency
    var notes: String
    var category: TransactionCategory
    var timestamp: Date
    
    init(amount: Decimal, currency: Locale.Currency, notes: String, category: TransactionCategory, timestamp: Date) {
        self.amount = amount
        self.currency = currency
        self.notes = notes
        self.category = category
        self.timestamp = timestamp
    }
}

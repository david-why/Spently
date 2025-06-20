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
    var currencyCode: String
    var notes: String
    var category: TransactionCategory
    var timestamp: Date
    
    init(amount: Decimal, currencyCode: String, notes: String, category: TransactionCategory, timestamp: Date) {
        self.amount = amount
        self.currencyCode = currencyCode
        self.notes = notes
        self.category = category
        self.timestamp = timestamp
    }
    
    var currency: Locale.Currency {
        get {
            .init(currencyCode)
        }
        set {
            currencyCode = newValue.identifier
        }
    }
}

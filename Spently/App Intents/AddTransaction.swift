//
//  AddTransactionIntent.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import AppIntents
import SwiftData

struct AddTransaction: AppIntent {
    static let title: LocalizedStringResource = "Add Transaction"
    static let description = IntentDescription("Adds an income or expense transaction to your list.")
    
    static var parameterSummary: some ParameterSummary {
        Summary("Add a transaction")
    }
    
    @Parameter var amount: Double
    
    @Dependency
    private var modelContainer: ModelContainer
    
    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<TransactionEntity> {
        let context = modelContainer.mainContext
        let transaction = TransactionRecord(amount: 111.11, notes: "Added from Shortcuts", category: .defaultCategories[0], timestamp: .now)
        context.insert(transaction)
        let entity = TransactionEntity(transaction: transaction)
        return .result(value: entity)
    }
}

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
        Summary("Add a \(\.$category) transaction for \(\.$amount)") {
            \.$notes
        }
    }
    
    @Parameter var amount: Double
    
    @Parameter(optionsProvider: CategoryOptionsProvider()) var category: CategoryEntity
    
    @Parameter var notes: String?
    
    @Dependency
    private var modelContainer: ModelContainer
    
    @MainActor func perform() async throws -> some IntentResult & ReturnsValue<TransactionEntity> {
        print("perform with args:", amount, category)
        let context = modelContainer.mainContext
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>())
        guard let category = categories.first(where: { $0.id == category.id }) else {
            throw AddTransactionError.categoryNotFound
        }
        let transaction = TransactionRecord(amount: NSNumber(floatLiteral: amount).decimalValue, notes: notes ?? "", category: category, timestamp: .now)
        context.insert(transaction)
        try? context.save()
        let entity = TransactionEntity(transaction: transaction)
        return .result(value: entity)
    }
}

enum AddTransactionError: Error, CustomLocalizedStringResourceConvertible {
    case categoryNotFound
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .categoryNotFound:
            return "The provided category is not found."
        }
    }
}

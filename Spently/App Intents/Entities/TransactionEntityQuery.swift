//
//  TransactionEntityQuery.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import AppIntents
import SwiftData

struct TransactionEntityQuery: EntityQuery {
    @Dependency var modelContainer: ModelContainer
    
    @MainActor func entities(for identifiers: [UUID]) async throws -> [TransactionEntity] {
        let context = modelContainer.mainContext
        return try identifiers.compactMap { id in
            try context.fetch(FetchDescriptor<TransactionRecord>(predicate: #Predicate { $0.id == id })).first.map(TransactionEntity.init)
        }
    }
}

extension TransactionEntityQuery: EntityPropertyQuery {
    static let properties = QueryProperties {
        Property(\TransactionEntity.$amount) {
            EqualToComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount == decimal }
            }
            NotEqualToComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount != decimal }
            }
            LessThanOrEqualToComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount <= decimal }
            }
            GreaterThanOrEqualToComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount >= decimal }
            }
            LessThanComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount < decimal }
            }
            GreaterThanComparator { value in
                let decimal = NSNumber(floatLiteral: value).decimalValue
                return #Predicate<TransactionRecord> { $0.amount > decimal }
            }
        }
    }
    
    static let sortingOptions = SortingOptions {
        SortableBy(\TransactionEntity.$amount)
        SortableBy(\TransactionEntity.$timestamp)
    }
    
    @MainActor func entities(matching comparators: [Predicate<TransactionRecord>],
                             mode: ComparatorMode,
                             sortedBy: [EntityQuerySort<TransactionEntity>],
                             limit: Int?) async throws -> [TransactionEntity] {
        let context = modelContainer.mainContext
        let initialValue = mode == .and ? true : false
        let predicate = comparators.reduce(#Predicate<TransactionRecord> { _ in initialValue }, mode == .and ? { a, b in #Predicate { a.evaluate($0) && b.evaluate($0) } } : { a, b in #Predicate { a.evaluate($0) || b.evaluate($0) } })
        let records = try context.fetch(FetchDescriptor<TransactionRecord>(predicate: predicate))
        var entities = records.map(TransactionEntity.init)
        let sortComparators = sortedBy.compactMap { sort -> KeyPathComparator<TransactionEntity>? in
            let order: SortOrder = sort.order == .ascending ? .forward : .reverse
            switch sort.by {
            case \.$amount: return KeyPathComparator(\.amount, order: order)
            case \.$timestamp: return KeyPathComparator(\.timestamp, order: order)
            default: return nil
            }
        }
        entities.sort(using: sortComparators)
        return entities
    }
}

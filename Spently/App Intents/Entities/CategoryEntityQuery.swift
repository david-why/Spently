//
//  CategoryEntityQuery.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation
import AppIntents
import SwiftData

struct CategoryEntityQuery: EntityQuery {
    @Dependency var modelContainer: ModelContainer
    
    @MainActor func entities(for identifiers: [UUID]) async throws -> [CategoryEntity] {
        let context = modelContainer.mainContext
        return try identifiers.compactMap { id in
            try context.fetch(FetchDescriptor<TransactionCategory>(predicate: #Predicate { $0.id == id })).first.map(CategoryEntity.init)
        }
    }
}

extension CategoryEntityQuery: EntityPropertyQuery {
    static var properties = QueryProperties {
        Property(\CategoryEntity.$type) {
            EqualToComparator { value in
                let type = value.transactionType.rawValue
                return #Predicate { $0.typeInt == type }
            }
            NotEqualToComparator { value in
                let type = value.transactionType.rawValue
                return #Predicate { $0.typeInt != type }
            }
        }
        Property(\CategoryEntity.$name) {
            EqualToComparator { value in
                #Predicate { $0.name == value }
            }
            NotEqualToComparator { value in
                #Predicate { $0.name == value }
            }
        }
    }
    
    static let sortingOptions = SortingOptions {
        SortableBy(\.$type)
        SortableBy(\.$name)
    }
    
    @MainActor
    func entities(matching comparators: [Predicate<TransactionCategory>],
                  mode: ComparatorMode,
                  sortedBy: [EntityQuerySort<CategoryEntity>],
                  limit: Int?) async throws -> [CategoryEntity] {
        let context = modelContainer.mainContext
        let predicate = mode == .and ? comparators.combined() : comparators.combinedOr()
        let sortDescriptors = sortedBy.compactMap { sort in
            let order: SortOrder = sort.order == .ascending ? .forward : .reverse
            switch sort.by {
            case \.$type: return SortDescriptor(\TransactionCategory.typeInt, order: order)
            case \.$name: return SortDescriptor(\TransactionCategory.name, order: order)
            default: return nil
            }
        }
        let categories = try context.fetch(FetchDescriptor<TransactionCategory>(predicate: predicate, sortBy: sortDescriptors))
        return categories.map(CategoryEntity.init)
    }
}

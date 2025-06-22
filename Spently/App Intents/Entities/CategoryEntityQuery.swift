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

// FIXME: Filter based on type doesn't work. Bug in iOS?
extension CategoryEntityQuery: EnumerableEntityQuery {
    @MainActor func allEntities() async throws -> [CategoryEntity] {
        return try modelContainer.mainContext.fetch(FetchDescriptor<TransactionCategory>()).map(CategoryEntity.init)
    }
}

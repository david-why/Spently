//
//  CategoryOptionsProvider.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation
import AppIntents
import SwiftData

struct CategoryOptionsProvider: DynamicOptionsProvider {
    @Dependency var modelContainer: ModelContainer
    
    @MainActor func results() async throws -> [CategoryEntity] {
        try modelContainer.mainContext.fetch(FetchDescriptor<TransactionCategory>()).map(CategoryEntity.init)
    }
}

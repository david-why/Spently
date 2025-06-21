//
//  Migration.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import SwiftData

enum SpentlySchemaV1: VersionedSchema {
    static var versionIdentifier = Schema.Version(1, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TransactionRecord.self, TransactionCategory.self]
    }
    
    @Model
    class TransactionRecord {
        var amount: Decimal
        var currencyCode: String
        var notes: String
        var category: TransactionCategory!
        var timestamp: Date
        
        init(amount: Decimal, currencyCode: String, notes: String, category: TransactionCategory, timestamp: Date) {
            self.amount = amount
            self.currencyCode = currencyCode
            self.notes = notes
            self.category = category
            self.timestamp = timestamp
        }
    }
    
    @Model
    class TransactionCategory {
        var name: String
        var emoji: String
        var type: TransactionType
        var ordinal: Int
        @Relationship(inverse: \TransactionRecord.category) var records: [TransactionRecord]
        
        init(emoji: String, name: String, type: TransactionType, ordinal: Int, records: [TransactionRecord] = []) {
            self.emoji = emoji
            self.name = name
            self.type = type
            self.ordinal = ordinal
            self.records = records
        }
    }
    
    enum TransactionType: String, Codable, CaseIterable {
        case income = "income"
        case expense = "expense"
    }
}

enum SpentlySchemaV2: VersionedSchema {
    static var versionIdentifier = Schema.Version(2, 0, 0)
    
    static var models: [any PersistentModel.Type] {
        [TransactionRecord.self, TransactionCategory.self]
    }
}

enum SpentlyMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [SpentlySchemaV1.self, SpentlySchemaV2.self]
    }
    
    static var stages: [MigrationStage] {
        [migrateV1toV2]
    }
    
    static var oldCategoriesV1: [SpentlySchemaV1.TransactionCategory] = []
    static var categoryIDToRecordIDs: [PersistentIdentifier : [PersistentIdentifier]] = [:]
    
    static let migrateV1toV2 = MigrationStage.custom(
        fromVersion: SpentlySchemaV1.self,
        toVersion: SpentlySchemaV2.self,
        willMigrate: { context in
            print("WILL MIGRATE")
            oldCategoriesV1 = try context.fetch(FetchDescriptor<SpentlySchemaV1.TransactionCategory>())
            categoryIDToRecordIDs.removeAll()
            oldCategoriesV1.forEach {
                categoryIDToRecordIDs[$0.persistentModelID] = $0.records.map { $0.persistentModelID }
            }
            try context.delete(model: SpentlySchemaV1.TransactionCategory.self)
        },
        didMigrate: { context in
            print("DID MIGRATE")
            for oldCategory in oldCategoriesV1 {
                let ids = categoryIDToRecordIDs[oldCategory.persistentModelID]
                let records = try categoryIDToRecordIDs[oldCategory.persistentModelID]?.compactMap { id in
                    try context.fetch(FetchDescriptor<TransactionRecord>(predicate: #Predicate { $0.persistentModelID == id })).first
                } ?? []
                let newCategory = TransactionCategory(emoji: oldCategory.emoji, name: oldCategory.name, type: oldCategory.type.rawValue == "expense" ? .expense : .income, ordinal: oldCategory.ordinal, records: records)
                context.insert(newCategory)
            }
            try context.save()
        }
    )
}

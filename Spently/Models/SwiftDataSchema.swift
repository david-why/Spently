//
//  Migration.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import SwiftData
import AppIntents

enum SpentlySchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)
    
    static let models: [any PersistentModel.Type] = [TransactionRecord.self, TransactionCategory.self]
    
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
        @Relationship(deleteRule: .cascade, inverse: \TransactionRecord.category) var records: [TransactionRecord]
        
        init(emoji: String, name: String, type: TransactionType, ordinal: Int, records: [TransactionRecord] = []) {
            self.emoji = emoji
            self.name = name
            self.type = type
            self.ordinal = ordinal
            self.records = records
        }
    }
    
    enum TransactionType: Int, Codable {
        case income = 1000
        case expense = 2000
    }
}

enum SpentlySchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)
    
    static let models: [any PersistentModel.Type] = [TransactionRecord.self, TransactionCategory.self]
    
    @Model
    class TransactionRecord {
        var id = UUID()
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
        @Relationship(deleteRule: .cascade, inverse: \TransactionRecord.category) var records: [TransactionRecord]
        
        init(emoji: String, name: String, type: TransactionType, ordinal: Int, records: [TransactionRecord] = []) {
            self.emoji = emoji
            self.name = name
            self.type = type
            self.ordinal = ordinal
            self.records = records
        }
    }
    
    enum TransactionType: Int, Codable {
        case income = 1000
        case expense = 2000
    }
}

enum SpentlySchemaV3: VersionedSchema {
    static let versionIdentifier = Schema.Version(3, 0, 0)
    
    static let models: [any PersistentModel.Type] = [TransactionRecord.self, TransactionCategory.self]
    
    @Model
    class TransactionRecord {
        var id = UUID()
        var amount: Decimal
        var notes: String
        var category: TransactionCategory!
        var timestamp: Date
        
        init(amount: Decimal, notes: String, category: TransactionCategory, timestamp: Date) {
            self.amount = amount
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
        @Relationship(deleteRule: .cascade, inverse: \TransactionRecord.category) var records: [TransactionRecord]
        
        init(emoji: String, name: String, type: TransactionType, ordinal: Int, records: [TransactionRecord] = []) {
            self.emoji = emoji
            self.name = name
            self.type = type
            self.ordinal = ordinal
            self.records = records
        }
    }
    
    enum TransactionType: Int, Codable {
        case income = 1000
        case expense = 2000
    }
}

enum SpentlySchemaV4: VersionedSchema {
    static let versionIdentifier = Schema.Version(4, 0, 0)
    
    static let models: [any PersistentModel.Type] = [TransactionRecord.self, TransactionCategory.self]
    
    @Model
    class TransactionRecord {
        var id = UUID()
        var amount: Decimal
        var notes: String
        var category: TransactionCategory!
        var timestamp: Date
        
        init(amount: Decimal, notes: String, category: TransactionCategory, timestamp: Date) {
            self.amount = amount
            self.notes = notes
            self.category = category
            self.timestamp = timestamp
        }
    }
    
    @Model
    class TransactionCategory {
        var id = UUID()
        var name: String
        var emoji: String
        var type: TransactionType
        var ordinal: Int
        @Relationship(deleteRule: .cascade, inverse: \TransactionRecord.category) var records: [TransactionRecord]
        
        init(emoji: String, name: String, type: TransactionType, ordinal: Int, records: [TransactionRecord] = []) {
            self.emoji = emoji
            self.name = name
            self.type = type
            self.ordinal = ordinal
            self.records = records
        }
        
        static let defaultCategories: [TransactionCategory] = [
            .init(emoji: "💰", name: "Salary", type: .income, ordinal: 1000),
            .init(emoji: "💸", name: "Transfer", type: .income, ordinal: 1001),
            .init(emoji: "📈", name: "Investments", type: .income, ordinal: 1002),
            .init(emoji: "💡", name: "Other", type: .income, ordinal: 1003),
            
            .init(emoji: "🍔", name: "Food", type: .expense, ordinal: 2000),
            .init(emoji: "🏠", name: "Housing", type: .expense, ordinal: 2001),
            .init(emoji: "📊", name: "Insurance", type: .expense, ordinal: 2002),
            .init(emoji: "🍿", name: "Entertainment", type: .expense, ordinal: 2003),
            .init(emoji: "🛍️", name: "Shopping", type: .expense, ordinal: 2004),
            .init(emoji: "💊", name: "Health", type: .expense, ordinal: 2005),
            .init(emoji: "📚", name: "Education", type: .expense, ordinal: 2006),
            .init(emoji: "✈️", name: "Travel", type: .expense, ordinal: 2007),
            .init(emoji: "💸", name: "Loans", type: .expense, ordinal: 2008),
            .init(emoji: "💡", name: "Other", type: .expense, ordinal: 2009),
        ]
        
        static func startOrdinal(for type: TransactionType) -> Int {
            type.rawValue
        }
    }
    
    enum TransactionType: Int, Codable, CaseIterable, AppEnum {
        
        case income = 1000
        case expense = 2000

        var sign: String {
            switch self {
            case .income: "+"
            case .expense: "-"
            }
        }
        
        var localizedName: String {
            switch self {
            case .income: String(localized: "Income")
            case .expense: String(localized: "Expense")
            }
        }
        
        static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Type")
        
        static let caseDisplayRepresentations: [TransactionType : DisplayRepresentation] = [
            income: "Income",
            expense: "Expense",
        ]
    }
}

enum SpentlyMigrationPlan: SchemaMigrationPlan {
    static let schemas: [any VersionedSchema.Type] = [
        SpentlySchemaV1.self,
        SpentlySchemaV2.self,
        SpentlySchemaV3.self,
        SpentlySchemaV4.self
    ]
    
    static let stages = [migrateV1toV2, migrateV2toV3, migrateV3toV4]
    
    static let migrateV1toV2 = MigrationStage.lightweight(
        fromVersion: SpentlySchemaV1.self,
        toVersion: SpentlySchemaV2.self
    )
    
    static let migrateV2toV3 = MigrationStage.lightweight(
        fromVersion: SpentlySchemaV2.self,
        toVersion: SpentlySchemaV3.self
    )
    
    static let migrateV3toV4 = MigrationStage.lightweight(
        fromVersion: SpentlySchemaV3.self,
        toVersion: SpentlySchemaV4.self
    )
}

typealias TransactionRecord = SpentlySchemaV4.TransactionRecord

typealias TransactionCategory = SpentlySchemaV4.TransactionCategory

typealias TransactionType = SpentlySchemaV4.TransactionType

//
//  CategoryEntity.swift
//  Spently
//
//  Created by David Wang on 2025/6/22.
//

import Foundation
import AppIntents
import SwiftData

struct CategoryEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Transaction Category", numericFormat: "\(placeholder: .int) categories")
    
    static let defaultQuery = CategoryEntityQuery()
    
    var id: UUID
    
    @Property var type: TransactionType
    
    @Property var name: String
    
    @Property var emoji: String
    
    var displayRepresentation: DisplayRepresentation {
        let imageData = emoji.image.pngData()
        return DisplayRepresentation(
            title: "\(name)",
            subtitle: type.localizedStringResource,
            image: imageData == nil ? nil : .init(data: imageData!)
        )
    }
    
    init(category: TransactionCategory) {
        self.id = category.id
        self.type = category.type
        self.name = category.name
        self.emoji = category.emoji
    }
}

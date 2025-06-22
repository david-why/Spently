//
//  SpentlyApp.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData
import AppIntents

@main
struct SpentlyApp: App {
    private var modelContainer: ModelContainer
    
    init() {
        let modelContainer = try! ModelContainer(
            for: TransactionRecord.self, TransactionCategory.self,
            migrationPlan: SpentlyMigrationPlan.self
        )
        self.modelContainer = modelContainer
        AppDependencyManager.shared.add(dependency: modelContainer)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

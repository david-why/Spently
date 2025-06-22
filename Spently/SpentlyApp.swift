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
        
        // Dependencies for App Intents
        AppDependencyManager.shared.add(dependency: modelContainer)
        
        // Update list of shortcuts
        SpentlyShortcuts.updateAppShortcutParameters()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(modelContainer)
        }
    }
}

//
//  SpentlyApp.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData

@main
struct SpentlyApp: App {
    var body: some Scene {
        WindowGroup {
            let container = try? ModelContainer(
                for: Schema(versionedSchema: SpentlySchemaV2.self),
                migrationPlan: SpentlyMigrationPlan.self
            )
            
            ContentView()
                .modelContainer(container!)  // FIXME: Don't panic
        }
    }
}

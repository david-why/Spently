//
//  SpentlyApp.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI

@main
struct SpentlyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: TransactionRecord.self)
        }
    }
}

//
//  SpentlyShortcuts.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import Foundation
import AppIntents

class SpentlyShortcuts: AppShortcutsProvider {
    static let shortcutTileColor: ShortcutTileColor = .navy
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(intent: AddTransaction(), phrases: [], shortTitle: "Add Transaction", systemImageName: "plus.circle")
    }
}

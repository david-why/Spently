//
//  ContentView.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData

enum Tabs {
    case records
    case stats
    case settings
}

struct ContentView: View {
    @AppStorage("defaultCategoriesAdded") var defaultCategoriesAdded: Bool = false
    
    @Environment(\.modelContext) private var modelContext
    
    @State var tab: Tabs = .stats
    
    var body: some View {
        TabView(selection: $tab) {
            Tab("Transactions", systemImage: "doc.plaintext", value: .records) {
                RecordsPage()
            }
            Tab("Stats", systemImage: "chart.bar.fill", value: .stats) {
                StatsPage()
            }
            Tab("Settings", systemImage: "gear", value: .settings) {
                SettingsPage()
            }
        }
        .onAppear {
            if !defaultCategoriesAdded {
                _ = TransactionCategory.defaultCategories.map(modelContext.insert)
                defaultCategoriesAdded = true
            }
        }
    }
}

#Preview {
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TransactionRecord.self, configurations: configuration)
    let context = container.mainContext
    
    let _ = context.insert(SampleObjects.expenseRecord)
    let _ = context.insert(SampleObjects.incomeRecord)
    
    ContentView()
        .modelContainer(container)
}

#Preview("Empty") {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = TransactionCategory.defaultCategories.forEach(context.insert)
    
    ContentView()
        .modelContainer(container)
}

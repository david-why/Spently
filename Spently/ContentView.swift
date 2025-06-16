//
//  ContentView.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Records", systemImage: "list.bullet.rectangle") {
                RecordsPage()
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

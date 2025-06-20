//
//  RecordsPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData

struct RecordsPage: View {
    @Query(sort: \TransactionRecord.timestamp, order: .reverse) var records: [TransactionRecord]
    
    @Query(filter: #Predicate<TransactionRecord> { $0.amount == 0 }) var zeroRecords: [TransactionRecord]
    
    @State var addingRecord: TransactionRecord? = nil
    @State var navigationPath: [TransactionRecord.ID] = []
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List {
                if (records.isEmpty) {
                    emptyMessage
                }
                ForEach(recordSections, id: \.1) { section in
                    Section(section.1) {
                        ForEach(section.0) { record in
                            NavigationLink(value: record.id) {
                                TransactionView(record: record)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                ToolbarItemGroup {
                    Button("Add", systemImage: "plus") {
                        print("add thing")
                        let newRecord = TransactionRecord(amount: 0, currencyCode: Locale.current.currency?.identifier ?? "USD", notes: "", category: .defaultCategories[0], timestamp: .now)
                        modelContext.insert(newRecord)
                        do {
                            try modelContext.save()
                        } catch {
                            print("error in saving", error)
                        }
                        navigationPath.append(newRecord.id)
                    }
                }
            }
            .navigationDestination(for: TransactionRecord.ID.self) { recordID in
                if let record = records.filter({ $0.id == recordID }).first {
                    RecordDetailPage(record: record)
                }
            }
            .sheet(item: $addingRecord) { record in
                RecordDetailPage(record: record)
            }
            .onAppear {
                let _ = zeroRecords.map(modelContext.delete)
            }
        }
    }
    
    @ViewBuilder var emptyMessage: some View {
        Text("Welcome to ")
        + Text("Spently").bold()
        + Text("! Click the ")
        + Text(Image(systemName: "plus")).bold()
        + Text(" Add").bold()
        + Text(" button to begin!")
    }
    
    var recordSections: [([TransactionRecord], String)] {
        var sections: [([TransactionRecord], String)] = []
        var lastSectionRecords: [TransactionRecord] = []
        var lastStartOfDay: Date = .distantPast
        for record in records {
            let recordStartOfDay = Calendar.current.startOfDay(for: record.timestamp)
            if recordStartOfDay != lastStartOfDay {
                if !lastSectionRecords.isEmpty {
                    sections.append((lastSectionRecords, lastStartOfDay.formatted(date: .abbreviated, time: .omitted)))
                }
                lastStartOfDay = recordStartOfDay
                lastSectionRecords = []
            }
            lastSectionRecords.append(record)
        }
        if (!lastSectionRecords.isEmpty) {
            sections.append((lastSectionRecords, lastStartOfDay.formatted(date: .abbreviated, time: .omitted)))
        }
        return sections
    }
}

#Preview {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = context.insert(SampleObjects.expenseCategory)
    let _ = context.insert(SampleObjects.expenseRecord)
    let _ = context.insert(SampleObjects.incomeCategory)
    let _ = context.insert(SampleObjects.incomeRecord)
    
    RecordsPage()
        .modelContainer(container)
}

#Preview("Blank") {
    RecordsPage()
        .modelContainer(for: TransactionRecord.self, inMemory: true)
}

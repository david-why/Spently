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
    
    var body: some View {
        NavigationView {
            List {
                ForEach(recordSections, id: \.1) { section in
                    Section(section.1) {
                        ForEach(section.0) { record in
                            NavigationLink {
                                RecordDetailPage(record: record)
                            } label: {
                                TransactionView(record: record)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Records")
        }
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
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: TransactionRecord.self, configurations: configuration)
    let context = container.mainContext
    
    let _ = context.insert(SampleObjects.expenseRecord)
    let _ = context.insert(SampleObjects.incomeRecord)
    
    RecordsPage()
        .modelContainer(container)
}

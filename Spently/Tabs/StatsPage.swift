//
//  StatsPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/21.
//

import SwiftUI
import SwiftData
import Charts

struct StatsPage: View {
    @State var filterDates: DateInterval? = nil
    
    var body: some View {
        NavigationStack {
            StatsPageInner(filterDates: filterDates)
//                .toolbar {
//                    Menu("Filter", systemImage: filterIcon) {
//                        Button("Start date") {}
//                        Button("End date") {}
//                    }
//                }
        }
    }
    
    var filterIcon: String {
        filterDates == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill"
    }
}

struct StatsPageInner: View {
    var filterDates: DateInterval?
    
    @Query var transactions: [TransactionRecord]
    
    init(filterDates: DateInterval?) {
        self.filterDates = filterDates
        let startDate = filterDates?.start ?? Date.distantPast
        let endDate = filterDates?.end ?? Date()
        _transactions = Query(filter: #Predicate { $0.timestamp >= startDate && $0.timestamp <= endDate })
    }
    
    var body: some View {
        List {
            if transactions.isEmpty {
                Text("No data yet. Add some transactions to view your stats!")
                    .navigationTitle("Your Stats")
            } else {
                Section {
                    summaryChart
                } header: {
                    Text("Income vs. Expense")
                } footer: {}
                
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Section {
                        typeChart(for: type)
                    } header: {
                        Text("\(type.displayName) Details")
                    }
                }
            }
        }
        .navigationTitle("Your Stats")
    }
    
    @ViewBuilder var summaryChart: some View {
        Chart(transactions) { record in
            BarMark(
                x: .value("Type", record.category.type.displayName),
                y: .value("Amount", record.amount)
            )
            .foregroundStyle(by: .value("Category", record.category.name))
        }
        .chartXAxis {
            AxisMarks(values: ["Income", "Expense"])
        }
        .frame(height: 200)
    }
    
    @ViewBuilder func typeChart(for type: TransactionType) -> some View {
        Chart(transactions(of: type)) { record in
            SectorMark(angle: .value("Amount", record.amount))
                .foregroundStyle(by: .value("Category", record.category.name))
        }
        .frame(height: 200)
    }
    
    func transactions(of type: TransactionType) -> [TransactionRecord] {
        transactions.filter { $0.category.type == type }
    }
}

#Preview {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = TransactionCategory.defaultCategories.forEach(context.insert)
    
    StatsPage()
        .modelContainer(container)
}

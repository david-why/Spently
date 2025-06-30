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
    @State var isDateFilterOn: Bool = false
    
    @State var filterStartDate: Date = Calendar.current.startOfDay(for: .now.addingTimeInterval(-30 * 86400))
    @State var filterEndDate: Date = Calendar.current.startOfDay(for: .now.addingTimeInterval(86400))
    
    @State var showingStartDatePicker: Bool = false
    @State var showingEndDatePicker: Bool = false

    @Query var firstTransaction: [TransactionRecord]
    
    init() {
        var descriptor = FetchDescriptor<TransactionRecord>()
        descriptor.fetchLimit = 1
        _firstTransaction = Query(descriptor)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    if isDateFilterOn {
                        dateFilterItem(label: "Start date", date: $filterStartDate, isShowing: $showingStartDatePicker)
                        dateFilterItem(label: "End date", date: $filterEndDate, isShowing: $showingEndDatePicker)
                    }
                }
                
                StatsCharts(filterDates: filterDates)
            }
            .navigationTitle("Your Stats")
            .toolbar {
                Button("Filter", systemImage: filterIcon) {
                    isDateFilterOn.toggle()
                }
            }
        }
        .animation(.default, value: isDateFilterOn)
        .animation(.default, value: filterStartDate)
        .animation(.default, value: filterEndDate)
        .animation(.default, value: showingStartDatePicker)
        .animation(.default, value: showingEndDatePicker)
    }
    
    @ViewBuilder func dateFilterItem(label: String, date: Binding<Date>, isShowing: Binding<Bool>) -> some View {
        LabeledContent {
            Button {
                isShowing.wrappedValue = !isShowing.wrappedValue
            } label: {
                Text(verbatim: date.wrappedValue.formatted())
            }
        } label: {
            Text(label)
        }
        if isShowing.wrappedValue {
            DatePicker(label, selection: date)
                .datePickerStyle(.graphical)
        }
    }
    
    var noTransactions: Bool {
        firstTransaction.isEmpty
    }
    
    var filterDates: DateInterval? {
        isDateFilterOn ? DateInterval(start: filterStartDate, end: filterEndDate) : nil
    }
    
    var filterIcon: String {
        isDateFilterOn ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle"
    }
}

struct StatsCharts: View {
    var filterDates: DateInterval?
    
    @Query var transactions: [TransactionRecord]
    @Query var categories: [TransactionCategory]

    init(filterDates: DateInterval?) {
        self.filterDates = filterDates
        let startDate = filterDates?.start ?? Date.distantPast
        let endDate = filterDates?.end ?? Date.distantFuture
        _transactions = Query(filter: #Predicate { $0.timestamp >= startDate && $0.timestamp <= endDate })
    }
    
    var body: some View {
        Section("Income vs. Expense") {
            summaryChart
        }
        
        Section("Income Details") {
            typeChart(for: .income)
        }
        
        Section("Expense Details") {
            typeChart(for: .expense)
        }
    }
    
    @ViewBuilder var summaryChart: some View {
        if transactions.isEmpty {
            Text("No data found.")
        } else {
            Chart(categorySummaries) { summary in
                BarMark(
                    x: .value("Type", summary.category.type.localizedName),
                    y: .value("Amount", summary.total)
                )
                .foregroundStyle(by: .value("Category", summary.category.name))
            }
            .chartXAxis {
                AxisMarks(values: ["Income", "Expense"]) {
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel()
                }
            }
            .frame(height: 200)
        }
    }
    
    @ViewBuilder func typeChart(for type: TransactionType) -> some View {
        let summaries = categorySummaries.filter { $0.category.type == type }
        if summaries.isEmpty {
            Text("No data found.")
        } else {
            Chart(summaries) { summary in
                SectorMark(angle: .value("Amount", summary.total))
                    .foregroundStyle(by: .value("Category", summary.category.name))
            }
            .frame(height: 200)
        }
    }
    
    var categorySummaries: [CategorySummary] {
        var summaryMap = [UUID : CategorySummary]()
        
        for transaction in transactions {
            var summary = summaryMap[transaction.category.id] ?? .init(category: transaction.category, total: 0)
            summary.total += transaction.amount
            summaryMap[transaction.category.id] = summary
        }
        
        return summaryMap.values.sorted { $0.total > $1.total }
    }
    
    struct CategorySummary: Identifiable {
        var category: TransactionCategory
        var total: Decimal
        
        var id: UUID {
            category.id
        }
    }
}

#Preview {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = context.insert(SampleObjects.expenseRecord)
    let _ = context.insert(SampleObjects.incomeRecord)
    
    StatsPage()
        .modelContainer(container)
}

#Preview("Income only") {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = context.insert(SampleObjects.incomeRecord)
    
    StatsPage()
        .modelContainer(container)
}

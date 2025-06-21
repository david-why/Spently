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
    @State var isDateFilterOn: Bool = true
    
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
    
    init(filterDates: DateInterval?) {
        self.filterDates = filterDates
        let startDate = filterDates?.start ?? Date.distantPast
        let endDate = filterDates?.end ?? Date()
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
            Chart(transactions) { record in
                BarMark(
                    x: .value("Type", record.category.type.localizedName),
                    y: .value("Amount", record.amount)
                )
                .foregroundStyle(by: .value("Category", record.category.name))
            }
            .chartXAxis {
                AxisMarks(values: ["Income", "Expense"])
            }
            .frame(height: 200)
        }
    }
    
    @ViewBuilder func typeChart(for type: TransactionType) -> some View {
        let records = transactions(of: type)
        if records.isEmpty {
            Text("No data found.")
        } else {
            Chart(records) { record in
                SectorMark(angle: .value("Amount", record.amount))
                    .foregroundStyle(by: .value("Category", record.category.name))
            }
            .frame(height: 200)
        }
    }
    
    func transactions(of type: TransactionType) -> [TransactionRecord] {
        transactions.filter { $0.category.type == type }
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

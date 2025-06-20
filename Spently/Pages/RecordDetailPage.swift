//
//  RecordDetailPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI
import SwiftData
import Combine

struct RecordDetailPage: View {
    @Bindable var record: TransactionRecord
    
    @Query(sort: \TransactionCategory.ordinal) var categories: [TransactionCategory]
    @AppStorage("preferredCurrencies") var preferredCurrenciesString: String = ""
    
    @State private var isCategoriesOpen = false

    var body: some View {
        Form {
            Section {
                categoryPicker
                amountField
                Picker("Currency", selection: $record.currency) {
                    ForEach(currencyCodesWithValue, id: \.0) { currencyCode in
                        Text("\(currencyCode.0) (\(currencyCode.1))").tag(Locale.Currency(currencyCode.0))
                    }
                }
                DatePicker("Date", selection: $record.timestamp)
            }
            Section("Notes") {
                TextEditor(text: $record.notes)
            }
            Section("Preview") {
                TransactionView(record: record)
            }
        }
        .animation(.default, value: isCategoriesOpen)
        .navigationTitle("Edit")
    }
    
    var preferredCurrencies: [String] {
        get {
            preferredCurrenciesString.split(separator: ",").map(String.init)
        }
        set {
            preferredCurrenciesString = newValue.joined(separator: ",")
        }
    }
    
    var currencyCodesWithValue: [(String, String)] {
        currencyCodes.map { code in (code, record.amount.formatted(.currency(code: code))) }
    }
    
    var currencyCodes: [String] {
        let currentCurrency = Locale.current.currency?.identifier
        var priorityCodes: [String] = preferredCurrencies.filter { $0 != currentCurrency }
        if let currentCurrency {
            priorityCodes.insert(currentCurrency, at: 0)
        }
        return priorityCodes + Locale.Currency.isoCurrencies.map { $0.identifier }.filter { !priorityCodes.contains($0) }
    }
    
    @ViewBuilder var categoryPicker: some View {
        HStack {
            Text("Category")
            Spacer()
            Button {
                isCategoriesOpen.toggle()
            } label: {
                Text("\(record.category.emoji) \(record.category.name)")
            }
            .animation(nil, value: record.category.name)
        }
        if isCategoriesOpen {
            VStack {
                categoryList(for: .income)
                categoryList(for: .expense)
            }
        }
    }
    
    var amountFormatStyle: Decimal.FormatStyle {
        .init().grouping(.never)
    }
    
    @ViewBuilder var amountField: some View {
        LabeledContent("Amount") {
            HStack {
                TextField("Amount", value: $record.amount, format: Decimal.FormatStyle())
                    .multilineTextAlignment(.trailing)
                    .labelsHidden()
            }
        }
    }
    
    @ViewBuilder func categoryList(for type: TransactionType) -> some View {
        HStack {
            Text(type.displayName)
                .frame(alignment: .leading)
            Spacer()
        }
        LazyVGrid(columns: [.init(.adaptive(minimum: 52))]) {
            ForEach(categories.filter { $0.type == type }) { category in
                ZStack {
                    Circle()
                        .foregroundStyle(record.category == category ? Color.accentColor : .clear)
                        .opacity(0.5)
                    Circle()
                        .stroke(Color.gray, lineWidth: 1)
                    Text(verbatim: category.emoji)
                }
                .frame(width: 52, height: 52)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        record.category = category
                    }
                }
            }
        }
    }
}

#Preview {
    let container = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    NavigationView {
        RecordDetailPage(record: SampleObjects.expenseRecord)
            .modelContainer(container)
    }
    .onAppear {
        let _ = context.insert(SampleObjects.expenseCategory)
        let _ = context.insert(SampleObjects.incomeCategory)
        let _ = context.insert(SampleObjects.expenseRecord)
        let _ = TransactionCategory.defaultCategories.map(context.insert)
        UserDefaults.standard.set("USD,CNY", forKey: "preferredCurrencies")
    }
}

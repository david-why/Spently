//
//  TransactionView.swift
//  Spently
//
//  Created by David Wang on 2025/6/16.
//

import SwiftUI

struct TransactionView: View {
    @AppStorage("currency") var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    
    var record: TransactionRecord
    
    var body: some View {
        HStack {
            Text(record.category.emoji)
                .font(.system(size: 32))
            
            VStack(alignment: .leading) {
                Text(record.category.name)
                    .font(.headline)
                if !record.notes.isEmpty {
                    Text(record.notes)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Text("\(record.category.type.sign)\(record.amount.formatted(.currency(code: currencyCode)))")
                .font(.headline)
                .foregroundStyle(record.category.type == .expense ? .red : .green)
        }
    }
}

#Preview {
    List {
        TransactionView(record: SampleObjects.expenseRecord)
        TransactionView(record: SampleObjects.incomeRecord)
    }
}

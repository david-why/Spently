//
//  CategoryDetailPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/20.
//

import SwiftUI
import SwiftData

struct CategoryDetailPage: View {
    @Bindable var category: TransactionCategory
    
    @Environment(\.modelContext) var modelContext
    
    @State var type: TransactionType
    @State var isPresentedChangingType: Bool = false
    @State var changingType: (TransactionType, TransactionType)? = nil
    
    init(category: TransactionCategory) {
        self.category = category
        type = category.type
    }
    
    var body: some View {
        Form {
            LabeledContent("Name") {
                TextField("Name of category", text: $category.name)
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
            }
            
            LabeledContent("Emoji") {
                TextField("Emoji", text: $category.emoji)
                    .labelsHidden()
                    .multilineTextAlignment(.trailing)
                    .keyboardType(.init(rawValue: 124)!)
                    .onChange(of: category.emoji) { old, new in
                        if new.isEmpty {
                            category.emoji = old.isEmpty ? "❓" : String(old.last!)
                        } else if new.count > 1 {
                            category.emoji = String(new.last!)
                        }
                    }
            }
            
            Picker("Type", selection: $type) {
                ForEach(TransactionType.allCases, id: \.self) { type in
                    Text(type.localizedName).tag(type)
                }
            }
            .onChange(of: type) { old, new in
                if new != category.type && recordCount > 0 {
                    changingType = (old, new)
                    isPresentedChangingType = true
                }
            }
        }
        .navigationTitle("Edit Category")
        .alert("Confirm Changing Type", isPresented: $isPresentedChangingType, presenting: changingType) { old, new in
            Button("Confirm", role: .destructive) {
                category.type = new
            }
            Button("Cancel", role: .cancel) {
                type = old
            }
        } message: { old, new in
            Text("There are \(recordCount) transactions in this category. Proceeding will change their type and affect your accounting history.\n\nAre you sure you want to continue?")
        }
    }
    
    var recordCount: Int {
        let categoryModelID = category.persistentModelID
        let descriptor = FetchDescriptor<TransactionRecord>(predicate: #Predicate { $0.persistentModelID == categoryModelID })
        do {
            return try modelContext.fetchCount(descriptor)
        } catch {
            print("error fetching record count: \(error)")
            return 0
        }
    }
}

#Preview {
    let modelContainer = SampleObjects.modelContainer!
    let modelContext = SampleObjects.modelContext!
    
    let category = SampleObjects.expenseCategory
    
    let _ = modelContext.insert(category)
    let _ = modelContext.insert(SampleObjects.expenseRecord)
    let _ = try! modelContext.save()
    
    NavigationStack {
        CategoryDetailPage(category: category)
            .modelContainer(modelContainer)
    }
}

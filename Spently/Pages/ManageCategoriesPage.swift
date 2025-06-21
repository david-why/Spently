//
//  ManageCategoriesPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/20.
//

import SwiftUI
import SwiftData

struct ManageCategoriesPage: View {
    @Binding var navigationPath: NavigationPath
    
    @Query(sort: \TransactionCategory.ordinal) var categories: [TransactionCategory]
    
    @Query(filter: #Predicate<TransactionCategory> { $0.name == "" }) var unnamedCategories: [TransactionCategory]
    
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        Form {
            Section("Income Categories") {
                categoryList(for: .income)
            }
            Section("Expense Categories") {
                categoryList(for: .expense)
            }
        }
        .toolbar {
            Button("Add category", systemImage: "plus") {
                addCategory(type: .income)
            }
        }
        .navigationTitle("Categories")
        .navigationDestination(for: TransactionCategory.self) { category in
            CategoryDetailPage(category: category)
        }
        .onAppear {
            unnamedCategories.forEach(modelContext.delete)
        }
    }
    
    func categories(for type: TransactionType) -> [TransactionCategory] {
        categories.filter { $0.type == type }
    }
    
    @ViewBuilder func categoryList(for type: TransactionType) -> some View {
        let categoriesOfType = categories(for: type)
        List {
            ForEach(categoriesOfType) { category in
                NavigationLink(value: category) {
                    Text("\(category.emoji) \(category.name)")
                }
            }
            .onMove { source, destination in
                var list = categoriesOfType
                let movedItems = source.map { list[$0] }
                list.remove(atOffsets: source)
                list.insert(contentsOf: movedItems, at: destination - source.count { $0 < destination })
                let startOrdinal = TransactionCategory.startOrdinal(for: type)
                for (index, item) in list.enumerated() {
                    item.ordinal = startOrdinal + index
                }
//                try? modelContext.save()
//                print(((try? modelContext.fetch(FetchDescriptor<TransactionCategory>(sortBy: [.init(\.ordinal)]))) ?? []).map { ($0.name, $0.ordinal) })
            }
            .onDelete { offsets in
                print("deleting offsets: \(Set(offsets))")
//                var toDelete = [TransactionCategory]()
//                for offset in offsets {
//                    let category = categoriesOfType[offset]
//                    toDelete.append(category)
//                }
//                toDelete.forEach(modelContext.delete)
            }
        }
    }
    
    func addCategory(type: TransactionType) {
        let existingCategories = categories(for: type)
        let category = TransactionCategory(emoji: "❓", name: "", type: type, ordinal: existingCategories.last?.ordinal ?? TransactionCategory.startOrdinal(for: type))
        modelContext.insert(category)
        navigationPath.append(category)
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    ManageCategoriesPage(navigationPath: $navigationPath)
}

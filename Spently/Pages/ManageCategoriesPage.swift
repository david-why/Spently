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
    
    @State var isConfirmingDeleteCategories: Bool = false
    @State var confirmDeleteCategories: ConfirmDeletingCategories?
    @State var isConfirmingReset: Bool = false
    
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
            Button("Reset to default", systemImage: "arrow.counterclockwise") {
                isConfirmingReset = true
            }
        }
        .navigationTitle("Categories")
        .navigationDestination(for: TransactionCategory.self) { category in
            CategoryDetailPage(category: category)
        }
        .alert("Reset to default?", isPresented: $isConfirmingReset) {
            Button("Reset", role: .destructive) {
                doResetCategories()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to reset categories? This will:\n\n1. Delete all categories\n2. Restore default categories\n3. Set your transactions to a category with the same name if it exists, or \"Other\" otherwise")
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
            }
            .onDelete { offsets in
                print("deleting offsets: \(Set(offsets))")
                let toDelete = offsets.map { index in categoriesOfType[index] }
                print(toDelete.first?.records as Any)
                let countWithTransactions = toDelete.filter { !$0.records.isEmpty }.count
                confirmDeleteCategories = .init(categories: toDelete, countWithTransactions: countWithTransactions)
                if countWithTransactions != 0 {
                    isConfirmingDeleteCategories = true
                } else {
                    doDelete()
                }
            }
        }
        .alert("Confirm Deletion", isPresented: $isConfirmingDeleteCategories, presenting: confirmDeleteCategories) { data in
            Button("Delete", role: .destructive) {
                doDelete()
            }
            Button("Cancel", role: .cancel) {}
        } message: { data in
            Text("You are deleting \(data.categories.count) categories, \(data.countWithTransactions) of which have transactions which will be deleted. Are you sure?")
        }
    }
    
    func doDelete() {
        confirmDeleteCategories!.categories.forEach(modelContext.delete)
    }
    
    func doResetCategories() {
        do {
            try modelContext.transaction {
                let transactions = try modelContext.fetch(FetchDescriptor<TransactionRecord>())
                let categories = try modelContext.fetch(FetchDescriptor<TransactionCategory>())
                let defaultCategories = TransactionCategory.defaultCategories
                var categoryMapping: [TransactionCategory.ID: TransactionCategory] = [:]
                for category in categories {
                    if let newCategory = defaultCategories.first(where: { $0.name == category.name && $0.type == category.type }) {
                        categoryMapping.updateValue(newCategory, forKey: category.id)
                    } else {
                        let newCategory = defaultCategories.last { $0.type == category.type }!
                        categoryMapping.updateValue(newCategory, forKey: category.id)
                    }
                }
                for transaction in transactions {
                    transaction.category = categoryMapping[transaction.category.id]!
                }
                for category in categories {
                    modelContext.delete(category)
                }
                for category in defaultCategories {
                    modelContext.insert(category)
                }
            }
        } catch {
            print("ERROR:", error)
        }
    }
    
    func addCategory(type: TransactionType) {
        let existingCategories = categories(for: type)
        let category = TransactionCategory(emoji: "❓", name: "", type: type, ordinal: existingCategories.last?.ordinal ?? TransactionCategory.startOrdinal(for: type))
        modelContext.insert(category)
        navigationPath.append(category)
    }
    
    struct ConfirmDeletingCategories: Identifiable {
        var categories: [TransactionCategory]
        var countWithTransactions: Int
        let id = UUID()
    }
}

#Preview {
    @Previewable @State var navigationPath = NavigationPath()
    ManageCategoriesPage(navigationPath: $navigationPath)
}

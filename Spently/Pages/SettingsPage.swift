//
//  SettingsPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/20.
//

import SwiftUI
import SwiftData

struct SettingsPage: View {
    @AppStorage("preferredCurrencies") var preferredCurrenciesString: String = ""
    
    @Query(sort: \TransactionCategory.ordinal) var categories: [TransactionCategory]
    
    @Query(filter: #Predicate<TransactionCategory> { $0.name == "" }) var unnamedCategories: [TransactionCategory]
    
    @Environment(\.modelContext) var modelContext
    
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section("Income Categories") {
                    List {
                        categoryList(for: .income)
                            .onMove { source, destination in
                                print(Set(source), destination)
                            }
                    }
                    Button("Add income category") {
                        addCategory(type: .income)
                    }
                }
                Section("Expense Categories") {
                    categoryList(for: .expense)
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: TransactionCategory.self) { category in
                CategoryDetailPage(category: category)
            }
        }
        .onAppear {
            unnamedCategories.forEach(modelContext.delete)
        }
    }
    
    var preferredCurrencies: [String] {
        get {
            preferredCurrenciesString.split(separator: ",").map(String.init)
        }
        set {
            preferredCurrenciesString = newValue.joined(separator: ",")
        }
    }
    
    @ViewBuilder func categoryList(for type: TransactionType) -> some DynamicViewContent {
        ForEach(categories.filter { $0.type == type }) { category in
            NavigationLink(value: category) {
                Text("\(category.emoji) \(category.name)")
            }
        }
    }
    
    func addCategory(type: TransactionType) {
        let category = TransactionCategory(emoji: "💰", name: "", type: type, ordinal: TransactionCategory.userCategoryStartOrdinal(for: type))
    }
}

#Preview {
    let modelContainer = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = TransactionCategory.defaultCategories.forEach(context.insert)
    
    SettingsPage()
        .modelContainer(modelContainer)
}

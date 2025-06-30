//
//  SettingsPage.swift
//  Spently
//
//  Created by David Wang on 2025/6/20.
//

import SwiftUI
import SwiftData

struct SettingsPage: View {
    @AppStorage("currency") var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    
    @Query(sort: \TransactionCategory.ordinal) var categories: [TransactionCategory]
    
    @Query(filter: #Predicate<TransactionCategory> { $0.name == "" }) var unnamedCategories: [TransactionCategory]
    
    @Environment(\.modelContext) var modelContext
    
    @State var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section("Currency") {
                    Picker("Currency", selection: $currencyCode) {
                        ForEach(Locale.Currency.isoCurrencies) { currency in
                            Text(currency.identifier)
                        }
                    }
                }
                
                Section {
                    NavigationLink(value: ManageCategoriesSubpage.value) {
                        Text("Manage categories")
                    }
                } header: {
                    Text("Categories")
                } footer: {
                    Text("Add, remove, or edit the categories for your transactions.")
                }
            }
            .navigationTitle("Settings")
            .navigationDestination(for: ManageCategoriesSubpage.self) { _ in
                ManageCategoriesPage(navigationPath: $navigationPath)
            }
            .onAppear {
                unnamedCategories.forEach(modelContext.delete)
            }
        }
    }
    
    func categories(for type: TransactionType) -> [TransactionCategory] {
        categories.filter { $0.type == type }
    }
    
    @ViewBuilder func categoryList(for type: TransactionType) -> some DynamicViewContent {
        ForEach(categories(for: type)) { category in
            NavigationLink(value: category) {
                Text("\(category.emoji) \(category.name)")
            }
        }
        .onMove { source, destination in
            var list = categories(for: type)
            let movedItems = source.map { list[$0] }
            list.remove(atOffsets: source)
            list.insert(contentsOf: movedItems, at: destination - source.count { $0 < destination })
            let startOrdinal = TransactionCategory.startOrdinal(for: type)
            for (index, item) in list.enumerated() {
                item.ordinal = startOrdinal + index
            }
            try? modelContext.save()
            print(((try? modelContext.fetch(FetchDescriptor<TransactionCategory>(sortBy: [.init(\.ordinal)]))) ?? []).map { ($0.name, $0.ordinal) })
        }
    }
    
    func addCategory(type: TransactionType) {
        let existingCategories = categories(for: type)
        let category = TransactionCategory(emoji: "❓", name: "", type: type, ordinal: existingCategories.last?.ordinal ?? TransactionCategory.startOrdinal(for: type))
        modelContext.insert(category)
        navigationPath.append(category)
    }
    
    enum ManageCategoriesSubpage {
        case value
    }
}

#Preview {
    let modelContainer = SampleObjects.modelContainer!
    let context = SampleObjects.modelContext!
    
    let _ = TransactionCategory.defaultCategories.forEach(context.insert)
    
    SettingsPage()
        .modelContainer(modelContainer)
}

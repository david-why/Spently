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
    @State var currencyToAdd: String?
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            Form {
                Section {
                    List(preferredCurrenciesBinding, id: \.self, editActions: .delete) { currencyCode in
                        Text(currencyCode.wrappedValue)
                    }
                    Picker(selection: $currencyToAdd) {
                        Text("---").tag(nil as String?)
                        ForEach(unselectedCurrencies, id: \.self) { currencyCode in
                            Text(currencyCode).tag(currencyCode)
                        }
                    } label: {
                        Text("Add preferred currency")
                            .foregroundStyle(Color.accentColor)
                    }
                    .onChange(of: currencyToAdd) {
                        if let currencyToAdd {
                            self.currencyToAdd = nil
                            preferredCurrencies.append(currencyToAdd)
                        }
                    }
                } header: {
                    Text("Preferred Currencies")
                } footer: {
                    Text("Choose preferred currencies that always display at the top of the list. Swipe left on a currency to remove it from the list.")
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
        .animation(.default, value: preferredCurrencies)
    }
    
    var preferredCurrencies: [String] {
        get {
            preferredCurrenciesString.split(separator: ",").map(String.init)
        }
        nonmutating set {
            preferredCurrenciesString = newValue.joined(separator: ",")
        }
    }
    
    var preferredCurrenciesBinding: Binding<[String]> {
        Binding(get: { preferredCurrencies }, set: { preferredCurrencies = $0 })
    }
    
    var unselectedCurrencies: [String] {
        Locale.Currency.isoCurrencies.map { $0.identifier }.filter { !preferredCurrencies.contains($0) }
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

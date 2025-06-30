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
    @State var isDebugging = false
    @State var exportingDataURL: URL?
    @State var importingData = false
    
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
                
                if isDebugging {
                    Section("Debugging") {
                        Button("Export records as JSON") {
                            exportRecords()
                        }
                        .sheet(item: $exportingDataURL) { url in
                            SaveDocumentPicker(exporting: url, asCopy: true) { _ in
                                try? FileManager.default.removeItem(at: url)
                                DispatchQueue.main.async {
                                    exportingDataURL = nil
                                }
                            } onCancel: {
                                try? FileManager.default.removeItem(at: url)
                                DispatchQueue.main.async {
                                    exportingDataURL = nil
                                }
                            }
                        }
                        Button("Import JSON records") {
                            importingData = true
                        }
                    }
                }
            }
            .fileImporter(isPresented: $importingData, allowedContentTypes: [.json]) { result in
                let url = try! result.get()
                importRecords(url: url)
            }
            .navigationTitle("Settings")
            .navigationDestination(for: ManageCategoriesSubpage.self) { _ in
                ManageCategoriesPage(navigationPath: $navigationPath)
            }
            .onAppear {
                unnamedCategories.forEach(modelContext.delete)
            }
        }
        .onTapGesture(count: 3) {
            isDebugging.toggle()
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
    
    func exportRecords() {
        let records = try! modelContext.fetch(FetchDescriptor<TransactionRecord>())
        let recordItems = records.map(TransactionRecordItem.init)
        let categoryItems = categories.map(TransactionCategoryItem.init)
        let data = JSONDumpData(records: recordItems, categories: categoryItems)
        
        let encoder = JSONEncoder()
        let encodedData = try! encoder.encode(data)
        let saveURL = URL.documentsDirectory.appending(component: "SpentlyData.json")
        try! encodedData.write(to: saveURL)
        exportingDataURL = saveURL
    }
    
    func importRecords(url: URL) {
        print("Got import url")
        guard url.startAccessingSecurityScopedResource() else { print("FAILED TO GET ACCESS UWU"); return }
        defer { url.stopAccessingSecurityScopedResource() }
        let encodedData = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        let data = try! decoder.decode(JSONDumpData.self, from: encodedData)
        print("Got data", data.records.count, data.categories.count)
        
        try! modelContext.transaction {
            try modelContext.fetch(FetchDescriptor<TransactionRecord>()).forEach(modelContext.delete)
            try modelContext.fetch(FetchDescriptor<TransactionCategory>()).forEach(modelContext.delete)

            var categoryMap = [UUID : TransactionCategory]()
            
            for categoryItem in data.categories {
                let category = TransactionCategory(emoji: categoryItem.emoji, name: categoryItem.name, type: .init(rawValue: categoryItem.typeInt)!, ordinal: categoryItem.ordinal)
                category.id = categoryItem.id
                modelContext.insert(category)
                categoryMap[category.id] = category
            }
            for recordItem in data.records {
                print("inserting", recordItem.notes)
                let record = TransactionRecord(amount: recordItem.amount, notes: recordItem.notes, category: categoryMap[recordItem.categoryID]!, timestamp: recordItem.timestamp)
                record.id = recordItem.id
                modelContext.insert(record)
            }
        }
    }
    
    struct JSONDumpData: Codable {
        var records: [TransactionRecordItem]
        var categories: [TransactionCategoryItem]
    }
    
    struct TransactionRecordItem: Codable {
        var id: UUID
        var amount: Decimal
        var notes: String
        var categoryID: UUID
        var timestamp: Date
        
        init(from record: TransactionRecord) {
            id = record.id
            amount = record.amount
            notes = record.notes
            categoryID = record.category.id
            timestamp = record.timestamp
        }
    }
    
    struct TransactionCategoryItem: Codable {
        var id: UUID
        var name: String
        var emoji: String
        var typeInt: Int
        var ordinal: Int
        
        init(from category: TransactionCategory) {
            id = category.id
            name = category.name
            emoji = category.emoji
            typeInt = category.typeInt
            ordinal = category.ordinal
        }
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

//
//  ContentView.swift
//  iExpense
//
//  Created by Caleb Adepitan on 20/03/2025.
//

import SwiftUI

struct ExpenseItem: Identifiable, Codable, Hashable {
    var id = UUID()
    let name: String
    let type: String
    let amount: Double
}

@Observable
class Expense {
    var items = [ExpenseItem]() {
        didSet {
            if let encoded = try? JSONEncoder().encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }

    init() {
        if let savedItems = UserDefaults.standard.data(forKey: "Items") {
            if let decoded = try? JSONDecoder().decode([ExpenseItem].self, from: savedItems) {
                items = decoded
                return
            }
        }

        items = []
    }

    /// Group the expense items in this expense object by a given key of expense item and optionally filter the
    /// expense items before grouping
    /// - Parameters:
    ///   - by: The key to group the expense items by
    ///   - filter: The filter criteria for the expense items
    /// - Returns: A dictionary grouping of expense items, mapping a list of expense items to a unique grouping key
    func grouped<K: Hashable>(by: (ExpenseItem) -> K, where filter: ((ExpenseItem) -> Bool)?) -> Dictionary<K, [ExpenseItem]> {
        if let filter = filter {
            Dictionary(grouping: items.filter(filter), by: by)
        } else {
            Dictionary(grouping: items, by: by)
        }
    }
}

//
// extension View {
//    @ViewBuilder func hidden(when condition: Bool) -> some View {
//        if !condition {
//            self
//        } else {
//            hidden()
//        }
//    }
// }

struct ContentView: View {
    @State private var expenses = Expense()
    @State private var selectedItems: Set<UUID> = []
    @State private var searchText: String = ""

    @State private var showingAddView = false
    @State private var editingItem: ExpenseItem? = nil
    @State private var bottomBarVisibility: Visibility = .hidden
    @State private var editMode: EditMode = .inactive {
        didSet {
            withAnimation {
                if editMode == .active {
                    bottomBarVisibility = .visible
                } else {
                    bottomBarVisibility = .hidden
                }
            }
        }
    }

    var groupedExpenses: [(key: String, value: [ExpenseItem])] {
        let filter: ((ExpenseItem) -> Bool)? = searchText.isEmpty ? nil : {
            $0.name.lowercased().contains(searchText.lowercased())
        }

        return expenses.grouped(by: \.type, where: filter)
            .sorted(by: { $0.key < $1.key })
    }

    var body: some View {
        NavigationStack {
            VStack {
                List(selection: $selectedItems) {
                    ForEach(groupedExpenses, id: \.key) { group, items in
                        Section(header: Text(group)) {
                            ForEach(items) { item in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(item.name)
                                            .font(.headline)
                                        Text(item.type)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Text(item.amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                }
                                .swipeActions(edge: .trailing) {
                                    Button("Delete", systemImage: "trash", role: .destructive) {
                                        removeItems(at: [expenses.items.firstIndex(of: item)!])
                                        editMode = .inactive
                                    }

                                    Button("Edit", systemImage: "square.and.pencil") {
                                        editingItem = item
                                    }
                                    .tint(.blue)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle("Expense")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button(editMode == .active ? "Cancel" : "Select") {
                            editMode = editMode == .active ? .inactive : .active
                        }
                        .font(.caption)
                        .buttonBorderShape(.capsule)
                        .buttonStyle(.bordered)

                        Button("Add expense", systemImage: "plus") {
                            showingAddView = true
                        }
                        .buttonBorderShape(.circle)
                        .buttonStyle(.bordered)
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        HStack {
                            Button("Trash", systemImage: "trash") {
                                removeItems(selectedItems)
                                editMode = .inactive
                            }
                            .disabled(selectedItems.isEmpty)

                            Spacer()

                            Text("\(selectedItems.count) selected")
                                .font(.caption)

                            Spacer()

                            Button("Edit", systemImage: "square.and.pencil") {
                                editingItem = expenses.items.first(where: {
                                    $0.id == selectedItems.first!
                                })
                            }
                            .disabled(selectedItems.count != 1)
                        }
                    }
                }
                .toolbar(bottomBarVisibility, for: .bottomBar)
                .sheet(isPresented: $showingAddView) {
                    AddView(expenses: expenses)
                }
                .sheet(item: $editingItem) { item in
                    AddView(expenses: self.expenses, item: item)
                }
                .environment(\.editMode, $editMode)
            }
        }
        .searchable(text: $searchText)
    }

    /// Remove the set of items specified by their unique identifier from the
    /// record of expenses
    /// - Parameter items: The set of unique identifiers of the items to remove
    func removeItems(_ items: Set<UUID>) {
        expenses.items.removeAll(where: { items.contains($0.id) })
    }

    /// Remove the set of items specified by their unique indices in the collection from the
    /// record of expenses
    /// - Parameter offsets: The set of unique indices of items to remove
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
}

#Preview {
    ContentView()
}

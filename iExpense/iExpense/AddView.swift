//
//  AddView.swift
//  iExpense
//
//  Created by Caleb Adepitan on 21/03/2025.
//

import SwiftUI

struct AddView: View {
    @State private var name = ""
    @State private var amount = 0.0
    @State private var type = "Personal"
    @State private var types = ["Personal", "Business"]

    @Environment(\.dismiss) var dismiss

    var item: ExpenseItem? = nil
    var expenses: Expense

    var body: some View {
        NavigationStack {
            Form {
                TextField("Name", text: $name)

                Picker("Type", selection: $type) {
                    ForEach(types, id: \.self) {
                        Text($0)
                    }
                }

                TextField("Amount", value: $amount, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                    .keyboardType(.decimalPad)
            }
            .navigationTitle(item != nil ? "Edit expense" : "Add new expense")
            .toolbar {
                Button("Save") {
                    if let item = item {
                        save(item: ExpenseItem(id: item.id, name: name, type: type, amount: amount))
                    } else {
                        save(item: ExpenseItem(name: name, type: type, amount: amount))
                    }

                    dismiss()
                }
                .buttonStyle(.bordered)
                .buttonBorderShape(.capsule)
                .disabled(name.isEmpty || amount == 0)
            }
        }
        .onAppear {
            if let item = item {
                self.name = item.name
                self.type = item.type
                self.amount = item.amount
            }
        }
    }

    func save(item: ExpenseItem) {
        if let indexOfItemToEdit = expenses.items.firstIndex(where: { $0.id == item.id }) {
            expenses.items[indexOfItemToEdit] = item
        } else {
            expenses.items.append(item)
        }
    }
}

extension AddView {
    /// Create a view to edit an existing expense item given the root expense object and the
    /// exact item to edit gurarnteed to be present in the root expense object.
    /// - Parameters:
    ///   - expenses: The root expense object
    ///   - item: The expense item to edit guranteed to be in the root expense object
    init(expenses: Expense, item: ExpenseItem?) {
        self.expenses = expenses
        self.item = item
    }
}

#Preview {
    let expenses = Expense()
    AddView(expenses: expenses, item: expenses.items.first)
}

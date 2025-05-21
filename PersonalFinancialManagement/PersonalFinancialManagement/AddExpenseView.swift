//
//  AddExpenseView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 16.05.2025.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: Category = .diger
    @State private var selectedDate: Date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Harcama Bilgisi")) {
                    TextField("Başlık", text: $title)
                        .autocapitalization(.sentences)

                    TextField("Tutar (₺)", text: $amount)
                        .keyboardType(.decimalPad)

                    DatePicker("Tarih Seç", selection: $selectedDate, displayedComponents: .date)
                }

                Section(header: Text("Kategori")) {
                    Picker("Kategori Seç", selection: $selectedCategory) {
                        ForEach(Category.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }
            }
            .navigationTitle("Harcama Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        Double(amount) != nil
    }

    private func saveExpense() {
        guard let value = Double(amount) else { return }
        viewModel.addExpense(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: value,
            category: selectedCategory,
            date: selectedDate
        )
        dismiss()
    }
}

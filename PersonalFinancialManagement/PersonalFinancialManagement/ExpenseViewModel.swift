//ExpenseViewModel.swift
import Foundation
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { saveExpenses() }
    }

    // MARK: - Init

    init() {
        loadExpenses()
    }

    // MARK: - Ekle / Sil

    func addExpense(title: String, amount: Double, category: Category) {
        let newExpense = Expense(
            title: title,
            amount: amount,
            category: category,
            date: Date()
        )
        expenses.append(newExpense)
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

    // MARK: - Verileri Kalıcı Sakla

    private func saveExpenses() {
        if let encoded = try? JSONEncoder().encode(expenses) {
            UserDefaults.standard.set(encoded, forKey: "expenses")
        }
    }

    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "expenses"),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            expenses = decoded
        }
    }

    // MARK: - Kategoriye Göre Toplam

    func totalPerCategory() -> [Category: Double] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals
    }
}

// MARK: - İstatistiksel Filtreler

extension ExpenseViewModel {

    /// Her gün için toplam harcamayı döndürür
    func totalPerDay() -> [String: Double] {
        var result: [String: Double] = [:]
        for expense in expenses {
            let day = DateFormatter.localizedString(from: expense.date, dateStyle: .short, timeStyle: .none)
            result[day, default: 0] += expense.amount
        }
        return result
    }

    /// Her hafta için toplam harcamayı döndürür
    func totalPerWeek() -> [String: Double] {
        var result: [String: Double] = [:]
        let calendar = Calendar.current

        for expense in expenses {
            let week = calendar.component(.weekOfYear, from: expense.date)
            let year = calendar.component(.yearForWeekOfYear, from: expense.date)
            let key = "Hafta \(week), \(year)"
            result[key, default: 0] += expense.amount
        }
        return result
    }

    /// Her ay için toplam harcamayı döndürür
    func totalPerMonth() -> [String: Double] {
        var result: [String: Double] = [:]
        let calendar = Calendar.current

        for expense in expenses {
            let month = calendar.component(.month, from: expense.date)
            let year = calendar.component(.year, from: expense.date)
            let key = "\(year)-\(month)"
            result[key, default: 0] += expense.amount
        }
        return result
    }

    /// Her yıl için toplam harcamayı döndürür
    func totalPerYear() -> [String: Double] {
        var result: [String: Double] = [:]
        let calendar = Calendar.current

        for expense in expenses {
            let year = calendar.component(.year, from: expense.date)
            result["\(year)", default: 0] += expense.amount
        }
        return result
    }

    /// Bu haftaki toplam harcama
    func totalThisWeek() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }

    /// Geçen haftaki toplam harcama
    func totalPreviousWeek() -> Double {
        let calendar = Calendar.current
        guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
            return 0
        }
        return expenses
            .filter { calendar.isDate($0.date, equalTo: previousWeek, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }
}

import Foundation
import SwiftUI

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { saveExpenses() }
    }

    @AppStorage("monthlyLimit") var monthlyLimit: Double = 0.0

    init() {
        loadExpenses()
    }

    func addExpense(title: String, amount: Double, category: Category, date: Date) {
        let newExpense = Expense(title: title, amount: amount, category: category, date: date)
        expenses.append(newExpense)
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

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

    func isLimitExceeded() -> Bool {
        monthlyLimit > 0 && totalThisMonth() > monthlyLimit
    }

    func totalThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    // Toplam harcamalar kategoriye göre
    func totalPerCategory() -> [Category: Double] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals
    }

    // Toplam harcamalar yıla göre (String olarak)
    func totalPerYear() -> [String: Double] {
        let calendar = Calendar.current
        var result: [String: Double] = [:]
        for expense in expenses {
            let year = calendar.component(.year, from: expense.date)
            result["\(year)", default: 0] += expense.amount
        }
        return result
    }

    // Toplam harcamalar aya göre (String olarak "YYYY-M" formatında)
    func totalPerMonth() -> [String: Double] {
        let calendar = Calendar.current
        var result: [String: Double] = [:]
        for expense in expenses {
            let year = calendar.component(.year, from: expense.date)
            let month = calendar.component(.month, from: expense.date)
            let key = "\(year)-\(month)"
            result[key, default: 0] += expense.amount
        }
        return result
    }

    // Toplam harcamalar haftaya göre (String olarak "Hafta W, YYYY")
    func totalPerWeek() -> [String: Double] {
        let calendar = Calendar.current
        var result: [String: Double] = [:]
        for expense in expenses {
            let week = calendar.component(.weekOfYear, from: expense.date)
            let year = calendar.component(.yearForWeekOfYear, from: expense.date)
            let key = "Hafta \(week), \(year)"
            result[key, default: 0] += expense.amount
        }
        return result
    }

    // Toplam harcamalar güne göre (String olarak)
    func totalPerDay() -> [String: Double] {
        var result: [String: Double] = [:]
        for expense in expenses {
            let day = DateFormatter.localizedString(from: expense.date, dateStyle: .short, timeStyle: .none)
            result[day, default: 0] += expense.amount
        }
        return result
    }

    // Bu haftaki toplam harcama
    func totalThisWeek() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses.filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }

    // Geçen haftaki toplam harcama
    func totalPreviousWeek() -> Double {
        let calendar = Calendar.current
        guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
            return 0
        }
        return expenses.filter { calendar.isDate($0.date, equalTo: previousWeek, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }
}

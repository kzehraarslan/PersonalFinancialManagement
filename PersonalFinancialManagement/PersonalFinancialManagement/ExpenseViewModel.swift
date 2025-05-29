import Foundation
import SwiftUI
import UserNotifications

class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = [] {
        didSet { saveExpenses() }
    }
    
    @AppStorage("monthlyLimit") var monthlyLimit: Double = 0.0

    init() {
        loadExpenses()
        // Uygulama açıldığında bildirim yetkisi iste
        requestNotificationAuthorization()
        
        // ✅ Uygulama açıldığında limit kontrolü yap
        checkLimitOnLaunch()
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }

    func addExpense(title: String, amount: Double, category: Category, date: Date, photoData: Data? = nil) {
        var newExpense = Expense(
            id: UUID(),
            title: title,
            amount: amount,
            category: category,
            date: date
        )
        newExpense.photoData = photoData
        expenses.insert(newExpense, at: 0)
        
        if isLimitExceeded() {
            sendLimitExceededNotification()
        }
    }

    func deleteExpense(at offsets: IndexSet) {
        expenses.remove(atOffsets: offsets)
    }

    private func saveExpenses() {
        do {
            let encoded = try JSONEncoder().encode(expenses)
            UserDefaults.standard.set(encoded, forKey: "expenses")
        } catch {
            print("Harcama verilerini kaydetme hatası: \(error.localizedDescription)")
        }
    }

    private func loadExpenses() {
        if let data = UserDefaults.standard.data(forKey: "expenses") {
            do {
                let decoded = try JSONDecoder().decode([Expense].self, from: data)
                expenses = decoded
            } catch {
                print("Harcama verilerini yükleme hatası: \(error.localizedDescription)")
            }
        }
    }

    func isLimitExceeded() -> Bool {
        monthlyLimit > 0 && totalThisMonth() > monthlyLimit
    }

    func totalThisMonth() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .month) }
            .reduce(0) { $0 + $1.amount }
    }

    func totalPerCategory() -> [Category: Double] {
        var totals: [Category: Double] = [:]
        for expense in expenses {
            totals[expense.category, default: 0] += expense.amount
        }
        return totals
    }

    func totalPerYear() -> [String: Double] {
        var result: [String: Double] = [:]
        let calendar = Calendar.current
        for expense in expenses {
            let year = calendar.component(.year, from: expense.date)
            result["\(year)", default: 0] += expense.amount
        }
        return result
    }

    func totalPerMonth() -> [String: Double] {
        var result: [String: Double] = [:]
        let calendar = Calendar.current
        for expense in expenses {
            let year = calendar.component(.year, from: expense.date)
            let month = calendar.component(.month, from: expense.date)
            let key = "\(year)-\(month)"
            result[key, default: 0] += expense.amount
        }
        return result
    }

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

    func totalPerDay() -> [String: Double] {
        var result: [String: Double] = [:]
        for expense in expenses {
            let day = DateFormatter.localizedString(from: expense.date, dateStyle: .short, timeStyle: .none)
            result[day, default: 0] += expense.amount
        }
        return result
    }

    func totalThisWeek() -> Double {
        let calendar = Calendar.current
        let now = Date()
        return expenses
            .filter { calendar.isDate($0.date, equalTo: now, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }

    func totalPreviousWeek() -> Double {
        let calendar = Calendar.current
        guard let previousWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: Date()) else {
            return 0
        }
        return expenses
            .filter { calendar.isDate($0.date, equalTo: previousWeek, toGranularity: .weekOfYear) }
            .reduce(0) { $0 + $1.amount }
    }

    func topCategory() -> (category: Category, amount: Double)? {
        let totals = totalPerCategory()
        guard let max = totals.max(by: { $0.value < $1.value }) else { return nil }
        return (max.key, max.value)
    }

    func topDay() -> (day: String, amount: Double)? {
        let totals = totalPerDay()
        guard let max = totals.max(by: { $0.value < $1.value }) else { return nil }
        return (max.key, max.value)
    }

    func totalSpending() -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    private func sendLimitExceededNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Aylık Limit Aşıldı!"
        content.body = "Aylık harcama limitiniz aşıldı, dikkatli harcama yapın."
        content.sound = .default
        
        let request = UNNotificationRequest(identifier: "limitExceeded", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Limit aşıldı bildirimi gönderilemedi: \(error.localizedDescription)")
            }
        }
    }
    
    // ✅ Yeni fonksiyon: Uygulama açıldığında limiti kontrol et ve bildirimi tetikle
    private func checkLimitOnLaunch() {
        if isLimitExceeded() {
            sendLimitExceededNotification()
        }
    }
}

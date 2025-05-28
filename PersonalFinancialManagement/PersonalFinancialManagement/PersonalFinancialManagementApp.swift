//
//  PersonalFinancialManagementApp.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 16.05.2025.
//
import SwiftUI
import UserNotifications

@main
struct PersonalFinancialManagementApp: App {
    // Kullanıcının adını saklar — giriş yapılmış mı kontrol eder
    @AppStorage("username") private var username: String = ""
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = "system"

    enum AppTheme: String {
        case system, light, dark
    }

    var selectedTheme: ColorScheme? {
        switch AppTheme(rawValue: selectedThemeRaw) ?? .system {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
    
    // Bildirim yetkisi iste ve günlük bildirim ayarla
    init() {
        requestNotificationAuthorization()
        scheduleDailyReminder()
    }
    
    private func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Bildirim izni isteğinde hata: \(error.localizedDescription)")
            } else if granted {
                print("Bildirim izni verildi.")
            } else {
                print("Bildirim izni reddedildi.")
            }
        }
    }

    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Bugün Harcama Yaptın mı?"
        content.body = "Günlük harcama kaydını unutma!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = 20  // Her gün saat 20:00'de
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Günlük bildirim planlama hatası: \(error.localizedDescription)")
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if username.isEmpty {
                LoginView()
                    .preferredColorScheme(selectedTheme)
            } else {
                ContentView()
                    .preferredColorScheme(selectedTheme)
            }
        }
    }
}

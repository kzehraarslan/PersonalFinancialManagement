//
//  PersonalFinancialManagementApp.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 16.05.2025.
//
import SwiftUI

@main
struct PersonalFinancialManagementApp: App {
    // Kullanıcının adını saklar — giriş yapılmış mı kontrol eder
    @AppStorage("username") private var username: String = ""

    var body: some Scene {
        WindowGroup {
            if username.isEmpty {
                // Kullanıcı giriş yapmamış → Login ekranı göster
                LoginView()
            } else {
                // Giriş yapılmış → Ana uygulama göster
                ContentView()
            }
        }
    }
}

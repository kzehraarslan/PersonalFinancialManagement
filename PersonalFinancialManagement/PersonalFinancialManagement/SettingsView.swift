//
//  SettingsView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 29.05.2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("notificationFrequency") private var notificationFrequency: Int = 1 // Varsayılan günlük (1)
    @StateObject private var languageManager = AppLanguageManager.shared

    // Desteklenen diller ve gösterim isimleri
    private let supportedLanguages = [
        ("en", "English"),
        ("tr", "Türkçe")
    ]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Bildirim Sıklığı")) {
                    Picker("Sıklık", selection: $notificationFrequency) {
                        Text("Günlük").tag(1)
                        Text("Haftalık").tag(7)
                        Text("Aylık").tag(30)
                        Text("Bildirim Yok").tag(0)
                    }
                    .pickerStyle(.inline)
                }
                
                Section(header: Text("Dil Seçimi")) {
                    Picker("Dil", selection: $languageManager.currentLanguage) {
                        ForEach(supportedLanguages, id: \.0) { code, name in
                            Text(name).tag(code)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section(footer: Text("Bu ayarlar cihazınıza bildirim göndermemizi sağlar. Lütfen bildirim izinlerini kontrol edin.")) {
                    Button("Kaydet") {
                        NotificationManager.shared.scheduleReminderNotification(frequencyInDays: notificationFrequency)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Ayarlar")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}

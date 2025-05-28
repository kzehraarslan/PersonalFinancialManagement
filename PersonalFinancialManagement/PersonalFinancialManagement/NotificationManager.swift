//
//  NotificationManager.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 28.05.2025.
//
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }
}
extension NotificationManager {
    func scheduleLimitExceededNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Harcama Limiti Aşıldı!"
        content.body = "Aylık harcama limitini aştınız, dikkat edin."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "limitExceeded", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func scheduleDailyReminder() {
        var dateComponents = DateComponents()
        dateComponents.hour = 20  // Örnek: Her gün saat 20:00'de

        let content = UNMutableNotificationContent()
        content.title = "Bugün Harcama Yaptın mı?"
        content.body = "Günlük harcama kaydını unutma!"
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
}

import UserNotifications
import SwiftUI

class NotificationManager {
    static let shared = NotificationManager()

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if let error = error {
                print("Bildirim izni hatası: \(error.localizedDescription)")
            }
        }
    }

    func scheduleLimitExceededNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Harcama Limiti Aşıldı!"
        content.body = "Aylık harcama limitini aştınız, dikkat edin."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "limitExceeded", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Limit bildirimi gönderilemedi: \(error.localizedDescription)")
            }
        }
    }

    func scheduleReminderNotification(frequencyInDays: Int) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["reminderNotification"])
        guard frequencyInDays > 0 else {
            print("Bildirim kapatıldı.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Bugün Harcama Yaptın mı?"
        content.body = "Harcama kaydını unutma!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 20

        let trigger: UNNotificationTrigger
        if frequencyInDays == 1 {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        } else {
            let interval = TimeInterval(86400 * frequencyInDays)
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: true)
        }

        let request = UNNotificationRequest(identifier: "reminderNotification", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Hatırlatma bildirimi gönderilemedi: \(error.localizedDescription)")
            } else {
                print("Hatırlatma bildirimi başarıyla ayarlandı. Sıklık: \(frequencyInDays) gün.")
            }
        }
    }
}

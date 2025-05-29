//
//  AppLanguageManager.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 29.05.2025.
//

import Foundation
import SwiftUI
import ObjectiveC.runtime

final class AppLanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "appLanguage")
            Bundle.setLanguage(currentLanguage)
        }
    }
    
    static let shared = AppLanguageManager()
    
    private init() {
        let savedLang = UserDefaults.standard.string(forKey: "appLanguage")
        self.currentLanguage = savedLang ?? Locale.current.languageCode ?? "en"
        Bundle.setLanguage(currentLanguage)
    }
}

// MARK: - Bundle Extension for Language Switching

private var bundleKey: UInt8 = 0

extension Bundle {
    class func setLanguage(_ language: String) {
        defer {
            object_setClass(Bundle.main, PrivateBundle.self)
        }
        
        if let path = Bundle.main.path(forResource: language, ofType: "lproj"),
           let languageBundle = Bundle(path: path) {
            objc_setAssociatedObject(Bundle.main, &bundleKey, languageBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            print("🌐 Language bundle set for: \(language) at path: \(path)")
        } else {
            // Eğer .lproj klasörü bulunamazsa, fallback olarak ana bundle kullanılır
            print("⚠️ Language bundle not found for language code: \(language). Using main bundle.")
            objc_setAssociatedObject(Bundle.main, &bundleKey, Bundle.main, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}

private class PrivateBundle: Bundle {
    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        let bundle = objc_getAssociatedObject(self, &bundleKey) as? Bundle
        return bundle?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}

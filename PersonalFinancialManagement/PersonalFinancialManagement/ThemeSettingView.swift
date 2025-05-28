import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .system: return "Sistem Ayarları"
        case .light: return "Açık Tema"
        case .dark: return "Koyu Tema"
        }
    }
}

struct ThemeSettingView: View {
    @AppStorage("selectedTheme") private var selectedThemeRaw: String = AppTheme.system.rawValue

    // Binding oluşturuyoruz, bu sayede doğrudan selectedThemeRaw güncellenir
    private var selectedThemeBinding: Binding<AppTheme> {
        Binding<AppTheme>(
            get: { AppTheme(rawValue: selectedThemeRaw) ?? .system },
            set: { selectedThemeRaw = $0.rawValue }
        )
    }

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Tema Seçimi")) {
                    Picker("Tema", selection: selectedThemeBinding) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.inline)
                }
            }
            .navigationTitle("Tema Ayarları")
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

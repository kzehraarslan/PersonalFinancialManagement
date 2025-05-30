import SwiftUI

enum Category: String, Codable, CaseIterable, Identifiable {
    case market = "Market"
    case ulasim = "Ulaşım"
    case eglence = "Eğlence"
    case yemek = "Yemek"
    case giyim = "Giyim"
    case fatura = "Fatura"
    case diger = "Diğer"

    var id: String { rawValue }

    var color: Color {
        switch self {
        case .market: return .green
        case .ulasim: return .blue
        case .eglence: return .orange
        case .yemek: return .red
        case .giyim: return .black
        case .fatura: return .purple
        case .diger: return .gray
        }
    }

    var icon: String {
        switch self {
        case .market: return "🛒"
        case .ulasim: return "🚗"
        case .eglence: return "🎮"
        case .yemek: return "🍽️"
        case .giyim: return "👔"
        case .fatura: return "💡"
        case .diger: return "📌"
        }
    }
}

struct Expense: Identifiable, Codable {
    var id = UUID()
    var title: String
    var amount: Double
    var category: Category
    var date: Date
    
    // Base64 string olarak saklanan fotoğraf verisi (opsiyonel)
    var photoDataBase64: String?

    // Data tipinde photoData erişimi, Base64 ile encoding/decoding sağlanır
    var photoData: Data? {
        get {
            guard let base64 = photoDataBase64 else { return nil }
            return Data(base64Encoded: base64)
        }
        set {
            photoDataBase64 = newValue?.base64EncodedString()
        }
    }

    // Codable için manuel keyler
    enum CodingKeys: String, CodingKey {
        case id, title, amount, category, date, photoDataBase64
    }
}

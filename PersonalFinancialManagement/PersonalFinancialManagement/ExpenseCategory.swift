//
//  Category.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 28.05.2025.
//
import SwiftUI

enum ExpenseCategory: String, Codable, CaseIterable, Identifiable {
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

//
//  SpendingHabitsView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 28.05.2025.
//
import SwiftUI

struct SpendingHabitsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if let topCat = viewModel.topCategory() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("En Çok Harcama Yapılan Kategori:")
                            .font(.headline)
                        HStack {
                            Text(topCat.category.rawValue)
                                .bold()
                            Spacer()
                            Text(String(format: "%.2f₺", topCat.amount))
                        }
                    }
                }

                if let topDay = viewModel.topDay() {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("En Çok Harcama Yapılan Gün:")
                            .font(.headline)
                        HStack {
                            Text(topDay.day)
                                .bold()
                            Spacer()
                            Text(String(format: "%.2f₺", topDay.amount))
                        }
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Toplam Harcama:")
                        .font(.headline)
                    Text(String(format: "%.2f₺", viewModel.totalSpending()))
                        .bold()
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Harcama Alışkanlıkları")
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

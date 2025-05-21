//
//  LimitSettingView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 21.05.2025.
//

import SwiftUI

struct LimitSettingView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var limitInput: String = ""
    @State private var showSavedMessage = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Aylık Harcama Limiti")) {
                    TextField("₺ Limit Belirle", text: $limitInput)
                        .keyboardType(.decimalPad)

                    Button("Limiti Kaydet") {
                        if let value = Double(limitInput), value >= 0 {
                            viewModel.monthlyLimit = value
                            showSavedMessage = true
                        }
                    }
                }

                Section {
                    Text("Bu ayki harcama: \(String(format: "%.2f₺", viewModel.totalThisMonth()))")
                    Text("Belirlenen limit: \(String(format: "%.2f₺", viewModel.monthlyLimit))")
                        .foregroundColor(.gray)

                    if viewModel.isLimitExceeded() {
                        Text("⚠️ Limit aşıldı!")
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Limit Ayarları")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                limitInput = viewModel.monthlyLimit > 0 ? String(format: "%.2f", viewModel.monthlyLimit) : ""
            }
            .alert(isPresented: $showSavedMessage) {
                Alert(title: Text("Başarılı"),
                      message: Text("Aylık limit güncellendi."),
                      dismissButton: .default(Text("Tamam")) {
                          dismiss()
                      })
            }
        }
    }
}

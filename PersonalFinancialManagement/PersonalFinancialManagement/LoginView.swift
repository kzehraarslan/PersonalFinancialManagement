//
//  LoginView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 17.05.2025.
//
import SwiftUI

struct LoginView: View {
    @AppStorage("username") private var username: String = ""
    @State private var nameInput: String = ""
    @State private var showAlert: Bool = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            Text("💸 Harcama Takibi")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Devam etmek için adınızı girin")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("Adınızı girin", text: $nameInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .autocapitalization(.words)

            Button(action: handleLogin) {
                Text("Giriş Yap")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Hata"),
                message: Text("Lütfen adınızı giriniz."),
                dismissButton: .default(Text("Tamam"))
            )
        }
    }

    private func handleLogin() {
        let trimmed = nameInput.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            showAlert = true
        } else {
            username = trimmed
        }
    }
}

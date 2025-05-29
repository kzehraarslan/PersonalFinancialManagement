//
//  ContentView.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 29.05.2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var selectedCategory: Category? = nil
    @State private var showingAddExpense = false
    @State private var showingStats = false
    @State private var showingLimitSettings = false
    @State private var showingThemeSettings = false
    @State private var showingSettings = false
    @State private var selectedExpense: Expense? = nil
    @State private var showExportMenu = false
    @State private var shareFileURL: URL? = nil
    @AppStorage("username") private var username: String = ""
    @StateObject private var languageManager = AppLanguageManager.shared

    var filteredExpenses: [Expense] {
        if let category = selectedCategory {
            return viewModel.expenses.filter { $0.category == category }
        } else {
            return viewModel.expenses
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                if viewModel.isLimitExceeded() {
                    Text("⚠️ Aylık harcama limitini aştın!")
                        .foregroundColor(.red)
                        .bold()
                        .padding(.vertical, 8)
                }

                Picker("Kategori Seç", selection: $selectedCategory) {
                    Text("Tümü").tag(Category?.none)
                    ForEach(Category.allCases) { category in
                        Text(category.rawValue).tag(Optional(category))
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                List {
                    ForEach(filteredExpenses) { expense in
                        HStack(spacing: 15) {
                            if let data = expense.photoData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                    .clipped()
                            }

                            VStack(alignment: .leading) {
                                Text(expense.title)
                                    .font(.headline)
                                Text(expense.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text(String(format: "%.2f₺", expense.amount))
                                    .font(.headline)
                                Text(expense.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedExpense = expense
                        }
                    }
                    .onDelete { indexSet in
                        viewModel.deleteExpense(at: indexSet)
                    }
                }
            }
            .navigationTitle("Hoş geldin, \(username)")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Menu {
                        Button {
                            showingStats = true
                        } label: {
                            Label("İstatistikler", systemImage: "chart.bar.fill")
                        }

                        Button {
                            showingLimitSettings = true
                        } label: {
                            Label("Limit Ayarları", systemImage: "slider.horizontal.3")
                        }

                        Button {
                            showingThemeSettings = true
                        } label: {
                            Label("Tema Ayarları", systemImage: "paintbrush")
                        }

                        Button {
                            showingSettings = true
                        } label: {
                            Label("Genel Ayarlar", systemImage: "gear")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }

                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }

                    Button {
                        showExportMenu = true
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }

                    Menu {
                        Button(role: .destructive) {
                            username = ""
                        } label: {
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                        }
                    } label: {
                        Image(systemName: "person.crop.circle")
                    }
                }
            }
            .actionSheet(isPresented: $showExportMenu) {
                ActionSheet(
                    title: Text("Paylaşım Şekli Seçin"),
                    buttons: [
                        .default(Text("CSV Olarak Paylaş")) { exportCSV() },
                        .default(Text("PDF Olarak Paylaş")) { exportPDF() },
                        .cancel()
                    ]
                )
            }
            .sheet(isPresented: Binding<Bool>(
                get: { shareFileURL != nil },
                set: { if !$0 { shareFileURL = nil } }
            )) {
                if let url = shareFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                StatisticsView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingLimitSettings) {
                LimitSettingView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingThemeSettings) {
                ThemeSettingView()
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $selectedExpense) { expense in
                EditExpenseView(viewModel: viewModel, expense: expense)
            }
        }
    }

    func exportCSV() {
        let csvString = CSVExportManager.generateCSV(from: viewModel.expenses)
        if let fileURL = CSVExportManager.exportCSVFile(named: "HarcamaRaporu", content: csvString) {
            shareFileURL = fileURL
        }
    }

    func exportPDF() {
        if let fileURL = PDFReportManager.createPDF(expenses: viewModel.expenses, monthlyLimit: viewModel.monthlyLimit) {
            shareFileURL = fileURL
        }
    }
}

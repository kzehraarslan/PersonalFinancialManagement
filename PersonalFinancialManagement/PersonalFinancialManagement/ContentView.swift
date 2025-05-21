//  ContentView.swift
import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var selectedCategory: Category? = nil
    @State private var showingAddExpense = false
    @State private var showingStats = false
    @State private var selectedExpense: Expense? = nil
    @AppStorage("username") private var username: String = ""

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
                // Kategori filtreleme menüsü
                Picker("Kategori Seç", selection: $selectedCategory) {
                    Text("Tümü").tag(Category?.none)
                    ForEach(Category.allCases) { category in
                        Text(category.rawValue).tag(Optional(category))
                    }
                }
                .pickerStyle(.menu)
                .padding(.horizontal)

                // Harcama listesi
                List {
                    ForEach(filteredExpenses) { expense in
                        HStack {
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
                    .onDelete(perform: viewModel.deleteExpense)
                }
            }
            .navigationTitle("Hoş geldin, \(username)")
            .toolbar {
                // Grafik Sayfası
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingStats = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }

                // Harcama Ekle
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                // Çıkış Yap Menüsü
                ToolbarItem(placement: .navigationBarTrailing) {
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
            // Sayfa geçişleri
            .sheet(isPresented: $showingAddExpense) {
                AddExpenseView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingStats) {
                StatisticsView(viewModel: viewModel)
            }
            .sheet(item: $selectedExpense) { expense in
                EditExpenseView(viewModel: viewModel, expense: expense)
            }
        }
    }
}

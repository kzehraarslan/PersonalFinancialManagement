import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ExpenseViewModel()
    @State private var selectedCategory: Category? = nil
    @State private var showingAddExpense = false
    @State private var showingStats = false
    @State private var showingLimitSettings = false
    @State private var showingThemeSettings = false
    @State private var selectedExpense: Expense? = nil
    @State private var showingShareSheet = false
    @State private var exportURL: URL? = nil
    @State private var showingPDFShareSheet = false
    @State private var pdfURL: URL? = nil
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
                            // Fotoğraf varsa göster
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
                    Button {
                        showingStats = true
                    } label: {
                        Image(systemName: "chart.bar.fill")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingLimitSettings = true
                    } label: {
                        Image(systemName: "slider.horizontal.3")
                    }
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingThemeSettings = true
                    } label: {
                        Image(systemName: "paintbrush")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddExpense = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportCSV()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        exportPDF()
                    } label: {
                        Image(systemName: "doc.richtext")
                    }
                }

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
            .sheet(item: $selectedExpense) { expense in
                EditExpenseView(viewModel: viewModel, expense: expense)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportURL = exportURL {
                    ShareSheet(activityItems: [exportURL])
                }
            }
            .sheet(isPresented: $showingPDFShareSheet) {
                if let pdfURL = pdfURL {
                    ShareSheet(activityItems: [pdfURL])
                }
            }
        }
    }

    func exportCSV() {
        let csvString = CSVExportManager.generateCSV(from: viewModel.expenses)
        if let fileURL = CSVExportManager.exportCSVFile(named: "HarcamaRaporu", content: csvString) {
            exportURL = fileURL
            showingShareSheet = true
        }
    }

    func exportPDF() {
        if let fileURL = PDFReportManager.createPDF(expenses: viewModel.expenses, monthlyLimit: viewModel.monthlyLimit) {
            pdfURL = fileURL
            showingPDFShareSheet = true
        }
    }
}

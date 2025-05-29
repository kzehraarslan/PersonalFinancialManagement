import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var title: String
    @State private var amount: String
    @State private var selectedCategory: Category
    @State private var selectedDate: Date
    @State private var photoData: Data?  // Fotoğraf verisi
    @State private var showImagePicker = false

    // Fotoğrafı tam ekran göstermek için
    @State private var showFullScreenPhoto = false

    let expense: Expense

    init(viewModel: ExpenseViewModel, expense: Expense) {
        self.viewModel = viewModel
        self.expense = expense
        _title = State(initialValue: expense.title)
        _amount = State(initialValue: String(format: "%.2f", expense.amount))
        _selectedCategory = State(initialValue: expense.category)
        _selectedDate = State(initialValue: expense.date)
        _photoData = State(initialValue: expense.photoData)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Harcama Bilgisi")) {
                    TextField("Başlık", text: $title)
                        .autocapitalization(.sentences)

                    TextField("Tutar (₺)", text: $amount)
                        .keyboardType(.decimalPad)

                    DatePicker("Tarih Seç", selection: $selectedDate, displayedComponents: .date)
                }

                Section(header: Text("Kategori")) {
                    Picker("Kategori Seç", selection: $selectedCategory) {
                        ForEach(Category.allCases) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section(header: Text("Fotoğraf")) {
                    Button("Fotoğraf Seç") {
                        showImagePicker = true
                    }

                    if let data = photoData, let uiImage = UIImage(data: data) {
                        VStack {
                            Image(uiImage: uiImage)
                                .resizable()
                                .frame(width: 100, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .onTapGesture {
                                    showFullScreenPhoto = true
                                }

                            Button(role: .destructive) {
                                photoData = nil
                            } label: {
                                Label("Fotoğrafı Sil", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                            .buttonStyle(.borderless)
                        }
                    }
                }
            }
            .navigationTitle("Harcama Düzenle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Güncelle") {
                        updateExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
            .sheet(isPresented: $showImagePicker) {
                ImagePicker(imageData: $photoData)
            }
            .fullScreenCover(isPresented: $showFullScreenPhoto) {
                if let data = photoData, let uiImage = UIImage(data: data) {
                    FullScreenPhotoViewControllerWrapper(image: uiImage)
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && Double(amount) != nil
    }

    private func updateExpense() {
        guard let value = Double(amount) else { return }
        if let index = viewModel.expenses.firstIndex(where: { $0.id == expense.id }) {
            viewModel.expenses[index].title = title.trimmingCharacters(in: .whitespaces)
            viewModel.expenses[index].amount = value
            viewModel.expenses[index].category = selectedCategory
            viewModel.expenses[index].date = selectedDate
            viewModel.expenses[index].photoData = photoData // Fotoğraf verisini güncelle
        }
        dismiss()
    }
}

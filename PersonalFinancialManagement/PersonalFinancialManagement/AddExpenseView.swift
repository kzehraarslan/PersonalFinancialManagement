import SwiftUI
import PhotosUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ExpenseViewModel

    @State private var title: String = ""
    @State private var amount: String = ""
    @State private var selectedCategory: Category = .diger
    @State private var selectedDate: Date = Date()
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var selectedPhotoData: Data? = nil

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

                Section(header: Text("Fiş Fotoğrafı (Opsiyonel)")) {
                    PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                        HStack {
                            Image(systemName: "photo")
                            Text(selectedPhotoItem == nil ? "Fotoğraf Seç" : "Fotoğraf Seçildi")
                        }
                    }
                    if let data = selectedPhotoData, let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationTitle("Harcama Ekle")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveExpense()
                    }
                    .disabled(!isFormValid)
                }
            }
            .onChange(of: selectedPhotoItem) { newItem in
                if let newItem = newItem {
                    Task {
                        if let data = try? await newItem.loadTransferable(type: Data.self) {
                            selectedPhotoData = data
                        }
                    }
                }
            }
        }
    }

    private var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty && Double(amount) != nil
    }

    private func saveExpense() {
        guard let value = Double(amount) else { return }
        viewModel.addExpense(
            title: title.trimmingCharacters(in: .whitespaces),
            amount: value,
            category: selectedCategory,
            date: selectedDate,
            photoData: selectedPhotoData
        )
        dismiss()
    }
}

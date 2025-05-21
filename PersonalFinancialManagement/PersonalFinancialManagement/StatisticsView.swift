import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Kategoriye Göre Harcamalar
                    Text("Kategoriye Göre Harcamalar")
                        .font(.headline)

                    PieChartView(data: viewModel.totalPerCategory())
                        .frame(height: 250)

                    Divider()

                    // Yıllık Harcamalar
                    Text("Yıllık Harcamalar")
                        .font(.headline)

                    BarChartView(data: viewModel.totalPerYear(), barColor: .purple)
                        .frame(height: 200)

                    Divider()

                    // Aylık Harcamalar
                    Text("Aylık Harcamalar")
                        .font(.headline)

                    BarChartView(data: viewModel.totalPerMonth(), barColor: .orange)
                        .frame(height: 200)

                    Divider()

                    // Haftalık Harcamalar
                    Text("Haftalık Harcamalar")
                        .font(.headline)

                    BarChartView(data: viewModel.totalPerWeek(), barColor: .blue)
                        .frame(height: 200)

                    // Haftalık uyarı
                    let thisWeek = viewModel.totalThisWeek()
                    let previousWeek = viewModel.totalPreviousWeek()

                    Text(thisWeek > previousWeek
                         ? "⚠️ Bu hafta geçen haftadan daha fazla harcama yaptın! Tasarruf yapmaya çalış."
                         : "Bu hafta geçen haftadan daha az harcama yaptın. Tebrikler!")
                        .foregroundColor(thisWeek > previousWeek ? .red : .green)
                        .padding(.top, 8)

                    Divider()

                    // Günlük Harcamalar
                    Text("Günlük Harcamalar")
                        .font(.headline)

                    BarChartView(data: viewModel.totalPerDay(), barColor: .pink)
                        .frame(height: 200)
                }
                .padding()
            }
            .navigationTitle("İstatistikler")
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

// Basit Pie Chart View
struct PieChartView: View {
    let data: [Category: Double]

    var body: some View {
        Chart {
            ForEach(Array(data), id: \.key) { category, total in
                SectorMark(
                    angle: .value("Tutar", total),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.5
                )
                .foregroundStyle(category.color)
                .annotation(position: .overlay) {
                    Text(category.rawValue)
                        .font(.caption2)
                        .foregroundColor(.white)
                }
            }
        }
    }
}

// Basit Bar Chart View
struct BarChartView: View {
    let data: [String: Double]
    let barColor: Color

    var body: some View {
        Chart {
            ForEach(Array(data).sorted(by: { $0.key < $1.key }), id: \.key) { key, total in
                BarMark(
                    x: .value("Kategori", key),
                    y: .value("Tutar", total)
                )
                .foregroundStyle(barColor)
                .annotation(position: .top) {
                    Text(String(format: "%.0f₺", total))
                        .font(.caption2)
                }
            }
        }
    }
}

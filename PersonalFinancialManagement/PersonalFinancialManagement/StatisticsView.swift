//  StatisticsView.swift
import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var viewModel: ExpenseViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    Group {
                        Text("Kategoriye Göre Harcamalar")
                            .font(.headline)

                        Chart {
                            ForEach(Array(viewModel.totalPerCategory()), id: \.key) { category, total in
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
                        .frame(height: 250)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Yıllık Harcamalar")
                            .font(.headline)
                        Chart {
                            ForEach(Array(viewModel.totalPerYear()).sorted(by: { $0.key < $1.key }), id: \.key) { year, total in
                                BarMark(
                                    x: .value("Yıl", year),
                                    y: .value("Tutar", total)
                                )
                                .foregroundStyle(.purple)
                                .annotation(position: .top) {
                                    Text(String(format: "%.0f₺", total))
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Aylık Harcamalar")
                            .font(.headline)
                        Chart {
                            ForEach(Array(viewModel.totalPerMonth()).sorted(by: { $0.key < $1.key }), id: \.key) { month, total in
                                BarMark(
                                    x: .value("Ay", month),
                                    y: .value("Tutar", total)
                                )
                                .foregroundStyle(.orange)
                                .annotation(position: .top) {
                                    Text(String(format: "%.0f₺", total))
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Haftalık Harcamalar")
                            .font(.headline)
                        
                        Chart {
                            ForEach(Array(viewModel.totalPerWeek()).sorted(by: { $0.key < $1.key }), id: \.key) { week, total in
                                BarMark(
                                    x: .value("Hafta", week),
                                    y: .value("Tutar", total)
                                )
                                .foregroundStyle(.blue)
                                .annotation(position: .top) {
                                    Text(String(format: "%.0f₺", total))
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 200)
                        
                        // Haftalık harcama uyarısı
                        let thisWeek = viewModel.totalThisWeek()
                        let previousWeek = viewModel.totalPreviousWeek()
                        
                        if thisWeek > previousWeek {
                            Text("⚠️ Bu hafta geçen haftadan daha fazla harcama yaptın! Tasarruf yapmaya çalış.")
                                .foregroundColor(.red)
                                .padding(.top, 8)
                        } else {
                            Text("Bu hafta geçen haftadan daha az harcama yaptın. Tebrikler!")
                                .foregroundColor(.green)
                                .padding(.top, 8)
                        }
                    }
                    
                    Divider()
                    
                    Group {
                        Text("Günlük Harcamalar")
                            .font(.headline)
                        Chart {
                            ForEach(Array(viewModel.totalPerDay()).sorted(by: { $0.key < $1.key }), id: \.key) { day, total in
                                BarMark(
                                    x: .value("Gün", day),
                                    y: .value("Tutar", total)
                                )
                                .foregroundStyle(.pink)
                                .annotation(position: .top) {
                                    Text(String(format: "%.0f₺", total))
                                        .font(.caption2)
                                }
                            }
                        }
                        .frame(height: 200)
                    }
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

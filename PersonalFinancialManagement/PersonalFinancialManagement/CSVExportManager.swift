//
//  CSVExportManager.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 21.05.2025.
//
import Foundation

struct CSVExportManager {
    
    static func generateCSV(from expenses: [Expense]) -> String {
        var csv = "Başlık,Tutar,Kategori,Tarih\n"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for expense in expenses {
            let line = "\"\(expense.title)\",\"\(expense.amount)\",\"\(expense.category.rawValue)\",\"\(dateFormatter.string(from: expense.date))\""
            csv += line + "\n"
        }
        
        return csv
    }
    
    static func exportCSVFile(named fileName: String, content: String) -> URL? {
        let fileManager = FileManager.default
        let directory = fileManager.temporaryDirectory
        let fileURL = directory.appendingPathComponent("\(fileName).csv")
        
        do {
            try content.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("CSV yazma hatası:", error)
            return nil
        }
    }
}

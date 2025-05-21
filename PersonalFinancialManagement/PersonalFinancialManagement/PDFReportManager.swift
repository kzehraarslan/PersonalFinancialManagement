//
//  PDFReportManager.swift
//  PersonalFinancialManagement
//
//  Created by Zehra Arslan on 21.05.2025.
//
import PDFKit
import UIKit

struct PDFReportManager {
    
    static func createPDF(expenses: [Expense], monthlyLimit: Double) -> URL? {
        let pdfMetaData = [
            kCGPDFContextCreator: "PersonalFinancialManagement",
            kCGPDFContextAuthor: "Kullanıcı",
            kCGPDFContextTitle: "Aylık Harcama Raporu"
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageWidth = 595.2
        let pageHeight = 841.8
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { (context) in
            context.beginPage()
            
            let title = "Aylık Harcama Raporu"
            let titleAttributes = [
                NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)
            ]
            let titleSize = title.size(withAttributes: titleAttributes)
            title.draw(at: CGPoint(x: (pageWidth - titleSize.width)/2, y: 20), withAttributes: titleAttributes)
            
            // Toplam harcama ve limit
            let totalAmount = expenses.reduce(0) { $0 + $1.amount }
            let limitText = monthlyLimit > 0 ? String(format: "Aylık Limit: %.2f ₺", monthlyLimit) : "Aylık Limit: Yok"
            let totalText = String(format: "Toplam Harcama: %.2f ₺", totalAmount)
            
            let infoAttributes = [
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16)
            ]
            totalText.draw(at: CGPoint(x: 50, y: 80), withAttributes: infoAttributes)
            limitText.draw(at: CGPoint(x: 50, y: 110), withAttributes: infoAttributes)
            
            // Harcama listesi başlığı
            let headerText = "Harcamalar:"
            headerText.draw(at: CGPoint(x: 50, y: 150), withAttributes: infoAttributes)
            
            // Harcamalar listesi
            var yPosition = 180
            let lineHeight = 20
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd.MM.yyyy"
            
            for expense in expenses {
                if yPosition > Int(pageHeight) - 50 {
                    context.beginPage()
                    yPosition = 20
                }
                
                let expenseText = "\(dateFormatter.string(from: expense.date)) - \(expense.title) - \(expense.category.rawValue) - \(String(format: "%.2f ₺", expense.amount))"
                expenseText.draw(at: CGPoint(x: 50, y: CGFloat(yPosition)), withAttributes: infoAttributes)
                yPosition += lineHeight
            }
        }
        
        // Dosyayı geçici dizine kaydet
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("HarcamaRaporu.pdf")
        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("PDF yazma hatası: \(error)")
            return nil
        }
    }
}

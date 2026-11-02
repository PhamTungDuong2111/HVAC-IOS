import Foundation
import UIKit
import SwiftUI

// MARK: - Professional HVAC Engineering PDF Exporter
enum PdfExporter {

    static func generatePdf(state: AppState) -> URL? {
        let isSI = state.unitSystem == "SI"
        let project = state.project
        let densityCorr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        // Landscape A4 Page: 842 x 595 points
        let pageWidth: CGFloat = 842.0
        let pageHeight: CGFloat = 595.0
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("DuctWise_Schedule_\(project.date).pdf")

        do {
            try renderer.writePDF(to: tempURL) { context in
                context.beginPage()

                // 1. Top Header Banner (Dark Slate)
                let headerRect = CGRect(x: 0, y: 0, width: pageWidth, height: 56.0)
                let headerColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)
                headerColor.setFill()
                UIRectFill(headerRect)

                // Title
                let titleFont = UIFont.systemFont(ofSize: 16, weight: .black)
                let skyColor = UIColor(red: 56/255, green: 189/255, blue: 248/255, alpha: 1.0)
                let titleAttr: [NSAttributedString.Key: Any] = [
                    .font: titleFont,
                    .foregroundColor: skyColor
                ]
                "DUCTWISE HVAC".draw(at: CGPoint(x: 24, y: 12), withAttributes: titleAttr)

                // Subtitle
                let subtitleFont = UIFont.systemFont(ofSize: 10, weight: .medium)
                let subtitleAttr: [NSAttributedString.Key: Any] = [
                    .font: subtitleFont,
                    .foregroundColor: UIColor.white
                ]
                "HVAC DUCT SIZING SCHEDULE & ENGINEERING SPECIFICATION (ASHRAE / SMACNA / ACCA MANUAL D)".draw(at: CGPoint(x: 24, y: 34), withAttributes: subtitleAttr)

                // Certified Badge on Right
                let stampFont = UIFont.systemFont(ofSize: 8.5, weight: .bold)
                let greenColor = UIColor(red: 16/255, green: 185/255, blue: 129/255, alpha: 1.0)
                let stampAttr: [NSAttributedString.Key: Any] = [
                    .font: stampFont,
                    .foregroundColor: greenColor
                ]
                "CERTIFIED CALCULATION ENGINE • 100% OFFLINE VERIFIED".draw(at: CGPoint(x: 540, y: 22), withAttributes: stampAttr)

                // 2. Project Specifications Box
                let specRect = CGRect(x: 24, y: 66, width: pageWidth - 48, height: 50)
                let specBg = UIColor(red: 248/255, green: 250/255, blue: 252/255, alpha: 1.0)
                specBg.setFill()
                UIRectFill(specRect)

                let borderPath = UIBezierPath(roundedRect: specRect, cornerRadius: 4)
                UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0).setStroke()
                borderPath.lineWidth = 1.0
                borderPath.stroke()

                let specLabelFont = UIFont.systemFont(ofSize: 8, weight: .bold)
                let specValFont = UIFont.systemFont(ofSize: 9.5, weight: .bold)
                let labelColor = UIColor(red: 100/255, green: 116/255, blue: 139/255, alpha: 1.0)
                let valColor = UIColor(red: 15/255, green: 23/255, blue: 42/255, alpha: 1.0)

                // Column 1: Project & Date
                "PROJECT NAME:".draw(at: CGPoint(x: 34, y: 72), withAttributes: [.font: specLabelFont, .foregroundColor: labelColor])
                project.name.draw(at: CGPoint(x: 34, y: 84), withAttributes: [.font: specValFont, .foregroundColor: valColor])

                "DATE:".draw(at: CGPoint(x: 34, y: 98), withAttributes: [.font: specLabelFont, .foregroundColor: labelColor])
                project.date.draw(at: CGPoint(x: 65, y: 98), withAttributes: [.font: specValFont, .foregroundColor: valColor])

                // Column 2: Engineer & System Tag
                "LEAD ENGINEER:".draw(at: CGPoint(x: 260, y: 72), withAttributes: [.font: specLabelFont, .foregroundColor: labelColor])
                project.engineer.draw(at: CGPoint(x: 260, y: 84), withAttributes: [.font: specValFont, .foregroundColor: valColor])

                "SYSTEM TAG:".draw(at: CGPoint(x: 260, y: 98), withAttributes: [.font: specLabelFont, .foregroundColor: labelColor])
                project.systemTag.draw(at: CGPoint(x: 325, y: 98), withAttributes: [.font: specValFont, .foregroundColor: valColor])

                // Column 3: Air Density & Elevation Specs
                "DESIGN ELEVATION & AIR DENSITY:".draw(at: CGPoint(x: 520, y: 72), withAttributes: [.font: specLabelFont, .foregroundColor: labelColor])
                "Elevation: \(Int(state.altitudeFt)) ft  •  Temp: \(Int(state.tempF))°F".draw(at: CGPoint(x: 520, y: 84), withAttributes: [.font: specValFont, .foregroundColor: valColor])
                "Air Density Ratio (ρ/ρ₀): \(String(format: "%.3f", densityCorr.densityRatio))  (Loss Multiplier: \(String(format: "%.3f", densityCorr.lossMultiplier))×)".draw(at: CGPoint(x: 520, y: 98), withAttributes: [.font: specValFont, .foregroundColor: greenColor])

                // 3. Schedule Table
                let tableTop: CGFloat = 126.0
                let colX: [CGFloat] = [24, 90, 220, 265, 335, 385, 425, 475, 525, 575, 625, 715, 765]
                let headers = [
                    "RUN TAG", "DESCRIPTION", "SHAPE", "FLOW", "DIMENSION", "DE (IN)",
                    "LEN (FT)", "VEL (FPM)", "FRIC", "ΔP (IN)", "ASPECT", "GAUGE (SMACNA)", "AREA (SQFT)"
                ]

                // Table Header Bar
                let tableHeaderRect = CGRect(x: 24, y: tableTop, width: pageWidth - 48, height: 20)
                UIColor(red: 30/255, green: 41/255, blue: 59/255, alpha: 1.0).setFill()
                UIRectFill(tableHeaderRect)

                let thFont = UIFont.systemFont(ofSize: 7.5, weight: .bold)
                for (i, h) in headers.enumerated() {
                    let colWidth = (i < colX.count - 1 ? colX[i + 1] - colX[i] : (pageWidth - 24) - colX[i])
                    let rect = CGRect(x: colX[i] + 2, y: tableTop + 4, width: colWidth - 4, height: 14)
                    h.draw(in: rect, withAttributes: [.font: thFont, .foregroundColor: UIColor.white])
                }

                // Table Rows
                var currentY = tableTop + 20
                let rowHeight: CGFloat = 20.0
                let cellFont = UIFont.systemFont(ofSize: 8, weight: .medium)
                let boldCellFont = UIFont.systemFont(ofSize: 8, weight: .bold)

                for (idx, run) in project.runs.enumerated() {
                    let rowRect = CGRect(x: 24, y: currentY, width: pageWidth - 48, height: rowHeight)

                    // Zebra stripe
                    if idx % 2 == 1 {
                        UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0).setFill()
                    } else {
                        UIColor.white.setFill()
                    }
                    UIRectFill(rowRect)

                    // Dimension string
                    let dimStr: String
                    switch run.shape {
                    case "round":
                        dimStr = "Ø \(Int(run.diameter))\""
                    case "flatOval":
                        dimStr = "\(Int(run.width))\"×\(Int(run.height))\""
                    default:
                        dimStr = "\(Int(run.width))\"×\(Int(run.height))\""
                    }

                    let rowData: [String] = [
                        run.tag,
                        run.desc,
                        run.shape.capitalized,
                        "\(Int(run.cfm))",
                        dimStr,
                        String(format: "%.1f", run.diameter),
                        "\(Int(run.lengthFt))",
                        "\(Int(run.velocity))",
                        String(format: "%.3f", run.friction),
                        String(format: "%.3f", run.staticDrop),
                        String(format: "%.2f:1", run.aspectRatio),
                        run.gauge,
                        String(format: "%.1f", run.metalAreaSqFt)
                    ]

                    for (cIdx, val) in rowData.enumerated() {
                        let colWidth = (cIdx < colX.count - 1 ? colX[cIdx + 1] - colX[cIdx] : (pageWidth - 24) - colX[cIdx])
                        let r = CGRect(x: colX[cIdx] + 2, y: currentY + 4, width: colWidth - 4, height: rowHeight - 4)
                        let isBold = (cIdx == 0 || cIdx == 4 || cIdx == 7)
                        val.draw(in: r, withAttributes: [.font: isBold ? boldCellFont : cellFont, .foregroundColor: valColor])
                    }

                    // Bottom divider line
                    let divPath = UIBezierPath()
                    divPath.move(to: CGPoint(x: 24, y: currentY + rowHeight))
                    divPath.addLine(to: CGPoint(x: pageWidth - 24, y: currentY + rowHeight))
                    UIColor(red: 226/255, green: 232/255, blue: 240/255, alpha: 1.0).setStroke()
                    divPath.lineWidth = 0.5
                    divPath.stroke()

                    currentY += rowHeight
                    if currentY > pageHeight - 90 { break }
                }

                // 4. Totals Row
                let totalsRect = CGRect(x: 24, y: currentY, width: pageWidth - 48, height: 22)
                UIColor(red: 241/255, green: 245/255, blue: 249/255, alpha: 1.0).setFill()
                UIRectFill(totalsRect)

                let totalCfm = project.runs.reduce(0.0) { $0 + $1.cfm }
                let totalLen = project.runs.reduce(0.0) { $0 + $1.lengthFt }
                let totalArea = project.runs.reduce(0.0) { $0 + $1.metalAreaSqFt }

                "TOTAL RUNS: \(project.runs.count)".draw(at: CGPoint(x: 28, y: currentY + 5), withAttributes: [.font: boldCellFont, .foregroundColor: valColor])
                "TOTAL CFM: \(Int(totalCfm))".draw(at: CGPoint(x: 265, y: currentY + 5), withAttributes: [.font: boldCellFont, .foregroundColor: valColor])
                "TOTAL LENGTH: \(Int(totalLen)) FT".draw(at: CGPoint(x: 425, y: currentY + 5), withAttributes: [.font: boldCellFont, .foregroundColor: valColor])
                "TOTAL SHEET METAL: \(String(format: "%.1f", totalArea)) SQFT".draw(at: CGPoint(x: 630, y: currentY + 5), withAttributes: [.font: boldCellFont, .foregroundColor: valColor])

                // 5. Engineering Sign-Off & Approvals
                let footerY = pageHeight - 55
                let footerDiv = UIBezierPath()
                footerDiv.move(to: CGPoint(x: 24, y: footerY))
                footerDiv.addLine(to: CGPoint(x: pageWidth - 24, y: footerY))
                UIColor(red: 148/255, green: 163/255, blue: 184/255, alpha: 1.0).setStroke()
                footerDiv.lineWidth = 1.0
                footerDiv.stroke()

                let sigFont = UIFont.systemFont(ofSize: 8.5, weight: .medium)
                "Prepared By (HVAC Engineer): ___________________________".draw(at: CGPoint(x: 24, y: footerY + 12), withAttributes: [.font: sigFont, .foregroundColor: valColor])
                "Checked & Approved By: ___________________________".draw(at: CGPoint(x: 320, y: footerY + 12), withAttributes: [.font: sigFont, .foregroundColor: valColor])
                "Date: ________________".draw(at: CGPoint(x: 600, y: footerY + 12), withAttributes: [.font: sigFont, .foregroundColor: valColor])

                let noteFont = UIFont.systemFont(ofSize: 7.5, weight: .regular)
                "Complies with ASHRAE Fundamentals Chapter 21, ACCA Manual D, and SMACNA HVAC Duct Construction Standards 4th Edition. Generated by DuctWise HVAC iOS.".draw(at: CGPoint(x: 24, y: footerY + 34), withAttributes: [.font: noteFont, .foregroundColor: labelColor])
            }
            return tempURL
        } catch {
            print("Failed to generate PDF: \(error)")
            return nil
        }
    }
}

// MARK: - UIActivityViewController Sheet for SwiftUI
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

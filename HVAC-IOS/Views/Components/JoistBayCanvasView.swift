import SwiftUI

// MARK: - 2D Joist Bay Cross-Section Clearance Simulator View
struct JoistBayCanvasView: View {
    let cavityWidthIn: Double
    let cavityHeightIn: Double
    let ductShape: String
    let ductWidthIn: Double
    let ductHeightIn: Double
    let wrapThicknessIn: Double
    let linerThicknessIn: Double
    let isSI: Bool
    let statusText: String
    let statusColor: Color

    var body: some View {
        VStack(spacing: 8) {
            // Visual Canvas Container
            ZStack {
                Color(hex: "070C18") // Deep canvas dark

                GeometryReader { geo in
                    let padding: CGFloat = 36.0
                    let availableW = geo.size.width - padding * 2
                    let availableH = geo.size.height - padding * 2

                    // Calculate scale factor (pixels per inch)
                    let scaleX = availableW / CGFloat(max(cavityWidthIn, 1.0))
                    let scaleY = availableH / CGFloat(max(cavityHeightIn, 1.0))
                    let scale = min(scaleX, scaleY) * 0.92

                    let bayPixelW = CGFloat(cavityWidthIn) * scale
                    let bayPixelH = CGFloat(cavityHeightIn) * scale

                    let centerX = geo.size.width / 2.0
                    let centerY = geo.size.height / 2.0

                    let bayRect = CGRect(
                        x: centerX - bayPixelW / 2.0,
                        y: centerY - bayPixelH / 2.0,
                        width: bayPixelW,
                        height: bayPixelH
                    )

                    // 1. Framing / Joist Cavity Outline
                    Path { p in
                        p.addRect(bayRect)
                    }
                    .stroke(
                        AppTheme.borderMedium,
                        style: StrokeStyle(lineWidth: 1.5, dash: [4, 4])
                    )

                    // 2. Left & Right Joist Studs (Wood)
                    let studW: CGFloat = 16.0
                    // Left Stud
                    Path { p in
                        p.addRect(CGRect(x: bayRect.minX - studW, y: bayRect.minY, width: studW, height: bayRect.height))
                    }
                    .fill(AppTheme.joistWood.opacity(0.85))

                    // Right Stud
                    Path { p in
                        p.addRect(CGRect(x: bayRect.maxX, y: bayRect.minY, width: studW, height: bayRect.height))
                    }
                    .fill(AppTheme.joistWood.opacity(0.85))

                    // 3. Subfloor above & Ceiling below
                    let floorH: CGFloat = 10.0
                    Path { p in
                        p.addRect(CGRect(x: bayRect.minX - studW, y: bayRect.minY - floorH, width: bayRect.width + studW * 2, height: floorH))
                    }
                    .fill(Color(hex: "475569")) // Subfloor

                    Path { p in
                        p.addRect(CGRect(x: bayRect.minX - studW, y: bayRect.maxY, width: bayRect.width + studW * 2, height: floorH))
                    }
                    .fill(Color(hex: "334155")) // Ceiling Drywall

                    // 4. Duct Envelope calculations
                    let envW = (ductWidthIn + 2 * wrapThicknessIn) * Double(scale)
                    let envH = (ductHeightIn + 2 * wrapThicknessIn) * Double(scale)

                    let ductPixelW = ductWidthIn * Double(scale)
                    let ductPixelH = ductHeightIn * Double(scale)

                    // External Wrap (if any)
                    if wrapThicknessIn > 0 {
                        if ductShape == "round" {
                            Path { p in
                                p.addEllipse(in: CGRect(
                                    x: centerX - CGFloat(envW) / 2.0,
                                    y: centerY - CGFloat(envH) / 2.0,
                                    width: CGFloat(envW),
                                    height: CGFloat(envH)
                                ))
                            }
                            .fill(AppTheme.wrapInsulation.opacity(0.25))

                            Path { p in
                                p.addEllipse(in: CGRect(
                                    x: centerX - CGFloat(envW) / 2.0,
                                    y: centerY - CGFloat(envH) / 2.0,
                                    width: CGFloat(envW),
                                    height: CGFloat(envH)
                                ))
                            }
                            .stroke(AppTheme.wrapInsulation, lineWidth: 1.5)
                        } else if ductShape == "flatOval" {
                            let wrapRect = CGRect(
                                x: centerX - CGFloat(envW) / 2.0,
                                y: centerY - CGFloat(envH) / 2.0,
                                width: CGFloat(envW),
                                height: CGFloat(envH)
                            )
                            let r = min(CGFloat(envW), CGFloat(envH)) / 2.0
                            Path { p in p.addRoundedRect(in: wrapRect, cornerSize: CGSize(width: r, height: r)) }
                                .fill(AppTheme.wrapInsulation.opacity(0.25))
                            Path { p in p.addRoundedRect(in: wrapRect, cornerSize: CGSize(width: r, height: r)) }
                                .stroke(AppTheme.wrapInsulation, lineWidth: 1.5)
                        } else {
                            let wrapRect = CGRect(
                                x: centerX - CGFloat(envW) / 2.0,
                                y: centerY - CGFloat(envH) / 2.0,
                                width: CGFloat(envW),
                                height: CGFloat(envH)
                            )
                            Path { p in p.addRect(wrapRect) }
                                .fill(AppTheme.wrapInsulation.opacity(0.25))
                            Path { p in p.addRect(wrapRect) }
                                .stroke(AppTheme.wrapInsulation, lineWidth: 1.5)
                        }
                    }

                    // Metal Duct
                    if ductShape == "round" {
                        let roundRect = CGRect(
                            x: centerX - CGFloat(ductPixelW) / 2.0,
                            y: centerY - CGFloat(ductPixelH) / 2.0,
                            width: CGFloat(ductPixelW),
                            height: CGFloat(ductPixelH)
                        )
                        Path { p in p.addEllipse(in: roundRect) }
                            .fill(AppTheme.ductMetal.opacity(0.35))
                        Path { p in p.addEllipse(in: roundRect) }
                            .stroke(AppTheme.ductMetal, lineWidth: 2.0)
                    } else if ductShape == "flatOval" {
                        let ovalRect = CGRect(
                            x: centerX - CGFloat(ductPixelW) / 2.0,
                            y: centerY - CGFloat(ductPixelH) / 2.0,
                            width: CGFloat(ductPixelW),
                            height: CGFloat(ductPixelH)
                        )
                        let r = min(CGFloat(ductPixelW), CGFloat(ductPixelH)) / 2.0
                        Path { p in p.addRoundedRect(in: ovalRect, cornerSize: CGSize(width: r, height: r)) }
                            .fill(AppTheme.ductMetal.opacity(0.35))
                        Path { p in p.addRoundedRect(in: ovalRect, cornerSize: CGSize(width: r, height: r)) }
                            .stroke(AppTheme.ductMetal, lineWidth: 2.0)
                    } else {
                        let rectRect = CGRect(
                            x: centerX - CGFloat(ductPixelW) / 2.0,
                            y: centerY - CGFloat(ductPixelH) / 2.0,
                            width: CGFloat(ductPixelW),
                            height: CGFloat(ductPixelH)
                        )
                        Path { p in p.addRect(rectRect) }
                            .fill(AppTheme.ductMetal.opacity(0.35))
                        Path { p in p.addRect(rectRect) }
                            .stroke(AppTheme.ductMetal, lineWidth: 2.0)
                    }

                    // Internal Liner (if any)
                    if linerThicknessIn > 0 {
                        let linerPixel = linerThicknessIn * Double(scale)
                        let linerW = max(ductPixelW - 2 * linerPixel, 4.0)
                        let linerH = max(ductPixelH - 2 * linerPixel, 4.0)

                        if ductShape == "round" {
                            Path { p in
                                p.addEllipse(in: CGRect(
                                    x: centerX - CGFloat(linerW) / 2.0,
                                    y: centerY - CGFloat(linerH) / 2.0,
                                    width: CGFloat(linerW),
                                    height: CGFloat(linerH)
                                ))
                            }
                            .stroke(AppTheme.acousticLiner, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        } else {
                            Path { p in
                                p.addRect(CGRect(
                                    x: centerX - CGFloat(linerW) / 2.0,
                                    y: centerY - CGFloat(linerH) / 2.0,
                                    width: CGFloat(linerW),
                                    height: CGFloat(linerH)
                                ))
                            }
                            .stroke(AppTheme.acousticLiner, style: StrokeStyle(lineWidth: 1.5, dash: [2, 2]))
                        }
                    }

                    // Dimension / Clearance Indicators
                    let leftGap = (cavityWidthIn - (ductWidthIn + 2 * wrapThicknessIn)) / 2.0
                    let topGap = (cavityHeightIn - (ductHeightIn + 2 * wrapThicknessIn)) / 2.0

                    // Left Clearance Callout
                    Text("\(String(format: "%.1f", isSI ? UnitConverter.inToMm(leftGap) : leftGap))\(isSI ? "mm" : "\"")")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(leftGap >= 1.0 ? AppTheme.statusGreen : (leftGap >= 0 ? AppTheme.statusAmber : AppTheme.statusRed))
                        .position(x: bayRect.minX + 20, y: centerY)

                    // Top Clearance Callout
                    Text("\(String(format: "%.1f", isSI ? UnitConverter.inToMm(topGap) : topGap))\(isSI ? "mm" : "\"")")
                        .font(.system(size: 9.5, weight: .bold))
                        .foregroundColor(topGap >= 1.0 ? AppTheme.statusGreen : (topGap >= 0 ? AppTheme.statusAmber : AppTheme.statusRed))
                        .position(x: centerX, y: bayRect.minY + 14)
                }
            }
            .frame(height: 230)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )

            // Status Badge
            HStack(spacing: 8) {
                Circle()
                    .fill(statusColor)
                    .frame(width: 10, height: 10)

                Text(statusText)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(AppTheme.textPrimary)

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(statusColor.opacity(0.12))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}


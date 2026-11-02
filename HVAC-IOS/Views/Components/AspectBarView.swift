import SwiftUI

// MARK: - Aspect Ratio Gauge & ASHRAE Warning Component
struct AspectBarView: View {
    let aspectRatio: Double
    let lang: String

    var body: some View {
        let status = HvacFormulas.getAspectRatioStatus(aspectRatio: aspectRatio)
        let statusColor = Color(hex: status.colorHex)

        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(I18n.t("aspectRatio", lang))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(AppTheme.textSecondary)

                Spacer()

                Text(String(format: "%.2f : 1", aspectRatio))
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(statusColor)

                Text(statusBadgeText(for: status.level))
                    .font(.system(size: 10, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(statusColor.opacity(0.18))
                    .foregroundColor(statusColor)
                    .clipShape(Capsule())
            }

            // Multi-segment Bar
            GeometryReader { geo in
                let w = geo.size.width
                let maxRatio = 5.0
                let clampedRatio = min(max(aspectRatio, 1.0), maxRatio)
                let pointerX = ((clampedRatio - 1.0) / (maxRatio - 1.0)) * w

                ZStack(alignment: .leading) {
                    // Segments
                    HStack(spacing: 2) {
                        // Optimal: 1:1 -> 2:1 (25%)
                        Rectangle()
                            .fill(AppTheme.statusGreen)
                            .frame(width: w * 0.25)
                        // Good: 2:1 -> 3:1 (25%)
                        Rectangle()
                            .fill(Color(hex: "06B6D4"))
                            .frame(width: w * 0.25)
                        // Acceptable: 3:1 -> 4:1 (25%)
                        Rectangle()
                            .fill(AppTheme.statusAmber)
                            .frame(width: w * 0.25)
                        // Warning: > 4:1 (25%)
                        Rectangle()
                            .fill(AppTheme.statusRed)
                            .frame(width: w * 0.25 - 6)
                    }
                    .frame(height: 8)
                    .clipShape(Capsule())

                    // Pointer / Cursor
                    Circle()
                        .fill(AppTheme.textPrimary)
                        .frame(width: 14, height: 14)
                        .overlay(Circle().stroke(AppTheme.bgDark, lineWidth: 2))
                        .offset(x: pointerX - 7)
                        .shadow(radius: 2)
                }
            }
            .frame(height: 16)

            // Segment labels
            HStack {
                Text("1:1")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textMuted)
                Spacer()
                Text("2:1")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textMuted)
                Spacer()
                Text("3:1")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.textMuted)
                Spacer()
                Text("4:1 (ASHRAE Max)")
                    .font(.system(size: 9))
                    .foregroundColor(AppTheme.statusAmber)
            }

            // ASHRAE Warning Banner if Aspect Ratio > 4:1
            if aspectRatio > 4.0 {
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(AppTheme.statusRed)

                    Text(I18n.t("arWarning", lang))
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "FCA5A5"))
                        .lineSpacing(2)
                }
                .padding(10)
                .background(AppTheme.statusRed.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(AppTheme.statusRed.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding(12)
        .background(AppTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private func statusBadgeText(for level: HvacFormulas.AspectLevel) -> String {
        switch level {
        case .optimal: return "OPTIMAL"
        case .good: return "GOOD"
        case .acceptable: return "ACCEPTABLE"
        case .warning: return "WARNING (>4:1)"
        }
    }
}

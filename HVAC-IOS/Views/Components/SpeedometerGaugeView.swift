import SwiftUI

// MARK: - Velocity Speedometer / Circular Gauge Component
struct SpeedometerGaugeView: View {
    let velocityFpm: Double
    let maxGaugeFpm: Double = 2500.0
    let isSI: Bool

    var body: some View {
        let normalized = min(max(velocityFpm / maxGaugeFpm, 0.0), 1.0)
        let angle = -180.0 + (normalized * 180.0) // from -180° to 0° (semi-circle)

        VStack(spacing: 6) {
            ZStack {
                // Background Track
                Circle()
                    .trim(from: 0.0, to: 0.5)
                    .stroke(
                        AppTheme.borderMedium,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(180))
                    .frame(width: 220, height: 220)

                // Colored Velocity Band Arcs
                // Zone 1: Sound sensitive / Residential (0 - 900 FPM) -> Green
                Circle()
                    .trim(from: 0.0, to: 0.5 * (900.0 / 2500.0))
                    .stroke(
                        AppTheme.statusGreen,
                        style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(180))
                    .frame(width: 220, height: 220)

                // Zone 2: Commercial branch / standard (900 - 1300 FPM) -> Cyan
                Circle()
                    .trim(from: 0.5 * (900.0 / 2500.0), to: 0.5 * (1300.0 / 2500.0))
                    .stroke(
                        AppTheme.accentSky,
                        style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(180))
                    .frame(width: 220, height: 220)

                // Zone 3: Commercial main / high (1300 - 1800 FPM) -> Amber
                Circle()
                    .trim(from: 0.5 * (1300.0 / 2500.0), to: 0.5 * (1800.0 / 2500.0))
                    .stroke(
                        AppTheme.statusAmber,
                        style: StrokeStyle(lineWidth: 16, lineCap: .butt)
                    )
                    .rotationEffect(.degrees(180))
                    .frame(width: 220, height: 220)

                // Zone 4: Industrial / High Noise (> 1800 FPM) -> Red
                Circle()
                    .trim(from: 0.5 * (1800.0 / 2500.0), to: 0.5)
                    .stroke(
                        AppTheme.statusRed,
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .rotationEffect(.degrees(180))
                    .frame(width: 220, height: 220)

                // Needle
                GeometryReader { geo in
                    let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
                    Path { path in
                        path.move(to: center)
                        let needleLength = geo.size.width * 0.36
                        let rad = angle * Double.pi / 180.0
                        let endPoint = CGPoint(
                            x: center.x + CGFloat(cos(rad) * needleLength),
                            y: center.y + CGFloat(sin(rad) * needleLength)
                        )
                        path.addLine(to: endPoint)
                    }
                    .stroke(AppTheme.textPrimary, style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: angle)
                }
                .frame(width: 220, height: 220)

                // Center Hub
                Circle()
                    .fill(AppTheme.accentSky)
                    .frame(width: 14, height: 14)
                    .shadow(color: AppTheme.accentSky.opacity(0.6), radius: 6)

                // Readout inside gauge bottom
                VStack(spacing: 2) {
                    Text(isSI ? String(format: "%.1f", UnitConverter.fpmToMs(velocityFpm)) : "\(Int(velocityFpm.rounded()))")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundColor(AppTheme.textPrimary)

                    Text(isSI ? "m/s" : "FPM")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)
                }
                .offset(y: 20)
            }
            .frame(height: 140)

            // Scale Markings
            HStack {
                Text(isSI ? "0 m/s" : "0 FPM")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.textMuted)
                Spacer()
                Text(isSI ? "4.5 m/s" : "900")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.statusGreen)
                Spacer()
                Text(isSI ? "6.5 m/s" : "1300")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.accentSky)
                Spacer()
                Text(isSI ? "12.7 m/s" : "2500 FPM")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppTheme.statusRed)
            }
            .padding(.horizontal, 24)
        }
    }
}


import SwiftUI

// MARK: - Tab 6: Altitude, Air Density & Units View
struct AltitudeView: View {
    @ObservedObject var viewModel: DuctWiseViewModel

    var body: some View {
        let state = viewModel.state
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        let corr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        ScrollView {
            VStack(spacing: 16) {

                // 1. Title Banner
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "mountain.2.fill")
                            .foregroundColor(AppTheme.accentSky)
                        Text(I18n.t("altitudeTitle", lang))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    Text(I18n.t("altitudeSubtitle", lang))
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. Air Density Results Dashboard
                VStack(alignment: .leading, spacing: 12) {
                    Text(I18n.t("airDensityResults", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    HStack(spacing: 10) {
                        metricTile(
                            title: I18n.t("densityRatio", lang),
                            value: String(format: "%.3f", corr.densityRatio),
                            unit: "ρ / ρ₀",
                            color: AppTheme.accentSky
                        )

                        metricTile(
                            title: I18n.t("actualDensity", lang),
                            value: isSI ? String(format: "%.3f", corr.actualDensitySI) : String(format: "%.4f", corr.actualDensityIP),
                            unit: isSI ? "kg/m³" : "lb/ft³",
                            color: AppTheme.accentTeal
                        )

                        metricTile(
                            title: I18n.t("lossMultiplier", lang),
                            value: String(format: "%.3f", corr.lossMultiplier),
                            unit: "× ΔP",
                            color: AppTheme.statusGreen
                        )
                    }

                    // Pressure & Temp Ratio Row
                    HStack(spacing: 10) {
                        metricTile(
                            title: I18n.t("pressureRatio", lang),
                            value: String(format: "%.3f", corr.pressureRatio),
                            unit: "P / P₀",
                            color: AppTheme.textPrimary
                        )

                        metricTile(
                            title: I18n.t("tempRatio", lang),
                            value: String(format: "%.3f", (460.0 + 70.0) / (460.0 + state.tempF)),
                            unit: "T₀ / T",
                            color: AppTheme.textPrimary
                        )
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 3. Elevation / Altitude Input & Quick Presets
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(I18n.t("elevation", lang))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text(isSI ? "\(Int(UnitConverter.ftToM(state.altitudeFt))) m above sea level" : "\(Int(state.altitudeFt)) ft")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.accentSky)
                        }

                        Spacer()

                        TextField("Altitude", value: Binding(
                            get: { state.altitudeFt },
                            set: { viewModel.setAltitude($0) }
                        ), formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(6)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))

                        Text(isSI ? "m" : "ft")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }

                    // Altitude Presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            presetPill(label: I18n.t("seaLevel", lang), ft: 0.0, currentFt: state.altitudeFt)
                            presetPill(label: "Denver (5,280 ft)", ft: 5280.0, currentFt: state.altitudeFt)
                            presetPill(label: "Mexico City (7,350 ft)", ft: 7350.0, currentFt: state.altitudeFt)
                            presetPill(label: "Bogota (8,660 ft)", ft: 8660.0, currentFt: state.altitudeFt)
                            presetPill(label: "10,000 ft", ft: 10000.0, currentFt: state.altitudeFt)
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 4. Air Temperature Input & Presets
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(I18n.t("temperature", lang))
                                .font(.system(size: 13, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text(isSI ? String(format: "%.1f °C", UnitConverter.fToC(state.tempF)) : "\(Int(state.tempF)) °F")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.accentSky)
                        }

                        Spacer()

                        TextField("Temp", value: Binding(
                            get: { state.tempF },
                            set: { viewModel.setTemperature($0) }
                        ), formatter: NumberFormatter())
                        .keyboardType(.numbersAndPunctuation)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 80)
                        .padding(6)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))

                        Text(isSI ? "°C" : "°F")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }

                    // Temperature Presets
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            tempPill(label: "Cold (55°F / 13°C)", f: 55.0, currentF: state.tempF)
                            tempPill(label: "Standard (70°F / 21°C)", f: 70.0, currentF: state.tempF)
                            tempPill(label: "Summer (95°F / 35°C)", f: 95.0, currentF: state.tempF)
                            tempPill(label: "Attic (130°F / 54°C)", f: 130.0, currentF: state.tempF)
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 5. Engineering Guidance Alert
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "info.circle.fill")
                        .foregroundColor(AppTheme.accentSky)
                        .font(.system(size: 16))

                    Text(I18n.t("altitudeAdvisoryNote", lang))
                        .font(.system(size: 11.5))
                        .foregroundColor(AppTheme.textSecondary)
                        .lineSpacing(2)
                }
                .padding(14)
                .background(AppTheme.bgCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
        }
        .background(AppTheme.bgDark)
    }

    private func metricTile(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(color)

            Text(unit)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppTheme.bgCardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func presetPill(label: String, ft: Double, currentFt: Double) -> some View {
        let isSel = abs(currentFt - ft) < 1.0
        return Button(action: {
            viewModel.setAltitude(ft)
        }) {
            Text(label)
                .font(.system(size: 11, weight: isSel ? .bold : .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSel ? AppTheme.primaryBlue : AppTheme.bgCardElevated)
                .foregroundColor(isSel ? .white : AppTheme.textSecondary)
                .clipShape(Capsule())
        }
    }

    private func tempPill(label: String, f: Double, currentF: Double) -> some View {
        let isSel = abs(currentF - f) < 1.0
        return Button(action: {
            viewModel.setTemperature(f)
        }) {
            Text(label)
                .font(.system(size: 11, weight: isSel ? .bold : .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSel ? AppTheme.primaryBlue : AppTheme.bgCardElevated)
                .foregroundColor(isSel ? .white : AppTheme.textSecondary)
                .clipShape(Capsule())
        }
    }
}

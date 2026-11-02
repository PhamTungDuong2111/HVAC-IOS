import SwiftUI

// MARK: - Tab 3: Design Bands & Velocity Speedometer View
struct VelocityView: View {
    @ObservedObject var viewModel: DuctWiseViewModel
    @State private var selectedCategory: String = "all"
    @State private var showingAppliedAlert = false
    @State private var appliedBandName = ""

    var body: some View {
        let state = viewModel.state
        let s = state.sizer
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        // Current velocity calculation
        let areaSqFt: Double
        switch s.shape {
        case "round":
            areaSqFt = HvacFormulas.roundAreaSqFt(diameterIn: s.roundDiameter)
        case "flatOval":
            areaSqFt = HvacFormulas.flatOvalProperties(major: s.flatOvalMajor, minor: s.flatOvalMinor).areaSqFt
        default:
            areaSqFt = HvacFormulas.rectangularAreaSqFt(widthIn: s.rectWidth, heightIn: s.rectHeight)
        }
        let currentVelFpm = HvacFormulas.velocityFromCfmAndArea(cfm: s.cfm, areaSqFt: areaSqFt)

        let filteredBands = selectedCategory == "all"
            ? Standards.applicationDesignBands
            : Standards.applicationDesignBands.filter { $0.category == selectedCategory }

        ScrollView {
            VStack(spacing: 16) {

                // 1. Current Operating Speedometer Card
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "gauge.with.needle.fill")
                            .foregroundColor(AppTheme.accentSky)
                        Text(I18n.t("tabVelocity", lang))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }

                    SpeedometerGaugeView(
                        velocityFpm: currentVelFpm,
                        isSI: isSI
                    )
                }
                .padding(16)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. Category Filter Tabs
                HStack(spacing: 8) {
                    filterButton(title: I18n.t("catAll", lang), cat: "all")
                    filterButton(title: I18n.t("catResidential", lang), cat: "residential")
                    filterButton(title: I18n.t("catCommercial", lang), cat: "commercial")
                    filterButton(title: I18n.t("catSpecialty", lang), cat: "specialty")
                }

                // 3. Design Bands List
                VStack(spacing: 12) {
                    ForEach(filteredBands) { band in
                        let isOpt = currentVelFpm >= band.optFpmMin && currentVelFpm <= band.optFpmMax
                        let isAcceptable = currentVelFpm >= band.minFpm && currentVelFpm <= band.maxFpm

                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(I18n.t(band.nameKey, lang))
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundColor(AppTheme.textPrimary)

                                    Text(band.ncRating)
                                        .font(.system(size: 10.5, weight: .semibold))
                                        .foregroundColor(AppTheme.accentSky)
                                }

                                Spacer()

                                // Current velocity relative badge
                                if isOpt {
                                    badgeView(text: "OPTIMAL", color: AppTheme.statusGreen)
                                } else if isAcceptable {
                                    badgeView(text: "ACCEPTABLE", color: AppTheme.statusAmber)
                                } else if currentVelFpm > band.maxFpm {
                                    badgeView(text: "HIGH NOISE", color: AppTheme.statusRed)
                                } else {
                                    badgeView(text: "LOW", color: AppTheme.textMuted)
                                }
                            }

                            Text(I18n.t(band.descriptionKey, lang))
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textSecondary)
                                .lineLimit(2)

                            Divider().background(AppTheme.borderSubtle)

                            // Velocity ranges & Friction
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(I18n.t("optRange", lang))
                                        .font(.system(size: 9.5))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text(isSI
                                         ? "\(String(format: "%.1f", UnitConverter.fpmToMs(band.optFpmMin))) - \(String(format: "%.1f", UnitConverter.fpmToMs(band.optFpmMax))) m/s"
                                         : "\(Int(band.optFpmMin)) - \(Int(band.optFpmMax)) FPM")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppTheme.statusGreen)
                                }

                                Spacer()

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(I18n.t("maxAllowed", lang))
                                        .font(.system(size: 9.5))
                                        .foregroundColor(AppTheme.textMuted)
                                    Text(isSI
                                         ? "\(String(format: "%.1f", UnitConverter.fpmToMs(band.maxFpm))) m/s"
                                         : "\(Int(band.maxFpm)) FPM")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(AppTheme.statusAmber)
                                }

                                Spacer()

                                // Apply Button
                                Button(action: {
                                    viewModel.setAppPreset(band.id)
                                    appliedBandName = I18n.t(band.nameKey, lang)
                                    showingAppliedAlert = true
                                }) {
                                    Text(I18n.t("applyBand", lang))
                                        .font(.system(size: 11, weight: .bold))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(AppTheme.primaryBlue)
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                }
                            }
                        }
                        .padding(14)
                        .background(AppTheme.bgCard)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(isOpt ? AppTheme.statusGreen.opacity(0.4) : AppTheme.borderSubtle, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.bgDark)
        .alert(isPresented: $showingAppliedAlert) {
            Alert(
                title: Text(I18n.t("bandAppliedTitle", lang)),
                message: Text("\(appliedBandName) \(I18n.t("bandAppliedMsg", lang))"),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func filterButton(title: String, cat: String) -> some View {
        let isSel = selectedCategory == cat
        return Button(action: {
            selectedCategory = cat
        }) {
            Text(title)
                .font(.system(size: 11, weight: isSel ? .bold : .medium))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSel ? AppTheme.primaryBlue : AppTheme.bgCard)
                .foregroundColor(isSel ? .white : AppTheme.textSecondary)
                .clipShape(Capsule())
        }
    }

    private func badgeView(text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 9.5, weight: .bold))
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(color.opacity(0.18))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}


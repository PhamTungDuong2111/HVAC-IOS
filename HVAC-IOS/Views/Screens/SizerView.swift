import SwiftUI

// MARK: - Tab 1: Duct Sizer & Huebscher Calculator View
struct SizerView: View {
    @ObservedObject var viewModel: DuctWiseViewModel
    @State private var showingAddAlert = false

    var body: some View {
        let state = viewModel.state
        let s = state.sizer
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        // Density Correction
        let densityCorr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        // Geometry & Aerodynamics
        let de: Double
        let areaSqFt: Double
        let aspectRatio: Double

        switch s.shape {
        case "round":
            de = s.roundDiameter
            areaSqFt = HvacFormulas.roundAreaSqFt(diameterIn: de)
            aspectRatio = 1.0
        case "flatOval":
            let oval = HvacFormulas.flatOvalProperties(major: s.flatOvalMajor, minor: s.flatOvalMinor)
            de = oval.equivalentRoundDe
            areaSqFt = oval.areaSqFt
            aspectRatio = oval.aspectRatio
        default:
            de = HvacFormulas.huebscherRectangular(a: s.rectWidth, b: s.rectHeight)
            areaSqFt = HvacFormulas.rectangularAreaSqFt(widthIn: s.rectWidth, heightIn: s.rectHeight)
            aspectRatio = HvacFormulas.getAspectRatio(w: s.rectWidth, h: s.rectHeight)
        }

        let actualVelocity = HvacFormulas.velocityFromCfmAndArea(cfm: s.cfm, areaSqFt: areaSqFt)
        let actualFriction = HvacFormulas.calculateFrictionRate(cfm: s.cfm, diameterIn: de, densityMultiplier: densityCorr.lossMultiplier)
        let staticDrop = HvacFormulas.calculateStaticDrop(frictionRatePer100Ft: actualFriction, totalEquivLengthFt: s.ductLengthFt)

        let maxDim: Double
        let dim1: Double
        let dim2: Double
        switch s.shape {
        case "round":
            maxDim = s.roundDiameter
            dim1 = s.roundDiameter
            dim2 = s.roundDiameter
        case "flatOval":
            maxDim = max(s.flatOvalMajor, s.flatOvalMinor)
            dim1 = s.flatOvalMajor
            dim2 = s.flatOvalMinor
        default:
            maxDim = max(s.rectWidth, s.rectHeight)
            dim1 = s.rectWidth
            dim2 = s.rectHeight
        }
        let gauge = HvacFormulas.getRecommendedGauge(maxDimensionIn: maxDim)
        let metalArea = HvacFormulas.calculateSheetMetalArea(shape: s.shape, dim1In: dim1, dim2In: dim2, lengthFt: s.ductLengthFt)

        ScrollView {
            VStack(spacing: 16) {

                // 1. Sizing Mode Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text(I18n.t("sizingMode", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    Picker("Mode", selection: Binding(
                        get: { s.mode },
                        set: { viewModel.setSizingMode($0) }
                    )) {
                        Text(I18n.t("modeFriction", lang)).tag("friction")
                        Text(I18n.t("modeVelocity", lang)).tag("velocity")
                        Text(I18n.t("modeDimensions", lang)).tag("dimensions")
                    }
                    .pickerStyle(.segmented)
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. Duct Shape Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text(I18n.t("shape", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    HStack(spacing: 8) {
                        shapeButton(title: I18n.t("rectangular", lang), icon: "rectangle", shapeId: "rectangular", currentShape: s.shape)
                        shapeButton(title: I18n.t("round", lang), icon: "circle", shapeId: "round", currentShape: s.shape)
                        shapeButton(title: I18n.t("flatOval", lang), icon: "oval", shapeId: "flatOval", currentShape: s.shape)
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 3. Application Band Preset Selector
                VStack(alignment: .leading, spacing: 6) {
                    Text(I18n.t("appApplication", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Standards.applicationDesignBands) { band in
                                let isSelected = s.appPresetId == band.id
                                Button(action: {
                                    viewModel.setAppPreset(band.id)
                                }) {
                                    Text(I18n.t(band.nameKey, lang))
                                        .font(.system(size: 11.5, weight: isSelected ? .bold : .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isSelected ? AppTheme.primaryBlue : AppTheme.bgCardElevated)
                                        .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 4. Primary Inputs: CFM & Slider
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(I18n.t("airflow", lang))
                                .font(.system(size: 14, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text(isSI ? "\(Int(UnitConverter.cfmToLps(s.cfm))) L/s (\(Int(UnitConverter.cfmToM3h(s.cfm))) m³/h)" : "\(Int(s.cfm)) CFM")
                                .font(.system(size: 12))
                                .foregroundColor(AppTheme.accentSky)
                        }

                        Spacer()

                        HStack {
                            TextField("CFM", value: Binding(
                                get: { s.cfm },
                                set: { viewModel.setAirflow($0) }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accentSky)
                            .frame(width: 90)
                            .padding(6)
                            .background(AppTheme.bgCardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 6))

                            Text(isSI ? "L/s" : "CFM")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(AppTheme.textMuted)
                        }
                    }

                    // CFM Slider
                    Slider(
                        value: Binding(
                            get: { s.cfm },
                            set: { viewModel.setAirflow($0) }
                        ),
                        in: 50...5000,
                        step: 25
                    )
                    .tint(AppTheme.accentSky)

                    Divider().background(AppTheme.borderSubtle)

                    // Target Friction or Target Velocity depending on mode
                    if s.mode == "friction" {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(I18n.t("targetFriction", lang))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text(isSI ? String(format: "%.2f Pa/m", UnitConverter.inwg100ftToPaM(s.targetFriction)) : "\(s.targetFriction) in.wg/100ft")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            Spacer()
                            TextField("Friction", value: Binding(
                                get: { s.targetFriction },
                                set: { viewModel.setTargetFriction($0) }
                            ), formatter: decimalFormatter)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accentSky)
                            .frame(width: 80)
                            .padding(6)
                            .background(AppTheme.bgCardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    } else if s.mode == "velocity" {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(I18n.t("targetVelocity", lang))
                                    .font(.system(size: 13, weight: .semibold))
                                    .foregroundColor(AppTheme.textPrimary)
                                Text(isSI ? String(format: "%.1f m/s", UnitConverter.fpmToMs(s.targetVelocity)) : "\(Int(s.targetVelocity)) FPM")
                                    .font(.system(size: 11))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            Spacer()
                            TextField("FPM", value: Binding(
                                get: { s.targetVelocity },
                                set: { viewModel.setTargetVelocity($0) }
                            ), formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .font(.system(size: 16, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accentSky)
                            .frame(width: 80)
                            .padding(6)
                            .background(AppTheme.bgCardElevated)
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }

                    // Dimension Locking for Rectangular
                    if s.shape == "rectangular" {
                        HStack {
                            Text(I18n.t("lockDimension", lang))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textSecondary)
                            Spacer()
                            Picker("Lock", selection: Binding(
                                get: { s.lockDimension },
                                set: { viewModel.setLockDimension($0) }
                            )) {
                                Text(I18n.t("unlocked", lang)).tag("none")
                                Text(I18n.t("lockWidth", lang)).tag("width")
                                Text(I18n.t("lockHeight", lang)).tag("height")
                            }
                            .pickerStyle(.menu)
                            .tint(AppTheme.accentSky)
                        }
                    }

                    // Dimension Inputs
                    if s.shape == "rectangular" {
                        HStack(spacing: 12) {
                            dimensionInput(label: I18n.t("width", lang), value: Binding(
                                get: { s.rectWidth },
                                set: { viewModel.setRectWidth($0) }
                            ), unit: isSI ? "mm" : "in", isSI: isSI)

                            dimensionInput(label: I18n.t("height", lang), value: Binding(
                                get: { s.rectHeight },
                                set: { viewModel.setRectHeight($0) }
                            ), unit: isSI ? "mm" : "in", isSI: isSI)
                        }
                    } else if s.shape == "round" {
                        dimensionInput(label: I18n.t("diameter", lang), value: Binding(
                            get: { s.roundDiameter },
                            set: { viewModel.setRoundDiameter($0) }
                        ), unit: isSI ? "mm" : "in", isSI: isSI)
                    } else {
                        HStack(spacing: 12) {
                            dimensionInput(label: "Major Axis (a)", value: Binding(
                                get: { s.flatOvalMajor },
                                set: { viewModel.setFlatOvalMajor($0) }
                            ), unit: isSI ? "mm" : "in", isSI: isSI)

                            dimensionInput(label: "Minor Axis (b)", value: Binding(
                                get: { s.flatOvalMinor },
                                set: { viewModel.setFlatOvalMinor($0) }
                            ), unit: isSI ? "mm" : "in", isSI: isSI)
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 5. Results & Huebscher Equivalent Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "function")
                            .foregroundColor(AppTheme.accentTeal)
                        Text(I18n.t("huebscherHeader", lang))
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }

                    HStack(spacing: 12) {
                        resultTile(
                            title: I18n.t("huebscherDe", lang),
                            value: String(format: "%.1f", isSI ? UnitConverter.inToMm(de) : de),
                            unit: isSI ? "mm" : "in",
                            highlight: true
                        )

                        resultTile(
                            title: I18n.t("velocity", lang),
                            value: isSI ? String(format: "%.1f", UnitConverter.fpmToMs(actualVelocity)) : "\(Int(actualVelocity.rounded()))",
                            unit: isSI ? "m/s" : "FPM",
                            highlight: actualVelocity > 1500
                        )

                        resultTile(
                            title: I18n.t("frictionRate", lang),
                            value: isSI ? String(format: "%.2f", UnitConverter.inwg100ftToPaM(actualFriction)) : String(format: "%.3f", actualFriction),
                            unit: isSI ? "Pa/m" : "in.wg",
                            highlight: false
                        )
                    }

                    HStack(spacing: 12) {
                        resultTile(
                            title: I18n.t("gauge", lang),
                            value: gauge,
                            unit: "SMACNA",
                            highlight: false
                        )

                        resultTile(
                            title: I18n.t("metalArea", lang),
                            value: String(format: "%.1f", isSI ? metalArea.areaSqM : metalArea.areaSqFt),
                            unit: isSI ? "m²" : "sq ft",
                            highlight: false
                        )
                    }
                }
                .padding(14)
                .background(AppTheme.bgCardElevated)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppTheme.borderMedium, lineWidth: 1)
                )

                // 6. Aspect Ratio Card (For Rectangular & Flat Oval)
                if s.shape != "round" {
                    AspectBarView(aspectRatio: aspectRatio, lang: lang)
                }

                // 7. Commercial Stock Size Suggestions
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Image(systemName: "sparkles")
                            .foregroundColor(AppTheme.accentSky)
                        Text(I18n.t("stockSuggestions", lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }

                    let suggestions = viewModel.getStockSuggestions()
                    if suggestions.isEmpty {
                        Text(I18n.t("noStockFound", lang))
                            .font(.system(size: 11))
                            .foregroundColor(AppTheme.textMuted)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(suggestions) { item in
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(item.label)
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                            .foregroundColor(AppTheme.textPrimary)
                                        Text("De: \(String(format: "%.1f\"", item.de)) • \(Int(item.velocity)) FPM • \(item.friction) in.wg")
                                            .font(.system(size: 10.5))
                                            .foregroundColor(AppTheme.textSecondary)
                                    }

                                    Spacer()

                                    Text("\(item.deviationPercent > 0 ? "+" : "")\(String(format: "%.1f%%", item.deviationPercent))")
                                        .font(.system(size: 11, weight: .bold))
                                        .foregroundColor(abs(item.deviationPercent) < 5 ? AppTheme.statusGreen : AppTheme.statusAmber)

                                    Button(action: {
                                        viewModel.applyStockSize(w: item.width, h: item.height)
                                    }) {
                                        Text(I18n.t("selectSize", lang))
                                            .font(.system(size: 11, weight: .bold))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 5)
                                            .background(AppTheme.primaryBlue)
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 6))
                                    }
                                }
                                .padding(10)
                                .background(AppTheme.bgCardElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 8. Add to Duct Schedule / Job List Section
                VStack(alignment: .leading, spacing: 10) {
                    Text(I18n.t("addToJob", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    HStack(spacing: 8) {
                        TextField(I18n.t("tagPlaceholder", lang), text: Binding(
                            get: { s.runTag },
                            set: { viewModel.setRunTag($0) }
                        ))
                        .font(.system(size: 13, design: .monospaced))
                        .padding(8)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        TextField(I18n.t("descPlaceholder", lang), text: Binding(
                            get: { s.runDesc },
                            set: { viewModel.setRunDesc($0) }
                        ))
                        .font(.system(size: 13))
                        .padding(8)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }

                    HStack {
                        Text(I18n.t("length", lang))
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)

                        Spacer()

                        TextField("Length", value: Binding(
                            get: { s.ductLengthFt },
                            set: { viewModel.setDuctLength($0) }
                        ), formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 70)
                        .padding(6)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))

                        Text(isSI ? "m" : "ft")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }

                    Button(action: {
                        viewModel.addCurrentSizerToJobList()
                        showingAddAlert = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text(I18n.t("addToJob", lang))
                                .font(.system(size: 14, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(AppTheme.statusGreen)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .alert(isPresented: $showingAddAlert) {
                        Alert(
                            title: Text(I18n.t("runAddedTitle", lang)),
                            message: Text(I18n.t("runAddedMessage", lang)),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
        }
        .background(AppTheme.bgDark)
    }

    // Helper views
    private func shapeButton(title: String, icon: String, shapeId: String, currentShape: String) -> some View {
        let isSelected = currentShape == shapeId
        return Button(action: {
            viewModel.setDuctShape(shapeId)
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                Text(title)
                    .font(.system(size: 11, weight: .bold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(isSelected ? AppTheme.primaryBlue : AppTheme.bgCardElevated)
            .foregroundColor(isSelected ? .white : AppTheme.textSecondary)
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private func dimensionInput(label: String, value: Binding<Double>, unit: String, isSI: Bool) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            HStack {
                TextField(label, value: value, formatter: decimalFormatter)
                    .keyboardType(.decimalPad)
                    .font(.system(size: 15, weight: .bold, design: .monospaced))
                    .foregroundColor(AppTheme.textPrimary)

                Text(unit)
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(AppTheme.textMuted)
            }
            .padding(8)
            .background(AppTheme.bgCardElevated)
            .clipShape(RoundedRectangle(cornerRadius: 6))
        }
        .frame(maxWidth: .infinity)
    }

    private func resultTile(title: String, value: String, unit: String, highlight: Bool) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(highlight ? AppTheme.accentSky : AppTheme.textPrimary)
                .lineLimit(1)

            Text(unit)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppTheme.bgCard)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var decimalFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f
    }
}


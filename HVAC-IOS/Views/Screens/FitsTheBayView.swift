import SwiftUI

// MARK: - Tab 2: Fits the Bay (Joist Clearance Simulator) View
struct FitsTheBayView: View {
    @ObservedObject var viewModel: DuctWiseViewModel

    var body: some View {
        let state = viewModel.state
        let bay = state.fitsBay
        let sizer = state.sizer
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        // Active insulation
        let insul = Standards.insulationTypes.first(where: { $0.id == bay.insulationId }) ?? Standards.insulationTypes[0]
        let wrapThick = insul.external ? insul.thicknessIn : 0.0
        let linerThick = !insul.external ? insul.thicknessIn : 0.0

        // Duct dimensions
        var ductW = (sizer.shape == "round") ? sizer.roundDiameter : sizer.rectWidth
        var ductH = (sizer.shape == "round") ? sizer.roundDiameter : sizer.rectHeight

        // Rotate 90° if toggled
        if bay.rotated && sizer.shape != "round" {
            let temp = ductW
            ductW = ductH
            ductH = temp
        }

        let envelopeW = ductW + 2 * wrapThick
        let envelopeH = ductH + 2 * wrapThick

        let cavityW = bay.customWidthIn
        let cavityH = bay.customHeightIn

        let clearHoriz = cavityW - envelopeW
        let clearVert = cavityH - envelopeH

        let leftClear = clearHoriz / 2.0
        let topClear = clearVert / 2.0

        let doesFit = (clearHoriz >= 0) && (clearVert >= 0)
        let minClearance = min(leftClear, topClear)

        let statusText: String
        let statusColor: Color
        if !doesFit {
            statusText = I18n.t("statusConflict", lang)
            statusColor = AppTheme.statusRed
        } else if minClearance < 1.0 {
            statusText = I18n.t("statusTight", lang)
            statusColor = AppTheme.statusAmber
        } else {
            statusText = I18n.t("statusComfortable", lang)
            statusColor = AppTheme.statusGreen
        }

        ScrollView {
            VStack(spacing: 16) {

                // 1. Title Banner
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "viewfinder")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(AppTheme.accentSky)
                        Text(I18n.t("fitsBayTitle", lang))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                    }
                    Text(I18n.t("fitsBaySubtitle", lang))
                        .font(.system(size: 11))
                        .foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. 2D Simulator Canvas
                JoistBayCanvasView(
                    cavityWidthIn: cavityW,
                    cavityHeightIn: cavityH,
                    ductShape: sizer.shape,
                    ductWidthIn: ductW,
                    ductHeightIn: ductH,
                    wrapThicknessIn: wrapThick,
                    linerThicknessIn: linerThick,
                    isSI: isSI,
                    statusText: statusText,
                    statusColor: statusColor
                )

                // 3. Framing / Joist Preset Selector
                VStack(alignment: .leading, spacing: 10) {
                    Text(I18n.t("joistPreset", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Standards.joistBayPresets) { p in
                                let isSel = bay.presetId == p.id
                                Button(action: {
                                    viewModel.setBayPreset(p.id)
                                }) {
                                    Text(p.label)
                                        .font(.system(size: 11.5, weight: isSel ? .bold : .medium))
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 6)
                                        .background(isSel ? AppTheme.primaryBlue : AppTheme.bgCardElevated)
                                        .foregroundColor(isSel ? .white : AppTheme.textSecondary)
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    // Cavity Dimensions (Custom or Preset)
                    HStack(spacing: 12) {
                        dimensionField(
                            label: I18n.t("customCavityWidth", lang),
                            value: Binding(
                                get: { bay.customWidthIn },
                                set: { viewModel.setCustomBayCavity(widthIn: $0, heightIn: bay.customHeightIn) }
                            ),
                            unit: isSI ? "mm" : "in"
                        )

                        dimensionField(
                            label: I18n.t("customCavityHeight", lang),
                            value: Binding(
                                get: { bay.customHeightIn },
                                set: { viewModel.setCustomBayCavity(widthIn: bay.customWidthIn, heightIn: $0) }
                            ),
                            unit: isSI ? "mm" : "in"
                        )
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 4. Insulation / Liner Options & 90° Rotate
                VStack(alignment: .leading, spacing: 10) {
                    Text(I18n.t("insulationType", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    Picker("Insulation", selection: Binding(
                        get: { bay.insulationId },
                        set: { viewModel.setInsulation($0) }
                    )) {
                        ForEach(Standards.insulationTypes) { item in
                            Text(I18n.t(item.nameKey, lang)).tag(item.id)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(AppTheme.accentSky)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(8)
                    .background(AppTheme.bgCardElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 6))

                    // Rotate 90° Toggle
                    if sizer.shape != "round" {
                        Button(action: {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                viewModel.toggleBayRotated()
                            }
                        }) {
                            HStack {
                                Image(systemName: "arrow.triangle.2.circlepath")
                                Text(bay.rotated ? I18n.t("rotateRestore", lang) : I18n.t("rotate90", lang))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(bay.rotated ? AppTheme.accentTeal : AppTheme.bgCardElevated)
                            .foregroundColor(bay.rotated ? .white : AppTheme.accentSky)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 5. Clearance Metrics Breakdown Card
                VStack(alignment: .leading, spacing: 10) {
                    Text(I18n.t("clearanceStatus", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    HStack(spacing: 12) {
                        metricBox(
                            title: I18n.t("leftRightClearance", lang),
                            value: String(format: "%.1f", isSI ? UnitConverter.inToMm(leftClear) : leftClear),
                            unit: isSI ? "mm" : "in",
                            pass: leftClear >= 1.0
                        )

                        metricBox(
                            title: I18n.t("topClearance", lang),
                            value: String(format: "%.1f", isSI ? UnitConverter.inToMm(topClear) : topClear),
                            unit: isSI ? "mm" : "in",
                            pass: topClear >= 1.0
                        )
                    }

                    HStack(spacing: 12) {
                        metricBox(
                            title: I18n.t("envelopeW", lang),
                            value: String(format: "%.1f", isSI ? UnitConverter.inToMm(envelopeW) : envelopeW),
                            unit: isSI ? "mm" : "in",
                            pass: true
                        )

                        metricBox(
                            title: I18n.t("envelopeH", lang),
                            value: String(format: "%.1f", isSI ? UnitConverter.inToMm(envelopeH) : envelopeH),
                            unit: isSI ? "mm" : "in",
                            pass: true
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

    private func dimensionField(label: String, value: Binding<Double>, unit: String) -> some View {
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

    private func metricBox(title: String, value: String, unit: String, pass: Bool) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(pass ? AppTheme.textPrimary : AppTheme.statusRed)

            Text(unit)
                .font(.system(size: 9.5, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(AppTheme.bgCardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var decimalFormatter: NumberFormatter {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.maximumFractionDigits = 2
        return f
    }
}

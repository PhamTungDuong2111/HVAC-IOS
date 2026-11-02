import SwiftUI

// MARK: - Tab 4: Static Budget & ACCA Manual D Friction Rate View
struct StaticBudgetView: View {
    @ObservedObject var viewModel: DuctWiseViewModel
    @State private var showingFrictionAppliedAlert = false

    var body: some View {
        let state = viewModel.state
        let sb = state.staticBudget
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        // TEL Calculations
        var fittingEquivFt = 0.0
        for item in sb.fittings {
            if let def = Standards.fittingCatalog.first(where: { $0.id == item.id }) {
                fittingEquivFt += def.equivFt * Double(item.qty)
            }
        }
        let totalTEL = sb.straightLengthFt + fittingEquivFt

        // Component Drops Calculations
        let totalCompDrop = sb.components.filter { $0.enabled }.reduce(0.0) { $0 + $1.drop }
        let budgetResult = HvacFormulas.calculateStaticBudget(
            equipmentESP: sb.equipmentESP,
            componentDrops: totalCompDrop,
            totalEquivLengthFt: totalTEL
        )

        ScrollView {
            VStack(spacing: 16) {

                // 1. Result Dashboard: ASP & Manual D Friction Rate
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "fanblades.fill")
                            .foregroundColor(AppTheme.accentSky)
                        Text(I18n.t("tabStaticBudget", lang))
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(AppTheme.textPrimary)
                        Spacer()
                    }

                    HStack(spacing: 10) {
                        resultCard(
                            title: I18n.t("availableStatic", lang),
                            value: String(format: "%.2f", isSI ? UnitConverter.inwgToPa(budgetResult.availableStaticPressure) : budgetResult.availableStaticPressure),
                            unit: isSI ? "Pa" : "in.wg",
                            color: AppTheme.accentSky
                        )

                        resultCard(
                            title: I18n.t("totalTEL", lang),
                            value: "\(Int(isSI ? UnitConverter.ftToM(budgetResult.totalEquivLengthFt) : budgetResult.totalEquivLengthFt))",
                            unit: isSI ? "m" : "ft",
                            color: AppTheme.accentTeal
                        )

                        resultCard(
                            title: I18n.t("designFrictionRate", lang),
                            value: String(format: "%.3f", isSI ? UnitConverter.inwg100ftToPaM(budgetResult.designFrictionRate) : budgetResult.designFrictionRate),
                            unit: isSI ? "Pa/m" : "in.wg",
                            color: budgetResult.designFrictionRate < 0.05 ? AppTheme.statusAmber : AppTheme.statusGreen
                        )
                    }

                    // Quick apply button to transfer friction rate to Sizer Tab
                    Button(action: {
                        if budgetResult.designFrictionRate > 0.01 {
                            viewModel.setTargetFriction(budgetResult.designFrictionRate)
                            showingFrictionAppliedAlert = true
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text(I18n.t("applyFrictionToSizer", lang))
                                .font(.system(size: 12.5, weight: .bold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(AppTheme.primaryBlue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. Blower ESP & Straight Duct Length Inputs
                VStack(alignment: .leading, spacing: 12) {
                    Text(I18n.t("blowerRatedESP", lang))
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(I18n.t("equipmentESP", lang))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("e.g. 0.50 in.wg (Standard Heat Pump / AHU)")
                                .font(.system(size: 10.5))
                                .foregroundColor(AppTheme.textMuted)
                        }

                        Spacer()

                        TextField("ESP", value: Binding(
                            get: { sb.equipmentESP },
                            set: { viewModel.setEquipmentESP($0) }
                        ), formatter: decimalFormatter)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 75)
                        .padding(6)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))

                        Text(isSI ? "Pa" : "in.wg")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(I18n.t("straightDuctLength", lang))
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundColor(AppTheme.textPrimary)
                            Text("Longest supply + return duct path")
                                .font(.system(size: 10.5))
                                .foregroundColor(AppTheme.textMuted)
                        }

                        Spacer()

                        TextField("Length", value: Binding(
                            get: { sb.straightLengthFt },
                            set: { viewModel.setStraightLength($0) }
                        ), formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 75)
                        .padding(6)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .font(.system(size: 15, weight: .bold, design: .monospaced))

                        Text(isSI ? "m" : "ft")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(AppTheme.textMuted)
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 3. Deductible Component Drops (Evaporator coil, Filters, Grilles)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(I18n.t("componentDropsTitle", lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.accentSky)
                        Spacer()
                        Text("-\(String(format: "%.2f", totalCompDrop)) in.wg")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.statusAmber)
                    }

                    VStack(spacing: 8) {
                        ForEach(sb.components) { comp in
                            let def = Standards.componentPressureDrops.first(where: { $0.id == comp.id })
                            let name = def != nil ? I18n.t(def!.nameKey, lang) : comp.id

                            HStack {
                                Toggle(isOn: Binding(
                                    get: { comp.enabled },
                                    set: { _ in viewModel.toggleComponent(comp.id) }
                                )) {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text(name)
                                            .font(.system(size: 12.5, weight: .medium))
                                            .foregroundColor(comp.enabled ? AppTheme.textPrimary : AppTheme.textMuted)
                                        if let range = def?.range {
                                            Text("Range: \(range) in.wg")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppTheme.textMuted)
                                        }
                                    }
                                }
                                .tint(AppTheme.accentSky)

                                Spacer()

                                TextField("Drop", value: Binding(
                                    get: { comp.drop },
                                    set: { viewModel.updateComponentDrop(comp.id, drop: $0) }
                                ), formatter: decimalFormatter)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 55)
                                .padding(4)
                                .background(AppTheme.bgCardElevated)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                                .font(.system(size: 13, weight: .bold, design: .monospaced))
                                .disabled(!comp.enabled)

                                Text(isSI ? "Pa" : "in.wg")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(AppTheme.textMuted)
                            }
                            .padding(8)
                            .background(AppTheme.bgCardElevated.opacity(comp.enabled ? 1.0 : 0.4))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 4. Fitting Equivalent Length (TEL Catalog)
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(I18n.t("fittingsCatalogTitle", lang))
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(AppTheme.accentSky)
                        Spacer()
                        Text("+\(Int(fittingEquivFt)) ft TEL")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundColor(AppTheme.accentTeal)
                    }

                    VStack(spacing: 8) {
                        ForEach(Standards.fittingCatalog) { fitting in
                            let activeItem = sb.fittings.first(where: { $0.id == fitting.id })
                            let qty = activeItem?.qty ?? 0

                            HStack {
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(I18n.t(fitting.nameKey, lang))
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(qty > 0 ? AppTheme.textPrimary : AppTheme.textSecondary)

                                    Text("\(Int(fitting.equivFt)) ft equiv / ea")
                                        .font(.system(size: 10))
                                        .foregroundColor(AppTheme.accentTeal)
                                }

                                Spacer()

                                HStack(spacing: 8) {
                                    Button(action: {
                                        viewModel.removeFitting(fitting.id)
                                    }) {
                                        Image(systemName: "minus")
                                            .font(.system(size: 10, weight: .bold))
                                            .frame(width: 26, height: 26)
                                            .background(AppTheme.bgCardElevated)
                                            .foregroundColor(qty > 0 ? AppTheme.accentSky : AppTheme.textMuted)
                                            .clipShape(Circle())
                                    }
                                    .disabled(qty == 0)

                                    Text("\(qty)")
                                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                                        .foregroundColor(qty > 0 ? AppTheme.textPrimary : AppTheme.textMuted)
                                        .frame(minWidth: 20)

                                    Button(action: {
                                        viewModel.addFitting(fitting.id)
                                    }) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 10, weight: .bold))
                                            .frame(width: 26, height: 26)
                                            .background(AppTheme.bgCardElevated)
                                            .foregroundColor(AppTheme.accentSky)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                            .padding(8)
                            .background(AppTheme.bgCardElevated.opacity(qty > 0 ? 1.0 : 0.5))
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(16)
        }
        .background(AppTheme.bgDark)
        .alert(isPresented: $showingFrictionAppliedAlert) {
            Alert(
                title: Text(I18n.t("frictionAppliedTitle", lang)),
                message: Text(I18n.t("frictionAppliedMsg", lang)),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func resultCard(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9.5, weight: .medium))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(color)

            Text(unit)
                .font(.system(size: 9, weight: .bold))
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
        f.maximumFractionDigits = 3
        return f
    }
}


import SwiftUI

// MARK: - Tab 5: Duct Schedule / Job List View
struct JobListView: View {
    @ObservedObject var viewModel: DuctWiseViewModel
    @State private var pdfURL: URL?
    @State private var showingShareSheet = false
    @State private var showingClearAlert = false
    @State private var showingEditProjectSheet = false

    var body: some View {
        let state = viewModel.state
        let project = state.project
        let lang = state.lang
        let isSI = state.unitSystem == "SI"

        let totalRuns = project.runs.count
        let totalCfm = project.runs.reduce(0.0) { $0 + $1.cfm }
        let totalLen = project.runs.reduce(0.0) { $0 + $1.lengthFt }
        let totalArea = project.runs.reduce(0.0) { $0 + $1.metalAreaSqFt }

        ScrollView {
            VStack(spacing: 16) {

                // 1. Project Specifications Header Card
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(project.name)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("\(project.engineer) • \(project.date)")
                                .font(.system(size: 11))
                                .foregroundColor(AppTheme.textSecondary)

                            Text("System: \(project.systemTag)")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(AppTheme.accentSky)
                        }

                        Spacer()

                        Button(action: {
                            showingEditProjectSheet = true
                        }) {
                            Image(systemName: "pencil.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(AppTheme.accentSky)
                        }
                    }

                    Divider().background(AppTheme.borderSubtle)

                    // Aggregate KPIs Row
                    HStack(spacing: 8) {
                        kpiTile(title: I18n.t("totalRuns", lang), value: "\(totalRuns)", unit: "Runs")
                        kpiTile(title: I18n.t("totalFlow", lang), value: "\(Int(totalCfm))", unit: isSI ? "CFM" : "CFM")
                        kpiTile(title: I18n.t("totalLength", lang), value: "\(Int(isSI ? UnitConverter.ftToM(totalLen) : totalLen))", unit: isSI ? "m" : "ft")
                        kpiTile(title: I18n.t("totalMetal", lang), value: String(format: "%.0f", isSI ? UnitConverter.sqFtToSqM(totalArea) : totalArea), unit: isSI ? "m²" : "sqft")
                    }

                    // Action Buttons: PDF Export & Clear
                    HStack(spacing: 10) {
                        Button(action: {
                            if let url = PdfExporter.generatePdf(state: state) {
                                pdfURL = url
                                showingShareSheet = true
                            }
                        }) {
                            HStack {
                                Image(systemName: "doc.text.fill")
                                Text(I18n.t("exportPdf", lang))
                                    .font(.system(size: 13, weight: .bold))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(AppTheme.primaryBlue)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        Button(action: {
                            showingClearAlert = true
                        }) {
                            Image(systemName: "trash")
                                .font(.system(size: 14))
                                .padding(10)
                                .background(AppTheme.bgCardElevated)
                                .foregroundColor(AppTheme.statusRed)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }
                .padding(14)
                .background(AppTheme.bgCard)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // 2. Duct Runs List
                if project.runs.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "tray")
                            .font(.system(size: 40))
                            .foregroundColor(AppTheme.textMuted)

                        Text(I18n.t("noRunsTitle", lang))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(AppTheme.textSecondary)

                        Button(action: {
                            viewModel.loadDemoProject()
                        }) {
                            Text(I18n.t("loadDemoRuns", lang))
                                .font(.system(size: 12, weight: .bold))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 8)
                                .background(AppTheme.bgCardElevated)
                                .foregroundColor(AppTheme.accentSky)
                                .clipShape(Capsule())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(36)
                    .background(AppTheme.bgCard)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    VStack(spacing: 10) {
                        ForEach(project.runs) { run in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Text(run.tag)
                                            .font(.system(size: 14, weight: .black, design: .monospaced))
                                            .foregroundColor(AppTheme.accentSky)

                                        Text(run.shape.uppercased())
                                            .font(.system(size: 9, weight: .bold))
                                            .padding(.horizontal, 6)
                                            .padding(.vertical, 2)
                                            .background(AppTheme.bgCardElevated)
                                            .foregroundColor(AppTheme.textSecondary)
                                            .clipShape(Capsule())
                                    }

                                    Spacer()

                                    // Actions: Duplicate & Delete
                                    HStack(spacing: 12) {
                                        Button(action: {
                                            viewModel.duplicateRun(id: run.id)
                                        }) {
                                            Image(systemName: "doc.on.doc")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.textSecondary)
                                        }

                                        Button(action: {
                                            viewModel.removeRun(id: run.id)
                                        }) {
                                            Image(systemName: "trash")
                                                .font(.system(size: 13))
                                                .foregroundColor(AppTheme.statusRed)
                                        }
                                    }
                                }

                                Text(run.desc)
                                    .font(.system(size: 12))
                                    .foregroundColor(AppTheme.textSecondary)

                                Divider().background(AppTheme.borderSubtle)

                                // Run technical metrics grid
                                HStack {
                                    metricColumn(
                                        title: I18n.t("dimensions", lang),
                                        val: run.shape == "round" ? "Ø \(Int(run.diameter))\"" : "\(Int(run.width))\"×\(Int(run.height))\""
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("airflow", lang),
                                        val: "\(Int(run.cfm)) CFM"
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("velocity", lang),
                                        val: "\(Int(run.velocity)) FPM"
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("frictionRate", lang),
                                        val: String(format: "%.3f", run.friction)
                                    )
                                }

                                HStack {
                                    metricColumn(
                                        title: I18n.t("length", lang),
                                        val: "\(Int(run.lengthFt)) ft"
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("staticDrop", lang),
                                        val: String(format: "%.3f in", run.staticDrop)
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("gauge", lang),
                                        val: run.gauge
                                    )
                                    Spacer()
                                    metricColumn(
                                        title: I18n.t("metalArea", lang),
                                        val: "\(String(format: "%.1f", run.metalAreaSqFt)) sqft"
                                    )
                                }
                            }
                            .padding(12)
                            .background(AppTheme.bgCard)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
                            )
                        }
                    }
                }
            }
            .padding(16)
        }
        .background(AppTheme.bgDark)
        .sheet(isPresented: $showingShareSheet) {
            if let url = pdfURL {
                ShareSheet(activityItems: [url])
            }
        }
        .sheet(isPresented: $showingEditProjectSheet) {
            EditProjectSheet(project: project) { name, eng, date, sys in
                viewModel.updateProjectInfo(name: name, engineer: eng, date: date, systemTag: sys)
                showingEditProjectSheet = false
            }
        }
        .alert(isPresented: $showingClearAlert) {
            Alert(
                title: Text(I18n.t("confirmClear", lang)),
                message: Text(I18n.t("confirmClearMsg", lang)),
                primaryButton: .destructive(Text(I18n.t("clearAll", lang))) {
                    viewModel.clearAllRuns()
                },
                secondaryButton: .cancel(Text(I18n.t("cancel", lang)))
            )
        }
    }

    private func kpiTile(title: String, value: String, unit: String) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(AppTheme.textSecondary)
                .lineLimit(1)
            Text(value)
                .font(.system(size: 15, weight: .black, design: .monospaced))
                .foregroundColor(AppTheme.accentSky)
                .lineLimit(1)
            Text(unit)
                .font(.system(size: 9, weight: .bold))
                .foregroundColor(AppTheme.textMuted)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
        .background(AppTheme.bgCardElevated)
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private func metricColumn(title: String, val: String) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 9))
                .foregroundColor(AppTheme.textMuted)
            Text(val)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(AppTheme.textPrimary)
        }
    }
}

// MARK: - Edit Project Metadata Sheet
struct EditProjectSheet: View {
    let project: ProjectState
    let onSave: (String, String, String, String) -> Void

    @State private var name: String
    @State private var engineer: String
    @State private var date: String
    @State private var systemTag: String
    @Environment(\.presentationMode) var presentationMode

    init(project: ProjectState, onSave: @escaping (String, String, String, String) -> Void) {
        self.project = project
        self.onSave = onSave
        _name = State(initialValue: project.name)
        _engineer = State(initialValue: project.engineer)
        _date = State(initialValue: project.date)
        _systemTag = State(initialValue: project.systemTag)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Project Information")) {
                    TextField("Project Name", text: $name)
                    TextField("Lead HVAC Engineer", text: $engineer)
                    TextField("Date", text: $date)
                    TextField("System Tag (e.g. AHU-1)", text: $systemTag)
                }
            }
            .navigationTitle("Edit Project Info")
            .navigationBarItems(
                leading: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("Save") {
                    onSave(name, engineer, date, systemTag)
                }
                .font(.headline)
            )
        }
    }
}


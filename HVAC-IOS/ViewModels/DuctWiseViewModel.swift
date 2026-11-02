import Foundation
import SwiftUI
import Combine

// MARK: - Main Application ViewModel
final class DuctWiseViewModel: ObservableObject {

    static let defaultRuns: [DuctRun] = [
        DuctRun(
            id: UUID().uuidString,
            tag: "S-MAIN-01",
            desc: "AHU-1 Supply Main Trunk",
            shape: "rectangular",
            cfm: 1400.0,
            width: 20.0,
            height: 10.0,
            diameter: 15.2,
            lengthFt: 35.0,
            velocity: 1008.0,
            friction: 0.082,
            staticDrop: 0.029,
            aspectRatio: 2.0,
            gauge: "24 ga (0.70 mm)",
            metalAreaSqFt: 175.0
        ),
        DuctRun(
            id: UUID().uuidString,
            tag: "S-BR-01",
            desc: "Living Room Supply Branch",
            shape: "round",
            cfm: 450.0,
            width: 0.0,
            height: 0.0,
            diameter: 10.0,
            lengthFt: 22.0,
            velocity: 825.0,
            friction: 0.085,
            staticDrop: 0.019,
            aspectRatio: 1.0,
            gauge: "26 ga (0.55 mm)",
            metalAreaSqFt: 57.6
        ),
        DuctRun(
            id: UUID().uuidString,
            tag: "S-BR-02",
            desc: "Master Bedroom Supply Branch",
            shape: "round",
            cfm: 320.0,
            width: 0.0,
            height: 0.0,
            diameter: 9.0,
            lengthFt: 18.0,
            velocity: 724.0,
            friction: 0.078,
            staticDrop: 0.014,
            aspectRatio: 1.0,
            gauge: "26 ga (0.55 mm)",
            metalAreaSqFt: 42.4
        ),
        DuctRun(
            id: UUID().uuidString,
            tag: "R-MAIN-01",
            desc: "Central Return Trunk",
            shape: "rectangular",
            cfm: 1400.0,
            width: 22.0,
            height: 12.0,
            diameter: 17.5,
            lengthFt: 28.0,
            velocity: 764.0,
            friction: 0.048,
            staticDrop: 0.013,
            aspectRatio: 1.83,
            gauge: "24 ga (0.70 mm)",
            metalAreaSqFt: 158.7
        )
    ]

    @Published var state: AppState

    init() {
        self.state = AppState(
            project: ProjectState(runs: Self.defaultRuns)
        )
    }

    // MARK: - Global Header Controls
    func toggleLanguage() {
        state.lang = (state.lang == "vi") ? "en" : "vi"
    }

    func toggleUnitSystem() {
        state.unitSystem = (state.unitSystem == "IP") ? "SI" : "IP"
    }

    func setActiveTab(_ tab: Int) {
        state.activeTab = tab
    }

    func setAltitude(_ altitudeFt: Double) {
        state.altitudeFt = min(max(altitudeFt, -1000.0), 15000.0)
    }

    func setTemperature(_ tempF: Double) {
        state.tempF = min(max(tempF, -40.0), 200.0)
    }

    // MARK: - Tab 1: Duct Sizer Controls
    func setSizingMode(_ mode: String) {
        state.sizer.mode = mode
        recalculateSizing()
    }

    func setDuctShape(_ shape: String) {
        state.sizer.shape = shape
        recalculateSizing()
    }

    func setAirflow(_ cfm: Double) {
        state.sizer.cfm = max(10.0, cfm)
        recalculateSizing()
    }

    func setTargetFriction(_ friction: Double) {
        state.sizer.targetFriction = max(0.01, friction)
        recalculateSizing()
    }

    func setTargetVelocity(_ velocity: Double) {
        state.sizer.targetVelocity = max(100.0, velocity)
        recalculateSizing()
    }

    func setRectWidth(_ width: Double) {
        state.sizer.rectWidth = max(2.0, width)
    }

    func setRectHeight(_ height: Double) {
        state.sizer.rectHeight = max(2.0, height)
    }

    func setRoundDiameter(_ d: Double) {
        state.sizer.roundDiameter = max(2.0, d)
    }

    func setFlatOvalMajor(_ major: Double) {
        state.sizer.flatOvalMajor = max(2.0, major)
    }

    func setFlatOvalMinor(_ minor: Double) {
        state.sizer.flatOvalMinor = max(2.0, minor)
    }

    func setLockDimension(_ lock: String) {
        state.sizer.lockDimension = lock
        recalculateSizing()
    }

    func setAppPreset(_ presetId: String) {
        guard let band = Standards.applicationDesignBands.first(where: { $0.id == presetId }) else { return }
        let midVel = (band.optFpmMin + band.optFpmMax) / 2.0
        state.sizer.appPresetId = presetId
        state.sizer.targetVelocity = midVel
        state.sizer.targetFriction = band.typicalFrictionIP
        recalculateSizing()
    }

    func setDuctLength(_ lengthFt: Double) {
        state.sizer.ductLengthFt = max(1.0, lengthFt)
    }

    func setRunTag(_ tag: String) {
        state.sizer.runTag = tag
    }

    func setRunDesc(_ desc: String) {
        state.sizer.runDesc = desc
    }

    func applyStockSize(w: Double, h: Double) {
        if state.sizer.shape == "round" {
            state.sizer.roundDiameter = w
        } else {
            state.sizer.rectWidth = w
            state.sizer.rectHeight = h
        }
    }

    func recalculateSizing() {
        let cfm = state.sizer.cfm
        let densityCorr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        if state.sizer.mode == "friction" {
            let reqDe = HvacFormulas.solveDiameterFromFriction(
                cfm: cfm,
                frictionRate: state.sizer.targetFriction,
                densityMultiplier: densityCorr.lossMultiplier
            )
            let roundedDe = (reqDe * 10.0).rounded() / 10.0

            switch state.sizer.lockDimension {
            case "height":
                let w = HvacFormulas.solveHuebscherWidth(de: roundedDe, b: state.sizer.rectHeight)
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectWidth = (w * 10.0).rounded() / 10.0
            case "width":
                let h = HvacFormulas.solveHuebscherWidth(de: roundedDe, b: state.sizer.rectWidth)
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectHeight = (h * 10.0).rounded() / 10.0
            default:
                // Proportional rectangular ~ 1.5:1 ratio
                let h = roundedDe * 0.8
                let w = HvacFormulas.solveHuebscherWidth(de: roundedDe, b: h)
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectWidth = (w * 10.0).rounded() / 10.0
                state.sizer.rectHeight = (h * 10.0).rounded() / 10.0
            }
        } else if state.sizer.mode == "velocity" {
            let reqAreaSqFt = HvacFormulas.areaFromCfmAndVelocity(cfm: cfm, fpm: state.sizer.targetVelocity)
            let reqDe = sqrt((reqAreaSqFt * 144.0 * 4.0) / Double.pi)
            let roundedDe = (reqDe * 10.0).rounded() / 10.0

            switch state.sizer.lockDimension {
            case "height":
                let w = (reqAreaSqFt * 144.0) / state.sizer.rectHeight
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectWidth = (w * 10.0).rounded() / 10.0
            case "width":
                let h = (reqAreaSqFt * 144.0) / state.sizer.rectWidth
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectHeight = (h * 10.0).rounded() / 10.0
            default:
                let h = roundedDe * 0.8
                let w = (reqAreaSqFt * 144.0) / h
                state.sizer.roundDiameter = roundedDe
                state.sizer.rectWidth = (w * 10.0).rounded() / 10.0
                state.sizer.rectHeight = (h * 10.0).rounded() / 10.0
            }
        }
    }

    func addCurrentSizerToJobList() {
        let s = state.sizer
        let densityCorr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        let areaSqFt: Double
        let de: Double
        let aspect: Double

        switch s.shape {
        case "round":
            de = s.roundDiameter
            areaSqFt = HvacFormulas.roundAreaSqFt(diameterIn: de)
            aspect = 1.0
        case "flatOval":
            let oval = HvacFormulas.flatOvalProperties(major: s.flatOvalMajor, minor: s.flatOvalMinor)
            de = oval.equivalentRoundDe
            areaSqFt = oval.areaSqFt
            aspect = oval.aspectRatio
        default:
            de = HvacFormulas.huebscherRectangular(a: s.rectWidth, b: s.rectHeight)
            areaSqFt = HvacFormulas.rectangularAreaSqFt(widthIn: s.rectWidth, heightIn: s.rectHeight)
            aspect = HvacFormulas.getAspectRatio(w: s.rectWidth, h: s.rectHeight)
        }

        let velocity = HvacFormulas.velocityFromCfmAndArea(cfm: s.cfm, areaSqFt: areaSqFt)
        let friction = HvacFormulas.calculateFrictionRate(cfm: s.cfm, diameterIn: de, densityMultiplier: densityCorr.lossMultiplier)
        let staticDrop = HvacFormulas.calculateStaticDrop(frictionRatePer100Ft: friction, totalEquivLengthFt: s.ductLengthFt)
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
        let metalArea = HvacFormulas.calculateSheetMetalArea(shape: s.shape, dim1In: dim1, dim2In: dim2, lengthFt: s.ductLengthFt).areaSqFt

        let newRun = DuctRun(
            id: UUID().uuidString,
            tag: s.runTag,
            desc: s.runDesc,
            shape: s.shape,
            cfm: s.cfm,
            width: (s.shape == "rectangular") ? s.rectWidth : ((s.shape == "flatOval") ? s.flatOvalMajor : 0.0),
            height: (s.shape == "rectangular") ? s.rectHeight : ((s.shape == "flatOval") ? s.flatOvalMinor : 0.0),
            diameter: (s.shape == "round") ? s.roundDiameter : ((de * 10.0).rounded() / 10.0),
            lengthFt: s.ductLengthFt,
            velocity: velocity.rounded(),
            friction: (friction * 1000.0).rounded() / 1000.0,
            staticDrop: (staticDrop * 1000.0).rounded() / 1000.0,
            aspectRatio: (aspect * 100.0).rounded() / 100.0,
            gauge: gauge,
            metalAreaSqFt: (metalArea * 10.0).rounded() / 10.0
        )

        state.project.runs.append(newRun)
    }

    // Suggestions generator for Stock Sizes
    func getStockSuggestions() -> [StockSuggestion] {
        let cfm = state.sizer.cfm
        let densityCorr = HvacFormulas.getAirDensityCorrection(altitudeFt: state.altitudeFt, tempF: state.tempF)

        if state.sizer.shape == "round" {
            let reqDe: Double
            if state.sizer.mode == "friction" {
                reqDe = HvacFormulas.solveDiameterFromFriction(cfm: cfm, frictionRate: state.sizer.targetFriction, densityMultiplier: densityCorr.lossMultiplier)
            } else {
                let area = HvacFormulas.areaFromCfmAndVelocity(cfm: cfm, fpm: state.sizer.targetVelocity)
                reqDe = sqrt((area * 144.0 * 4.0) / Double.pi)
            }

            guard reqDe > 0 else { return [] }

            return Standards.stockRoundSizesIP.compactMap { d -> StockSuggestion? in
                let area = HvacFormulas.roundAreaSqFt(diameterIn: d)
                let vel = HvacFormulas.velocityFromCfmAndArea(cfm: cfm, areaSqFt: area)
                let f = HvacFormulas.calculateFrictionRate(cfm: cfm, diameterIn: d, densityMultiplier: densityCorr.lossMultiplier)
                let diff = ((d - reqDe) / reqDe) * 100.0
                if abs(diff) > 35.0 { return nil }
                return StockSuggestion(
                    label: "Ø \(Int(d))\"",
                    width: d,
                    height: d,
                    de: d,
                    velocity: vel.rounded(),
                    friction: (f * 1000.0).rounded() / 1000.0,
                    deviationPercent: (diff * 10.0).rounded() / 10.0
                )
            }
            .sorted(by: { abs($0.deviationPercent) < abs($1.deviationPercent) })
            .prefix(4)
            .map { $0 }
        } else {
            // Rectangular stock suggestions
            let reqDe: Double
            if state.sizer.mode == "friction" {
                reqDe = HvacFormulas.solveDiameterFromFriction(cfm: cfm, frictionRate: state.sizer.targetFriction, densityMultiplier: densityCorr.lossMultiplier)
            } else {
                let area = HvacFormulas.areaFromCfmAndVelocity(cfm: cfm, fpm: state.sizer.targetVelocity)
                reqDe = sqrt((area * 144.0 * 4.0) / Double.pi)
            }

            guard reqDe > 0 else { return [] }

            var list: [StockSuggestion] = []
            for h in Standards.stockRectHeightsIP {
                let exactW = HvacFormulas.solveHuebscherWidth(de: reqDe, b: h)
                let roundedW = (exactW / 2.0).rounded() * 2.0 // Round to even stock width
                if roundedW >= 6.0 && roundedW <= 48.0 {
                    let actualDe = HvacFormulas.huebscherRectangular(a: roundedW, b: h)
                    let area = HvacFormulas.rectangularAreaSqFt(widthIn: roundedW, heightIn: h)
                    let vel = HvacFormulas.velocityFromCfmAndArea(cfm: cfm, areaSqFt: area)
                    let f = HvacFormulas.calculateFrictionRate(cfm: cfm, diameterIn: actualDe, densityMultiplier: densityCorr.lossMultiplier)
                    let diff = ((actualDe - reqDe) / reqDe) * 100.0
                    if abs(diff) < 25.0 {
                        list.append(
                            StockSuggestion(
                                label: "\(Int(roundedW))\" × \(Int(h))\"",
                                width: roundedW,
                                height: h,
                                de: (actualDe * 10.0).rounded() / 10.0,
                                velocity: vel.rounded(),
                                friction: (f * 1000.0).rounded() / 1000.0,
                                deviationPercent: (diff * 10.0).rounded() / 10.0
                            )
                        )
                    }
                }
            }
            return Array(list.sorted(by: { abs($0.deviationPercent) < abs($1.deviationPercent) }).prefix(4))
        }
    }

    // MARK: - Tab 2: Fits the Bay Controls
    func setBayPreset(_ presetId: String) {
        guard let preset = Standards.joistBayPresets.first(where: { $0.id == presetId }) else { return }
        state.fitsBay.presetId = presetId
        state.fitsBay.customWidthIn = preset.cavityWidthIn
        state.fitsBay.customHeightIn = preset.cavityHeightIn
    }

    func setCustomBayCavity(widthIn: Double, heightIn: Double) {
        state.fitsBay.customWidthIn = max(4.0, widthIn)
        state.fitsBay.customHeightIn = max(3.0, heightIn)
    }

    func setInsulation(_ insulationId: String) {
        state.fitsBay.insulationId = insulationId
    }

    func toggleBayRotated() {
        state.fitsBay.rotated.toggle()
    }

    func setHangerAllowance(_ inches: Double) {
        state.fitsBay.hangerAllowanceIn = max(0.0, inches)
    }

    // MARK: - Tab 4: Static Budget Controls
    func setEquipmentESP(_ esp: Double) {
        state.staticBudget.equipmentESP = max(0.05, esp)
    }

    func setStraightLength(_ lengthFt: Double) {
        state.staticBudget.straightLengthFt = max(1.0, lengthFt)
    }

    func addFitting(_ fittingId: String) {
        if let idx = state.staticBudget.fittings.firstIndex(where: { $0.id == fittingId }) {
            state.staticBudget.fittings[idx].qty += 1
        } else {
            state.staticBudget.fittings.append(FittingItem(id: fittingId, qty: 1))
        }
    }

    func removeFitting(_ fittingId: String) {
        if let idx = state.staticBudget.fittings.firstIndex(where: { $0.id == fittingId }) {
            if state.staticBudget.fittings[idx].qty > 1 {
                state.staticBudget.fittings[idx].qty -= 1
            } else {
                state.staticBudget.fittings.remove(at: idx)
            }
        }
    }

    func toggleComponent(_ componentId: String) {
        if let idx = state.staticBudget.components.firstIndex(where: { $0.id == componentId }) {
            state.staticBudget.components[idx].enabled.toggle()
        }
    }

    func updateComponentDrop(_ componentId: String, drop: Double) {
        if let idx = state.staticBudget.components.firstIndex(where: { $0.id == componentId }) {
            state.staticBudget.components[idx].drop = max(0.0, drop)
        }
    }

    // MARK: - Tab 5: Job List Controls
    func updateProjectInfo(name: String, engineer: String, date: String, systemTag: String) {
        state.project.name = name
        state.project.engineer = engineer
        state.project.date = date
        state.project.systemTag = systemTag
    }

    func removeRun(id: String) {
        state.project.runs.removeAll(where: { $0.id == id })
    }

    func duplicateRun(id: String) {
        if let original = state.project.runs.first(where: { $0.id == id }) {
            var copy = original
            copy.id = UUID().uuidString
            copy.tag = "\(original.tag)-COPY"
            state.project.runs.append(copy)
        }
    }

    func clearAllRuns() {
        state.project.runs.removeAll()
    }

    func loadDemoProject() {
        state.project.runs = Self.defaultRuns
    }
}


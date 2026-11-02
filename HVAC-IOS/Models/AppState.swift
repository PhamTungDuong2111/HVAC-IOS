import Foundation

// MARK: - Sub-Models & State Entities

struct FittingItem: Identifiable, Codable, Equatable {
    var id: String
    var qty: Int
}

struct ComponentItem: Identifiable, Codable, Equatable {
    var id: String
    var drop: Double
    var enabled: Bool
}

struct SizerState: Codable, Equatable {
    var mode: String = "friction" // "friction", "velocity", "dimensions"
    var shape: String = "rectangular" // "rectangular", "round", "flatOval"
    var cfm: Double = 1200.0
    var targetFriction: Double = 0.08
    var targetVelocity: Double = 900.0
    var rectWidth: Double = 18.0
    var rectHeight: Double = 10.0
    var roundDiameter: Double = 14.0
    var flatOvalMajor: Double = 20.0
    var flatOvalMinor: Double = 10.0
    var lockDimension: String = "none" // "none", "width", "height"
    var appPresetId: String = "res_supply_trunk"
    var ductLengthFt: Double = 30.0
    var runTag: String = "S-TRUNK-01"
    var runDesc: String = "Main Supply Trunk"
}

struct FitsBayState: Codable, Equatable {
    var presetId: String = "2x10_16oc"
    var customWidthIn: Double = 14.5
    var customHeightIn: Double = 9.25
    var insulationId: String = "external_wrap_1.5"
    var rotated: Bool = false
    var hangerAllowanceIn: Double = 0.5
}

struct StaticBudgetState: Codable, Equatable {
    var equipmentESP: Double = 0.50
    var straightLengthFt: Double = 50.0
    var fittings: [FittingItem] = [
        FittingItem(id: "elbow_90_smooth_vanes", qty: 2),
        FittingItem(id: "trunk_tee_branch", qty: 1),
        FittingItem(id: "takeoff_conical", qty: 4),
        FittingItem(id: "boot_register_end", qty: 4)
    ]
    var components: [ComponentItem] = [
        ComponentItem(id: "cooling_coil", drop: 0.22, enabled: true),
        ComponentItem(id: "air_filter_merv11", drop: 0.16, enabled: true),
        ComponentItem(id: "supply_registers", drop: 0.03, enabled: true),
        ComponentItem(id: "return_grilles", drop: 0.03, enabled: true)
    ]
}

struct ProjectState: Codable, Equatable {
    var name: String = "Villa Palm Residence HVAC"
    var engineer: String = "Pham Tung Duong"
    var date: String = "2026-10-26"
    var systemTag: String = "AHU-01 (3-Ton Heat Pump)"
    var runs: [DuctRun] = []
}

struct AppState: Codable, Equatable {
    var lang: String = "vi" // Default Vietnamese as requested
    var unitSystem: String = "IP" // "IP" or "SI"
    var activeTab: Int = 0 // 0: Sizer, 1: FitsBay, 2: Velocity, 3: StaticBudget, 4: JobList, 5: Altitude
    var altitudeFt: Double = 0.0
    var tempF: Double = 70.0
    var sizer: SizerState = SizerState()
    var fitsBay: FitsBayState = FitsBayState()
    var staticBudget: StaticBudgetState = StaticBudgetState()
    var project: ProjectState = ProjectState()
}


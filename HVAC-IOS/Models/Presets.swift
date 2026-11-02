import Foundation

// MARK: - Stock Suggestion Model
struct StockSuggestion: Identifiable, Equatable {
    var id: String { label }
    let label: String
    let width: Double
    let height: Double
    let de: Double
    let velocity: Double
    let friction: Double
    let deviationPercent: Double
}

// MARK: - Design Band Model
struct DesignBand: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let category: String // "residential", "commercial", "specialty"
    let minFpm: Double
    let optFpmMin: Double
    let optFpmMax: Double
    let maxFpm: Double
    let typicalFrictionIP: Double
    let ncRating: String
    let descriptionKey: String
}

// MARK: - Joist Bay Preset
struct JoistBayPreset: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let cavityWidthIn: Double
    let cavityHeightIn: Double
    let label: String
}

// MARK: - Insulation Type
struct InsulationType: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let thicknessIn: Double
    let external: Bool
}

// MARK: - Fitting Definition
struct Fitting: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let equivFt: Double
    let category: String
}

// MARK: - Component Pressure Drop Definition
struct ComponentPressureDrop: Identifiable, Equatable {
    let id: String
    let nameKey: String
    let defaultDropInWg: Double
    let range: String
}


import Foundation

// MARK: - Duct Run representation for Duct Schedule & Job List
struct DuctRun: Identifiable, Codable, Equatable {
    var id: String = UUID().uuidString
    var tag: String
    var desc: String
    var shape: String // "rectangular", "round", "flatOval"
    var cfm: Double
    var width: Double = 0.0
    var height: Double = 0.0
    var diameter: Double = 0.0
    var lengthFt: Double = 0.0
    var velocity: Double = 0.0
    var friction: Double = 0.0
    var staticDrop: Double = 0.0
    var aspectRatio: Double = 1.0
    var gauge: String = ""
    var metalAreaSqFt: Double = 0.0
}

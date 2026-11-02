import Foundation

// MARK: - Unit Conversion Utilities
// Bidirectional conversions between Imperial (IP) and Metric (SI) systems.
enum UnitConverter {
    // Length: inches <-> mm
    static func inToMm(_ inch: Double) -> Double { inch * 25.4 }
    static func mmToIn(_ mm: Double) -> Double { mm / 25.4 }

    // Length: feet <-> meters
    static func ftToM(_ ft: Double) -> Double { ft * 0.3048 }
    static func mToFt(_ m: Double) -> Double { m / 0.3048 }

    // Airflow: CFM <-> L/s <-> m³/h
    static func cfmToLps(_ cfm: Double) -> Double { cfm * 0.471947 }
    static func lpsToCfm(_ lps: Double) -> Double { lps / 0.471947 }
    static func cfmToM3h(_ cfm: Double) -> Double { cfm * 1.69901 }
    static func m3hToCfm(_ m3h: Double) -> Double { m3h / 1.69901 }

    // Velocity: FPM <-> m/s
    static func fpmToMs(_ fpm: Double) -> Double { fpm * 0.00508 }
    static func msToFpm(_ ms: Double) -> Double { ms / 0.00508 }

    // Friction rate: in.wg / 100 ft <-> Pa / m
    static func inwg100ftToPaM(_ v: Double) -> Double { v * 8.165 }
    static func paMToInwg100ft(_ v: Double) -> Double { v / 8.165 }

    // Pressure: in.wg <-> Pascal
    static func inwgToPa(_ inwg: Double) -> Double { inwg * 248.84 }
    static func paToInwg(_ pa: Double) -> Double { pa / 248.84 }

    // Temperature: °F <-> °C
    static func fToC(_ f: Double) -> Double { ((f - 32.0) * 5.0) / 9.0 }
    static func cToF(_ c: Double) -> Double { (c * 9.0) / 5.0 + 32.0 }

    // Area: sq ft <-> sq m
    static func sqFtToSqM(_ sqFt: Double) -> Double { sqFt * 0.092903 }
    static func sqMToSqFt(_ sqM: Double) -> Double { sqM / 0.092903 }
}


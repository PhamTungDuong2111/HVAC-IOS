import Foundation

// MARK: - HVAC Engineering Calculation Engine
// Reference: ASHRAE Fundamentals (Chapter 21: Duct Design),
// ACCA Manual D, and SMACNA HVAC Duct Construction Standards.
enum HvacFormulas {

    // Universal physical constants
    static let stdAirDensityIP: Double = 0.075   // lb/ft³ at 70°F, 29.92 in.Hg (sea level)
    static let stdAirDensitySI: Double = 1.204   // kg/m³ at 20°C, 101.325 kPa

    // MARK: - Altitude & Temperature Air Density Correction
    struct DensityCorrection {
        let altitudeFt: Double
        let tempF: Double
        let densityRatio: Double
        let pressureRatio: Double
        let actualDensityIP: Double
        let actualDensitySI: Double
        let lossMultiplier: Double
    }

    static func getAirDensityCorrection(altitudeFt: Double = 0.0, tempF: Double = 70.0) -> DensityCorrection {
        let safeAlt = min(max(altitudeFt, -1000.0), 15000.0)
        let safeTemp = min(max(tempF, -40.0), 200.0)

        let pressureRatio = pow(1.0 - 6.8753e-6 * safeAlt, 5.2559)
        let tempRatio = (460.0 + 70.0) / (460.0 + safeTemp)
        let densityRatio = max(pressureRatio * tempRatio, 0.4)
        let actualDensityIP = stdAirDensityIP * densityRatio
        let actualDensitySI = stdAirDensitySI * densityRatio

        return DensityCorrection(
            altitudeFt: safeAlt,
            tempF: safeTemp,
            densityRatio: densityRatio,
            pressureRatio: pressureRatio,
            actualDensityIP: actualDensityIP,
            actualDensitySI: actualDensitySI,
            lossMultiplier: densityRatio
        )
    }

    // MARK: - Huebscher Equation: Equivalent Circular Diameter of Rectangular Duct
    // De = 1.30 * ((a * b)^0.625) / ((a + b)^0.25)
    static func huebscherRectangular(a: Double, b: Double) -> Double {
        if a <= 0 || b <= 0 { return 0.0 }
        let numerator = pow(a * b, 0.625)
        let denominator = pow(a + b, 0.25)
        return 1.30 * (numerator / denominator)
    }

    // MARK: - Solve for unknown rectangular dimension using Huebscher equation (Newton-Raphson)
    static func solveHuebscherWidth(de: Double, b: Double) -> Double {
        if de <= 0 || b <= 0 { return 0.0 }
        var a = (Double.pi * pow(de / 2.0, 2)) / b
        if a <= 0 { a = de }

        for _ in 0..<25 {
            let currentDe = huebscherRectangular(a: a, b: b)
            let diff = currentDe - de
            if abs(diff) < 0.0001 { break }

            let delta = 0.001
            let dePlus = huebscherRectangular(a: a + delta, b: b)
            let derivative = (dePlus - currentDe) / delta

            if abs(derivative) < 1e-7 { break }
            a -= diff / derivative
            if a <= 0.1 { a = 0.1 }
        }
        return a
    }

    // MARK: - Flat Oval Duct Calculations
    struct FlatOvalResult {
        let major: Double
        let minor: Double
        let areaSqIn: Double
        let areaSqFt: Double
        let perimeterIn: Double
        let hydraulicDiameter: Double
        let equivalentRoundDe: Double
        let aspectRatio: Double
    }

    static func flatOvalProperties(major: Double, minor: Double) -> FlatOvalResult {
        let a = max(major, minor)
        let b = min(major, minor)
        if a <= 0 || b <= 0 {
            return FlatOvalResult(major: a, minor: b, areaSqIn: 0, areaSqFt: 0, perimeterIn: 0, hydraulicDiameter: 0, equivalentRoundDe: 0, aspectRatio: 1.0)
        }

        let areaSqIn = (Double.pi * pow(b, 2)) / 4.0 + b * (a - b)
        let areaSqFt = areaSqIn / 144.0
        let perimeterIn = Double.pi * b + 2.0 * (a - b)
        let hydraulicDiameter = (4.0 * areaSqIn) / perimeterIn
        let equivalentRoundDe = 1.55 * (pow(areaSqIn, 0.625) / pow(perimeterIn, 0.25))

        return FlatOvalResult(
            major: a,
            minor: b,
            areaSqIn: areaSqIn,
            areaSqFt: areaSqFt,
            perimeterIn: perimeterIn,
            hydraulicDiameter: hydraulicDiameter,
            equivalentRoundDe: equivalentRoundDe,
            aspectRatio: a / b
        )
    }

    // MARK: - ASHRAE Friction Loss Calculation
    // f (in.wg / 100 ft) = 0.109136 * (Q^1.9) / (De^5.02)
    static func calculateFrictionRate(cfm: Double, diameterIn: Double, densityMultiplier: Double = 1.0) -> Double {
        if cfm <= 0 || diameterIn <= 0 { return 0.0 }
        let stdLoss = (0.109136 * pow(cfm, 1.9)) / pow(diameterIn, 5.02)
        return stdLoss * densityMultiplier
    }

    // MARK: - Solve Diameter from Airflow (CFM) & Friction Rate (in.wg / 100 ft)
    static func solveDiameterFromFriction(cfm: Double, frictionRate: Double, densityMultiplier: Double = 1.0) -> Double {
        if cfm <= 0 || frictionRate <= 0 { return 0.0 }
        let stdFriction = frictionRate / densityMultiplier
        let term = (0.109136 * pow(cfm, 1.9)) / stdFriction
        return pow(term, 1.0 / 5.02)
    }

    static func velocityFromCfmAndArea(cfm: Double, areaSqFt: Double) -> Double {
        if areaSqFt <= 0 { return 0.0 }
        return cfm / areaSqFt
    }

    static func cfmFromVelocityAndArea(fpm: Double, areaSqFt: Double) -> Double {
        return fpm * areaSqFt
    }

    static func areaFromCfmAndVelocity(cfm: Double, fpm: Double) -> Double {
        if fpm <= 0 { return 0.0 }
        return cfm / fpm
    }

    static func roundAreaSqFt(diameterIn: Double) -> Double {
        return (Double.pi * pow(diameterIn / 2.0, 2)) / 144.0
    }

    static func rectangularAreaSqFt(widthIn: Double, heightIn: Double) -> Double {
        return (widthIn * heightIn) / 144.0
    }

    static func getAspectRatio(w: Double, h: Double) -> Double {
        if w <= 0 || h <= 0 { return 1.0 }
        return max(w, h) / min(w, h)
    }

    enum AspectLevel {
        case optimal
        case good
        case acceptable
        case warning
    }

    struct AspectStatus {
        let level: AspectLevel
        let colorHex: String
    }

    static func getAspectRatioStatus(aspectRatio: Double) -> AspectStatus {
        if aspectRatio <= 2.0 {
            return AspectStatus(level: .optimal, colorHex: "10B981")
        } else if aspectRatio <= 3.0 {
            return AspectStatus(level: .good, colorHex: "06B6D4")
        } else if aspectRatio <= 4.0 {
            return AspectStatus(level: .acceptable, colorHex: "F59E0B")
        } else {
            return AspectStatus(level: .warning, colorHex: "EF4444")
        }
    }

    static func calculateStaticDrop(frictionRatePer100Ft: Double, totalEquivLengthFt: Double, componentDropsInWg: Double = 0.0) -> Double {
        let ductFrictionDrop = (frictionRatePer100Ft * totalEquivLengthFt) / 100.0
        return ductFrictionDrop + componentDropsInWg
    }

    struct StaticBudgetResult {
        let equipmentESP: Double
        let componentDrops: Double
        let availableStaticPressure: Double
        let totalEquivLengthFt: Double
        let designFrictionRate: Double
    }

    static func calculateStaticBudget(equipmentESP: Double, componentDrops: Double, totalEquivLengthFt: Double) -> StaticBudgetResult {
        let asp = max(0.0, equipmentESP - componentDrops)
        let designFrictionRate = totalEquivLengthFt > 0 ? (asp * 100.0) / totalEquivLengthFt : 0.0
        return StaticBudgetResult(
            equipmentESP: equipmentESP,
            componentDrops: componentDrops,
            availableStaticPressure: asp,
            totalEquivLengthFt: totalEquivLengthFt,
            designFrictionRate: designFrictionRate
        )
    }

    struct SheetMetalResult {
        let areaSqFt: Double
        let areaSqM: Double
        let perimeterFt: Double
    }

    static func calculateSheetMetalArea(shape: String, dim1In: Double, dim2In: Double, lengthFt: Double) -> SheetMetalResult {
        let perimeterFt: Double
        switch shape {
        case "round":
            perimeterFt = (Double.pi * dim1In) / 12.0
        case "flatOval":
            perimeterFt = flatOvalProperties(major: dim1In, minor: dim2In).perimeterIn / 12.0
        default:
            perimeterFt = (2.0 * (dim1In + dim2In)) / 12.0
        }
        let areaSqFt = perimeterFt * lengthFt
        let areaSqM = UnitConverter.sqFtToSqM(areaSqFt)
        return SheetMetalResult(areaSqFt: areaSqFt, areaSqM: areaSqM, perimeterFt: perimeterFt)
    }

    static func getRecommendedGauge(maxDimensionIn: Double) -> String {
        switch maxDimensionIn {
        case ...12.0:
            return "26 ga (0.55 mm)"
        case ...30.0:
            return "24 ga (0.70 mm)"
        case ...54.0:
            return "22 ga (0.85 mm)"
        case ...84.0:
            return "20 ga (1.00 mm)"
        default:
            return "18 ga (1.30 mm)"
        }
    }
}

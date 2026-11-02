import Foundation

// MARK: - HVAC Industry Standards & Engineering Presets
// References:
// - ASHRAE Handbook - Fundamentals (Chapter 21: Duct Design)
// - ACCA Manual D (Residential Duct Systems)
// - SMACNA HVAC Duct Construction Standards
enum Standards {

    // Standard Commercial Stock Round Duct Diameters (Inches)
    static let stockRoundSizesIP: [Double] = [
        4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0, 32.0, 34.0, 36.0, 40.0
    ]

    // Standard Stock Round Duct Diameters (Millimetres - ISO / EN 1506)
    static let stockRoundSizesSI: [Double] = [
        100.0, 125.0, 150.0, 160.0, 200.0, 250.0, 315.0, 355.0, 400.0, 450.0, 500.0, 560.0, 630.0, 710.0, 800.0, 900.0, 1000.0
    ]

    // Standard Rectangular Stock Heights (Inches)
    static let stockRectHeightsIP: [Double] = [
        6.0, 8.0, 10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 28.0, 32.0
    ]

    static let stockRectHeightsSI: [Double] = [
        150.0, 200.0, 250.0, 300.0, 350.0, 400.0, 450.0, 500.0, 600.0, 700.0, 800.0
    ]

    // MARK: - Application Design Bands (ASHRAE / ACCA)
    static let applicationDesignBands: [DesignBand] = [
        DesignBand(
            id: "res_supply_trunk",
            nameKey: "bandResSupplyTrunk",
            category: "residential",
            minFpm: 600.0,
            optFpmMin: 700.0,
            optFpmMax: 900.0,
            maxFpm: 1000.0,
            typicalFrictionIP: 0.08,
            ncRating: "NC 25 - 30",
            descriptionKey: "descResSupplyTrunk"
        ),
        DesignBand(
            id: "res_supply_branch",
            nameKey: "bandResSupplyBranch",
            category: "residential",
            minFpm: 400.0,
            optFpmMin: 500.0,
            optFpmMax: 700.0,
            maxFpm: 800.0,
            typicalFrictionIP: 0.08,
            ncRating: "NC 20 - 25",
            descriptionKey: "descResSupplyBranch"
        ),
        DesignBand(
            id: "res_return_trunk",
            nameKey: "bandResReturnTrunk",
            category: "residential",
            minFpm: 500.0,
            optFpmMin: 600.0,
            optFpmMax: 700.0,
            maxFpm: 800.0,
            typicalFrictionIP: 0.06,
            ncRating: "NC 25 - 30",
            descriptionKey: "descResReturnTrunk"
        ),
        DesignBand(
            id: "res_return_branch",
            nameKey: "bandResReturnBranch",
            category: "residential",
            minFpm: 350.0,
            optFpmMin: 400.0,
            optFpmMax: 600.0,
            maxFpm: 700.0,
            typicalFrictionIP: 0.06,
            ncRating: "NC 20 - 25",
            descriptionKey: "descResReturnBranch"
        ),
        DesignBand(
            id: "com_supply_main",
            nameKey: "bandComSupplyMain",
            category: "commercial",
            minFpm: 900.0,
            optFpmMin: 1000.0,
            optFpmMax: 1500.0,
            maxFpm: 1800.0,
            typicalFrictionIP: 0.10,
            ncRating: "NC 30 - 35",
            descriptionKey: "descComSupplyMain"
        ),
        DesignBand(
            id: "com_supply_branch",
            nameKey: "bandComSupplyBranch",
            category: "commercial",
            minFpm: 600.0,
            optFpmMin: 800.0,
            optFpmMax: 1200.0,
            maxFpm: 1400.0,
            typicalFrictionIP: 0.08,
            ncRating: "NC 25 - 30",
            descriptionKey: "descComSupplyBranch"
        ),
        DesignBand(
            id: "com_return_main",
            nameKey: "bandComReturnMain",
            category: "commercial",
            minFpm: 700.0,
            optFpmMin: 800.0,
            optFpmMax: 1200.0,
            maxFpm: 1500.0,
            typicalFrictionIP: 0.08,
            ncRating: "NC 30 - 35",
            descriptionKey: "descComReturnMain"
        ),
        DesignBand(
            id: "exhaust_ventilation",
            nameKey: "bandExhaustVent",
            category: "specialty",
            minFpm: 1000.0,
            optFpmMin: 1200.0,
            optFpmMax: 1800.0,
            maxFpm: 2200.0,
            typicalFrictionIP: 0.12,
            ncRating: "NC 35 - 45",
            descriptionKey: "descExhaustVent"
        ),
        DesignBand(
            id: "sound_sensitive",
            nameKey: "bandSoundSensitive",
            category: "specialty",
            minFpm: 250.0,
            optFpmMin: 350.0,
            optFpmMax: 500.0,
            maxFpm: 650.0,
            typicalFrictionIP: 0.05,
            ncRating: "NC 15 - 20",
            descriptionKey: "descSoundSensitive"
        )
    ]

    // MARK: - Joist Bay Presets
    static let joistBayPresets: [JoistBayPreset] = [
        JoistBayPreset(id: "2x8_16oc", nameKey: "joist2x8_16", cavityWidthIn: 14.5, cavityHeightIn: 7.25, label: "2x8 Joist @ 16\" O.C."),
        JoistBayPreset(id: "2x10_16oc", nameKey: "joist2x10_16", cavityWidthIn: 14.5, cavityHeightIn: 9.25, label: "2x10 Joist @ 16\" O.C."),
        JoistBayPreset(id: "2x12_16oc", nameKey: "joist2x12_16", cavityWidthIn: 14.5, cavityHeightIn: 11.25, label: "2x12 Joist @ 16\" O.C."),
        JoistBayPreset(id: "2x10_24oc", nameKey: "joist2x10_24", cavityWidthIn: 22.5, cavityHeightIn: 9.25, label: "2x10 Joist @ 24\" O.C."),
        JoistBayPreset(id: "2x12_24oc", nameKey: "joist2x12_24", cavityWidthIn: 22.5, cavityHeightIn: 11.25, label: "2x12 Joist @ 24\" O.C."),
        JoistBayPreset(id: "floor_truss_14", nameKey: "joistTruss14", cavityWidthIn: 22.5, cavityHeightIn: 14.0, label: "Floor Truss 14\" @ 24\" O.C."),
        JoistBayPreset(id: "custom", nameKey: "joistCustom", cavityWidthIn: 18.0, cavityHeightIn: 12.0, label: "Custom Framing / Chase")
    ]

    // MARK: - Insulation & Liner Types
    static let insulationTypes: [InsulationType] = [
        InsulationType(id: "none", nameKey: "insulNone", thicknessIn: 0.0, external: false),
        InsulationType(id: "internal_0.5", nameKey: "insulAcoustic05", thicknessIn: 0.5, external: false),
        InsulationType(id: "internal_1.0", nameKey: "insulAcoustic10", thicknessIn: 1.0, external: false),
        InsulationType(id: "external_wrap_1.5", nameKey: "insulWrap15", thicknessIn: 1.5, external: true),
        InsulationType(id: "external_wrap_2.0", nameKey: "insulWrap20", thicknessIn: 2.0, external: true)
    ]

    // MARK: - Equivalent Length of Duct Fittings (TEL in Feet)
    static let fittingCatalog: [Fitting] = [
        Fitting(id: "elbow_90_smooth_vanes", nameKey: "fitElbow90Vanes", equivFt: 10.0, category: "elbow"),
        Fitting(id: "elbow_90_smooth_novanes", nameKey: "fitElbow90NoVanes", equivFt: 30.0, category: "elbow"),
        Fitting(id: "elbow_90_mitered", nameKey: "fitElbow90Mitered", equivFt: 60.0, category: "elbow"),
        Fitting(id: "elbow_45_smooth", nameKey: "fitElbow45Smooth", equivFt: 10.0, category: "elbow"),
        Fitting(id: "trunk_tee_branch", nameKey: "fitTeeBranch", equivFt: 35.0, category: "tee"),
        Fitting(id: "trunk_tee_thru", nameKey: "fitTeeThru", equivFt: 10.0, category: "tee"),
        Fitting(id: "takeoff_conical", nameKey: "fitTakeoffConical", equivFt: 15.0, category: "takeoff"),
        Fitting(id: "takeoff_straight_collar", nameKey: "fitTakeoffCollar", equivFt: 35.0, category: "takeoff"),
        Fitting(id: "boot_register_straight", nameKey: "fitBootStraight", equivFt: 25.0, category: "boot"),
        Fitting(id: "boot_register_end", nameKey: "fitBootEnd", equivFt: 30.0, category: "boot"),
        Fitting(id: "damper_balancing", nameKey: "fitDamper", equivFt: 10.0, category: "damper"),
        Fitting(id: "duct_transition", nameKey: "fitTransition", equivFt: 10.0, category: "transition")
    ]

    // MARK: - Component Pressure Drops (ACCA Manual D)
    static let componentPressureDrops: [ComponentPressureDrop] = [
        ComponentPressureDrop(id: "cooling_coil", nameKey: "compCoolingCoil", defaultDropInWg: 0.22, range: "0.15 - 0.35"),
        ComponentPressureDrop(id: "air_filter_merv8", nameKey: "compFilterMerv8", defaultDropInWg: 0.10, range: "0.08 - 0.14"),
        ComponentPressureDrop(id: "air_filter_merv11", nameKey: "compFilterMerv11", defaultDropInWg: 0.16, range: "0.12 - 0.20"),
        ComponentPressureDrop(id: "air_filter_merv13", nameKey: "compFilterMerv13", defaultDropInWg: 0.22, range: "0.18 - 0.28"),
        ComponentPressureDrop(id: "supply_registers", nameKey: "compSupplyRegisters", defaultDropInWg: 0.03, range: "0.03 - 0.06"),
        ComponentPressureDrop(id: "return_grilles", nameKey: "compReturnGrilles", defaultDropInWg: 0.03, range: "0.03 - 0.06"),
        ComponentPressureDrop(id: "balancing_dampers", nameKey: "compBalancingDampers", defaultDropInWg: 0.03, range: "0.02 - 0.05"),
        ComponentPressureDrop(id: "electric_heat", nameKey: "compElectricHeat", defaultDropInWg: 0.05, range: "0.03 - 0.10")
    ]
}


import SwiftUI

// MARK: - Global App Header Component
struct AppHeaderView: View {
    @ObservedObject var viewModel: DuctWiseViewModel

    var body: some View {
        let lang = viewModel.state.lang
        let isSI = viewModel.state.unitSystem == "SI"

        VStack(spacing: 10) {
            HStack(alignment: .center) {
                // Brand / Title
                HStack(spacing: 10) {
                    Image(systemName: "wind")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(AppTheme.accentSky)
                        .padding(8)
                        .background(AppTheme.bgCardElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(I18n.t("appTitle", lang))
                                .font(.system(size: 19, weight: .bold))
                                .foregroundColor(AppTheme.textPrimary)

                            Text("OFFLINE")
                                .font(.system(size: 9, weight: .black))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(AppTheme.statusGreen.opacity(0.2))
                                .foregroundColor(AppTheme.statusGreen)
                                .clipShape(Capsule())
                        }

                        Text(I18n.t("appSubtitle", lang))
                            .font(.system(size: 10.5))
                            .foregroundColor(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }

                Spacer()

                // Actions: Unit Toggle & Language Toggle
                HStack(spacing: 8) {
                    // Unit System Pill
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleUnitSystem()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "ruler")
                                .font(.system(size: 10, weight: .bold))
                            Text(isSI ? "SI" : "IP")
                                .font(.system(size: 11, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.bgCardElevated)
                        .foregroundColor(AppTheme.accentSky)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.borderMedium, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    // Language Pill
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            viewModel.toggleLanguage()
                        }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "globe")
                                .font(.system(size: 10, weight: .bold))
                            Text(lang.uppercased())
                                .font(.system(size: 11, weight: .bold))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(AppTheme.bgCardElevated)
                        .foregroundColor(AppTheme.accentTeal)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(AppTheme.borderMedium, lineWidth: 1)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.bgCard)
        .overlay(
            Rectangle()
                .frame(height: 1)
                .foregroundColor(AppTheme.borderSubtle),
            alignment: .bottom
        )
    }
}

import SwiftUI

// MARK: - Root Main ContentView
struct ContentView: View {
    @StateObject private var viewModel = DuctWiseViewModel()

    var body: some View {
        let lang = viewModel.state.lang

        VStack(spacing: 0) {
            // Global App Header
            AppHeaderView(viewModel: viewModel)

            // Active Tab Content
            TabView(selection: Binding(
                get: { viewModel.state.activeTab },
                set: { viewModel.setActiveTab($0) }
            )) {
                SizerView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabSizer", lang), systemImage: "slider.horizontal.3")
                    }
                    .tag(0)

                FitsTheBayView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabFitsBay", lang), systemImage: "viewfinder")
                    }
                    .tag(1)

                VelocityView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabVelocity", lang), systemImage: "gauge.with.needle")
                    }
                    .tag(2)

                StaticBudgetView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabStaticBudget", lang), systemImage: "fanblades")
                    }
                    .tag(3)

                JobListView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabJobList", lang), systemImage: "list.bullet.rectangle")
                    }
                    .tag(4)

                AltitudeView(viewModel: viewModel)
                    .tabItem {
                        Label(I18n.t("tabAltitude", lang), systemImage: "mountain.2")
                    }
                    .tag(5)
            }
            .accentColor(AppTheme.accentSky)
        }
        .background(AppTheme.bgDark.edgesIgnoringSafeArea(.all))
        .preferredColorScheme(.dark)
    }
}


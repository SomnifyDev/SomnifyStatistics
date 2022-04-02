import SwiftUI
import HealthCore
import HealthKit
import SleepStatistics
import HeartIndicator
import HeartCore
import Logger

struct ContentView: View {

    @State private var shouldShowLastSleepAlert: Bool = false
    @State private var shouldShowLastSleepErrorAlert: Bool = false
    @State private var shouldShowHeartIndicatorAlert: Bool = false
    @State private var shouldShowHeartIndicatorErrorAlert: Bool = false

    @State private var lastSleepDataDescription: String = ""
    @State private var heartIndicatorDataDescription: String = ""

    private let heartIndicatorProvider = ExampleAppDependenciesFactory.shared.makeHeartIndicatorProvider()
    private let healthCoreProvider = ExampleAppDependenciesFactory.shared.makeHealthCoreProvider()
    private let heartCoreProvider = ExampleAppDependenciesFactory.shared.makeHeartCoreProvider()

    private let defaultDateInterval: DateInterval = {
        let today = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        return DateInterval(start: threeDaysAgo, end: today)
    }()

    var body: some View {
        Button {
            Task { await retrieveLastSleepInterval() }
        } label: {
            Text("Retrieve last sleep interval")
        }
        .alert(isPresented: $shouldShowLastSleepAlert) {
            Alert(title: Text(lastSleepDataDescription))
        }
        .alert(isPresented: $shouldShowLastSleepAlert) {
            Alert(title: Text(lastSleepDataDescription))
        }

        Button {
            Task { await getPNN50() }
        } label: {
            Text("Get PNN50 indicator data")
        }
        .alert(isPresented: $shouldShowHeartIndicatorAlert) {
            Alert(title: Text(heartIndicatorDataDescription))
        }
        .alert(isPresented: $shouldShowLastSleepAlert) {
            Alert(title: Text(lastSleepDataDescription))
        }

        Button {
            Task { await getRSDNN() }
        } label: {
            Text("Get RSDNN indicator data")
        }

    }

    private func retrieveLastSleepInterval() async {
        do {
            let sleepStatisticsProvider = SleepStatisticsProvider()
            let res = try await sleepStatisticsProvider.getLastSleepDateInterval(type: .asleep)
            lastSleepDataDescription = String(describing: res)
            shouldShowLastSleepAlert = true
        } catch {
            shouldShowLastSleepErrorAlert = true
        }
    }

    private func getPNN50() async {
        do {
            let result = try await heartIndicatorProvider.calculatePNN50(for: defaultDateInterval)
            print(result)
        } catch {
            Logger.logEvent("Error occured while getting PNN50: \(error.localizedDescription)", type: .error)
        }
    }

    private func getRSDNN() async {
        do {
            let result = try await heartIndicatorProvider.calculateRMSSD(for: defaultDateInterval)
            print(result)
        } catch {
            Logger.logEvent("Error occured while getting RSDNN: \(error.localizedDescription)", type: .error)
        }
    }

}

// MARK: - Factory

struct ExampleAppDependenciesFactory {

    static var shared = ExampleAppDependenciesFactory()

    func makeHeartIndicatorProvider() -> HeartIndicatorProvider {
        return HeartIndicatorProvider(
            healthCoreProvider: makeHealthCoreProvider(),
            heartCoreProvider: makeHeartCoreProvider()
        )
    }

    func makeHealthCoreProvider() -> HealthCoreProvider {
        return HealthCoreProvider(
            dataTypesToRead: [
                .seriesType(type: .heartbeat()),
                .quantityType(forIdentifier: .heartRateVariabilitySDNN)
            ],
            dataTypesToWrite: []
        )
    }

    func makeHeartCoreProvider() -> HeartCoreProvider {
        return HeartCoreProvider(healthCoreProvider: makeHealthCoreProvider())
    }

}

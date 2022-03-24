import SwiftUI
import HealthCore
import HealthKit
import SleepStatistics
import HeartIndicator

struct ContentView: View {

    @State private var shouldShowLastSleepAlert: Bool = false
    @State private var shouldShowLastSleepErrorAlert: Bool = false
    @State private var shouldShowHeartIndicatorAlert: Bool = false
    @State private var shouldShowHeartIndicatorErrorAlert: Bool = false

    @State private var lastSleepDataDescription: String = ""
    @State private var heartIndicatorDataDescription: String = ""

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
            Task { await getHeartIndicator(.HRV) }
        } label: {
            Text("Get HRV indicator data")
        }
        .alert(isPresented: $shouldShowHeartIndicatorAlert) {
            Alert(title: Text(heartIndicatorDataDescription))
        }
        .alert(isPresented: $shouldShowLastSleepAlert) {
            Alert(title: Text(lastSleepDataDescription))
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

    private func getHeartIndicator(_ indicator: HeartIndicator) async {
        let heartIndicatorProvider = HeartIndicatorProvider(
            healthCoreProvider: HealthCoreProvider(
                dataTypesToRead: [
                    .quantityType(forIdentifier: .heartRate),
                    .quantityType(forIdentifier: .heartRateVariabilitySDNN),
                    .seriesType(type: .heartbeat())
                ],
                dataTypesToWrite: []
            )
        )
        do {
            let period = DateInterval(
                start: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
                end: Date()
            )
            // TODO: - Implement example of working with getting indicators
        } catch {
            shouldShowHeartIndicatorErrorAlert = true
        }
    }

}

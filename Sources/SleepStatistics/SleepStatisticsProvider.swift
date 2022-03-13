import SleepCore
import HealthCore
import HealthKit

// MARK: - SleepStatisticsProviderError

public enum SleepStatisticsProviderError: Error {
    case unhandledError
}

// MARK: - SleepStatisticsProvider

public final class SleepStatisticsProvider {
    private let sleepCoreProvider: SleepCoreProvider

    private var sleep: Sleep?

    public init() {
        let neededDataTypes: Set<HealthCoreProvider.SampleType> = Set([
            .quantityType(forIdentifier: .heartRate),
            .quantityType(forIdentifier: .activeEnergyBurned),
            .quantityType(forIdentifier: .respiratoryRate),
            .categoryType(forIdentifier: .sleepAnalysis, categoryValue: 0)
        ])
        let healthCoreProvider = HealthCoreProvider(
            dataTypesToRead: neededDataTypes,
            dataTypesToWrite: []
        )

        self.sleepCoreProvider = SleepCoreProvider(healthCoreProvider: healthCoreProvider)
    }

    private func getLastSleepIfNeeded() async throws -> Sleep? {
        guard self.sleep == nil else {
            return self.sleep
        }

        self.sleep = try await self.sleepCoreProvider.retrieveLastSleep()
        return self.sleep
    }

    public func getLastSleepDateInterval(type: HKCategoryValueSleepAnalysis) async throws -> DateInterval? {
        _ = try await self.getLastSleepIfNeeded()

        switch type {
        case .inBed:
            return self.sleep?.inbedInterval
        case .asleep:
            return self.sleep?.sleepInterval
        case .awake:
            throw SleepStatisticsProviderError.unhandledError
        @unknown default:
            throw SleepStatisticsProviderError.unhandledError
        }
    }

    public func getLastSleepHealthData(type: HKQuantityTypeIdentifier) async throws -> [SampleData]? {
        _ = try await self.getLastSleepIfNeeded()

        switch type {
        case .heartRate:
            return self.sleep?.heartData
        case .activeEnergyBurned:
            return self.sleep?.energyData
        case .respiratoryRate:
            return self.sleep?.respiratoryData
        default:
            throw SleepStatisticsProviderError.unhandledError
        }
    }

    public func getLastSleepPhasesData() async throws -> [SleepPhase]? {
        try await self.getLastSleepIfNeeded()?.phases
    }
}

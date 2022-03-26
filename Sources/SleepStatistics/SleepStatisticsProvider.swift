import SleepCore
import HealthCore
import HealthKit

// MARK: - SleepStatisticsProviderError

public enum SleepStatisticsProviderError: Error {
    case notSupportedTypeError
}

// MARK: - SleepStatisticsProvider

public final class SleepStatisticsProvider: ObservableObject {

    // MARK: - Private properties

    private let sleepCoreProvider: SleepCoreProvider
    private var sleep: Sleep?

    // MARK: - Init

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

    // MARK: - Public methods

    public func getLastSleepDateInterval(type: HKCategoryValueSleepAnalysis) async throws -> DateInterval? {
        try await self.getLastSleepIfNeeded()

        switch type {
        case .inBed:
            return self.sleep?.inbedInterval
        case .asleep:
            return self.sleep?.sleepInterval
        default:
            throw SleepStatisticsProviderError.notSupportedTypeError
        }
    }

    public func getLastSleepHealthData(type: HKQuantityTypeIdentifier) async throws -> [SampleData]? {
        try await self.getLastSleepIfNeeded()

        switch type {
        case .heartRate:
            return self.sleep?.heartData
        case .activeEnergyBurned:
            return self.sleep?.energyData
        case .respiratoryRate:
            return self.sleep?.respiratoryData
        default:
            throw SleepStatisticsProviderError.notSupportedTypeError
        }
    }

    public func getLastSleepPhasesData() async throws -> [SleepPhase]? {
        try await self.getLastSleepIfNeeded()?.phases
    }
    
    // MARK: - Private methods

    @discardableResult
    private func getLastSleepIfNeeded() async throws -> Sleep? {
        guard self.sleep == nil else {
            return self.sleep
        }
        self.sleep = try await self.sleepCoreProvider.retrieveLastSleep()
        return self.sleep
    }
    
}

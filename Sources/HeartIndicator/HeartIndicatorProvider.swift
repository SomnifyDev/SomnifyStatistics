import CommonExtensions
import Foundation
import HealthCore
import HeartCore
import HealthKit
import Logger

// MARK: - Public types

public typealias SDNNIndicatorValue = Double

// MARK: - HeartIndicatorProvider

public final class HeartIndicatorProvider {

    // MARK: - Private properties

    private let healthCoreProvider: HealthCoreProvider
    private let heartCoreProvider: HeartCoreProvider

    // MARK: - Init

    public init(
        healthCoreProvider: HealthCoreProvider,
        heartCoreProvider: HeartCoreProvider
    ) {
        self.healthCoreProvider = healthCoreProvider
        self.heartCoreProvider = heartCoreProvider
    }

    // MARK: - Public methods

    /// Returns heart rate variability indicator during the concrete period of time
    public func calculateHRV(for dateInterval: DateInterval) async throws -> [HRVIndicatorValue]? {
        return try await heartCoreProvider.getHeartRateVariabilityData(dateInterval: dateInterval)
    }

    /// This indicator is recommended to be used on the period of the day to make analysis
    public func calculateSDNN(for dateInterval: DateInterval) async throws -> SDNNIndicatorValue? {
        guard let samples = try await calculateHRV(for: dateInterval) else {
            return nil
        }
        return samples.standardDeviation()
    }

    /// More accurate indicator im comparison with `SDNN`. Recommended to be used to make analysis on the short time interval
    public func calculateRMSSD(for dateInterval: DateInterval) async throws -> Double? {
        guard let heartbeatSeries = try await heartCoreProvider.getHeartbeatSeries(.period(dateInterval)) else {
            return nil
        }
        var result: [Double] = []
        for index in 1..<heartbeatSeries.count {
            result.append(pow(heartbeatSeries[index] - heartbeatSeries[index - 1], 2))
        }
        return sqrt(result.sum() / (Double(heartbeatSeries.count - 1)))
    }

    // TODO: - Implement some other indicators below (e.g. pNN50 etc...)

}

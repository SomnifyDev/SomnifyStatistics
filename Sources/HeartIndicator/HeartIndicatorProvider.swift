import CommonExtensions
import Foundation
import HealthCore
import HeartCore
import HealthKit
import Logger

// MARK: - Public types

public typealias SDNNIndicatorValue = Double

// MARK: - HeartIndicatorProvider

public final class HeartIndicatorProvider: ObservableObject {

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

    /// Returns heart rate variability indicator during the concrete period of time.
    ///
    /// Actually means time between each heartbeat in milliseconds.
    public func calculateHRV(for dateInterval: DateInterval) async throws -> [HRVIndicatorValue]? {
        return try await heartCoreProvider.getHeartRateVariabilityData(dateInterval: dateInterval)
    }

    /// This number shows whether or not your variability is within the standard overall range. Higher numbers usually indicate that your body is coping better with stress.
    ///
    /// This indicator is recommended to be used on the long period of time (e.g. day) to make analysis.
    public func calculateSDNN(for dateInterval: DateInterval) async throws -> SDNNIndicatorValue? {
        guard let samples = try await calculateHRV(for: dateInterval) else {
            return nil
        }
        return samples.standardDeviation()
    }

    /// Reflects parasympathetic activity (vagal activity) and respiratory sinus arrhythmia (RSA) and shows whether or not the body has had a chance to recover.
    ///
    /// More accurate indicator im comparison with `SDNN`. Recommended to be used to make analysis on the short time interval
    public func calculateRMSSD(for dateInterval: DateInterval) async throws -> Double? {
        guard let heartbeatSeries = try await heartCoreProvider.getHeartbeatSeries(during: dateInterval) else {
            return nil
        }
        var squaredTimeIntervalsDifferences: [Double] = []
        heartbeatSeries.forEach { externalSeries in
            var internalIndex: Int = 1
            while internalIndex < externalSeries.count {
                let isPrecededByGap = externalSeries[internalIndex].precededByGap
                if !isPrecededByGap {
                    let currentValue = externalSeries[internalIndex].timeSinceSeriesStart
                    let previousValue = externalSeries[internalIndex - 1].timeSinceSeriesStart
                    let squaredTimeIntervalsDifference = pow(currentValue - previousValue, 2)
                    squaredTimeIntervalsDifferences.append(squaredTimeIntervalsDifference)
                }
                internalIndex += 1
            }
        }
        return squaredTimeIntervalsDifferences.isEmpty ? nil : sqrt(squaredTimeIntervalsDifferences.sum() / (Double(squaredTimeIntervalsDifferences.count - 1)))
    }

    /// Proportion of adjacent R-R intervals differing by more than 50 ms.
    ///
    /// It shows how active the parasympathetic system is relative to the sympathetic nervous system.
    /// The higher the value, the more relaxed the body is. If the pNN50 is low, you’re either tired or over-stressed.
    public func calculatePNN50(for dateInterval: DateInterval) async throws -> Double? {
        guard let heartbeatSeries = try await heartCoreProvider.getHeartbeatSeries(during: dateInterval) else {
            return nil
        }
        var timeIntervalsDifferences: [Double] = []
        heartbeatSeries.forEach { externalSeries in
            var internalIndex: Int = 1
            while internalIndex < externalSeries.count {
                let isPrecededByGap = externalSeries[internalIndex].precededByGap
                if !isPrecededByGap {
                    let currentValue = externalSeries[internalIndex].timeSinceSeriesStart
                    let previousValue = externalSeries[internalIndex - 1].timeSinceSeriesStart
                    let timeIntervalsDifference = currentValue - previousValue
                    timeIntervalsDifferences.append(timeIntervalsDifference)
                }
                internalIndex += 1
            }
        }
        guard timeIntervalsDifferences.count > 1 else { return nil }
        var result: [Double] = []
        var index: Int = 1
        while index < timeIntervalsDifferences.count {
            result.append(abs(timeIntervalsDifferences[index] - timeIntervalsDifferences[index - 1]))
            index += 1
        }
        let proportion = Double(result.filter { $0 > 0.05 }.count) / Double(result.count)
        return proportion
    }

}

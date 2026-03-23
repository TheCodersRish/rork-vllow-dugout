import Foundation
import HealthKit

@Observable
@MainActor
class HealthKitService {
    var isAuthorized: Bool = false
    var isAvailable: Bool = HKHealthStore.isHealthDataAvailable()
    var stepCount: Int = 0
    var activeCalories: Int = 0
    var heartRate: Int = 0
    var isLoading: Bool = false

    private let healthStore = HKHealthStore()
    private let authKey = "healthkit_authorized"

    init() {
        isAuthorized = UserDefaults.standard.bool(forKey: authKey)
        if isAuthorized {
            Task { await fetchHealthData() }
        }
    }

    func requestAuthorization() async {
        guard isAvailable else { return }

        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.stepCount),
            HKQuantityType(.activeEnergyBurned),
            HKQuantityType(.heartRate)
        ]

        do {
            try await healthStore.requestAuthorization(toShare: [], read: readTypes)
            isAuthorized = true
            UserDefaults.standard.set(true, forKey: authKey)
            await fetchHealthData()
        } catch {
            isAuthorized = false
        }
    }

    func disconnect() {
        isAuthorized = false
        stepCount = 0
        activeCalories = 0
        heartRate = 0
        UserDefaults.standard.set(false, forKey: authKey)
    }

    func fetchHealthData() async {
        guard isAuthorized else { return }
        isLoading = true
        defer { isLoading = false }

        async let steps = fetchTodaySum(for: .stepCount, unit: .count())
        async let calories = fetchTodaySum(for: .activeEnergyBurned, unit: .kilocalorie())
        async let hr = fetchLatestHeartRate()

        stepCount = await steps
        activeCalories = await calories
        heartRate = await hr
    }

    private func fetchTodaySum(for identifier: HKQuantityTypeIdentifier, unit: HKUnit) async -> Int {
        let quantityType = HKQuantityType(identifier)
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let samplePredicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now, options: .strictStartDate)
        let predicate = HKSamplePredicate.quantitySample(type: quantityType, predicate: samplePredicate)

        do {
            let descriptor = HKStatisticsQueryDescriptor(
                predicate: predicate,
                options: .cumulativeSum
            )
            let result = try await descriptor.result(for: healthStore)
            return Int(result?.sumQuantity()?.doubleValue(for: unit) ?? 0)
        } catch {
            return 0
        }
    }

    private func fetchLatestHeartRate() async -> Int {
        let heartRateType = HKQuantityType(.heartRate)
        let predicate = HKSamplePredicate.quantitySample(type: heartRateType)
        let descriptor = HKSampleQueryDescriptor(
            predicates: [predicate],
            sortDescriptors: [SortDescriptor(\.endDate, order: .reverse)],
            limit: 1
        )

        do {
            let results = try await descriptor.result(for: healthStore)
            guard let sample = results.first else { return 0 }
            return Int(sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute())))
        } catch {
            return 0
        }
    }
}

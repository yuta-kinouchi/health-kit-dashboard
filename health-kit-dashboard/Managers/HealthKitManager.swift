import Foundation
import HealthKit

class HealthKitManager: ObservableObject {

    static let shared = HealthKitManager()

    private let healthStore = HKHealthStore()

    @Published var isAuthorized = false
    @Published var todaySteps: Int = 0
    @Published var todayDistance: Double = 0.0
    @Published var todayActiveEnergy: Double = 0.0
    @Published var todayFlightsClimbed: Int = 0
    @Published var todayWalkingSpeed: Double = 0.0
    @Published var weeklyWalkingSpeed: [DailyWalkingSpeedData] = []

    private init() {}

    // MARK: - HealthKit Availability Check

    func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }

    // MARK: - Authorization

    func requestAuthorization() async throws {
        guard isHealthKitAvailable() else {
            throw HealthKitError.notAvailable
        }

        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .flightsClimbed)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
            HKObjectType.quantityType(forIdentifier: .walkingStepLength)!,
            HKObjectType.quantityType(forIdentifier: .walkingAsymmetryPercentage)!,
            HKObjectType.quantityType(forIdentifier: .walkingDoubleSupportPercentage)!
        ]

        try await healthStore.requestAuthorization(toShare: [], read: typesToRead)

        await MainActor.run {
            self.isAuthorized = true
        }
    }

    // MARK: - Fetch Today's Data

    func fetchTodaySteps() async throws {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let steps = try await fetchTodaySum(for: stepType, unit: .count())

        await MainActor.run {
            self.todaySteps = Int(steps)
        }
    }

    func fetchTodayDistance() async throws {
        guard let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let distance = try await fetchTodaySum(for: distanceType, unit: .meter())

        await MainActor.run {
            self.todayDistance = distance
        }
    }

    func fetchTodayActiveEnergy() async throws {
        guard let energyType = HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let energy = try await fetchTodaySum(for: energyType, unit: .kilocalorie())

        await MainActor.run {
            self.todayActiveEnergy = energy
        }
    }

    func fetchTodayFlightsClimbed() async throws {
        guard let flightsType = HKQuantityType.quantityType(forIdentifier: .flightsClimbed) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let flights = try await fetchTodaySum(for: flightsType, unit: .count())

        await MainActor.run {
            self.todayFlightsClimbed = Int(flights)
        }
    }

    func fetchTodayWalkingSpeed() async throws {
        guard let speedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let speed = try await fetchTodayAverage(for: speedType, unit: HKUnit.meter().unitDivided(by: .second()))

        await MainActor.run {
            self.todayWalkingSpeed = speed
        }
    }

    func fetchAllTodayData() async throws {
        try await fetchTodaySteps()
        try await fetchTodayDistance()
        try await fetchTodayActiveEnergy()
        try await fetchTodayFlightsClimbed()
        try await fetchTodayWalkingSpeed()
    }

    // MARK: - Private Helper Methods

    private func fetchTodaySum(for quantityType: HKQuantityType, unit: HKUnit) async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let sum = result?.sumQuantity()?.doubleValue(for: unit) ?? 0.0
                continuation.resume(returning: sum)
            }

            healthStore.execute(query)
        }
    }

    private func fetchTodayAverage(for quantityType: HKQuantityType, unit: HKUnit) async throws -> Double {
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay,
            end: now,
            options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, result, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                let average = result?.averageQuantity()?.doubleValue(for: unit) ?? 0.0
                continuation.resume(returning: average)
            }

            healthStore.execute(query)
        }
    }

    // MARK: - Fetch Weekly Data

    func fetchWeeklySteps() async throws -> [DailyStepData] {
        guard let stepType = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        return try await fetchWeeklyData(for: stepType, unit: .count())
    }

    func fetchWeeklyWalkingSpeed() async throws -> [DailyWalkingSpeedData] {
        guard let speedType = HKQuantityType.quantityType(forIdentifier: .walkingSpeed) else {
            throw HealthKitError.dataTypeNotAvailable
        }

        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -30, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        var interval = DateComponents()
        interval.day = 1

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: speedType,
                quantitySamplePredicate: predicate,
                options: .discreteAverage,
                anchorDate: startDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var dailyData: [DailyWalkingSpeedData] = []

                results?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    let value = statistics.averageQuantity()?.doubleValue(for: HKUnit.meter().unitDivided(by: .second())) ?? 0.0
                    if value > 0 {
                        let data = DailyWalkingSpeedData(date: statistics.startDate, speed: value)
                        dailyData.append(data)
                    }
                }

                continuation.resume(returning: dailyData)
            }

            healthStore.execute(query)
        }
    }

    private func fetchWeeklyData(for quantityType: HKQuantityType, unit: HKUnit) async throws -> [DailyStepData] {
        let calendar = Calendar.current
        let now = Date()
        let startDate = calendar.date(byAdding: .day, value: -7, to: now)!

        let predicate = HKQuery.predicateForSamples(
            withStart: startDate,
            end: now,
            options: .strictStartDate
        )

        var interval = DateComponents()
        interval.day = 1

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsCollectionQuery(
                quantityType: quantityType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum,
                anchorDate: startDate,
                intervalComponents: interval
            )

            query.initialResultsHandler = { _, results, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                var dailyData: [DailyStepData] = []

                results?.enumerateStatistics(from: startDate, to: now) { statistics, _ in
                    let value = statistics.sumQuantity()?.doubleValue(for: unit) ?? 0.0
                    let data = DailyStepData(date: statistics.startDate, value: value)
                    dailyData.append(data)
                }

                continuation.resume(returning: dailyData)
            }

            healthStore.execute(query)
        }
    }
}

// MARK: - Error Handling

enum HealthKitError: LocalizedError {
    case notAvailable
    case dataTypeNotAvailable
    case authorizationFailed

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "HealthKitはこのデバイスで利用できません"
        case .dataTypeNotAvailable:
            return "要求されたデータタイプは利用できません"
        case .authorizationFailed:
            return "HealthKitの認証に失敗しました"
        }
    }
}

// MARK: - Data Models

struct DailyStepData: Identifiable {
    let id = UUID()
    let date: Date
    let value: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var intValue: Int {
        return Int(value)
    }
}

struct DailyWalkingSpeedData: Identifiable {
    let id = UUID()
    let date: Date
    let speed: Double

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        return formatter.string(from: date)
    }

    var speedInKmPerHour: Double {
        return speed * 3.6
    }

    var formattedSpeed: String {
        return String(format: "%.2f", speedInKmPerHour)
    }
}

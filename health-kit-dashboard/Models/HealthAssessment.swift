import Foundation

// MARK: - 健康状態評価モデル

struct HealthAssessment {
    let walkingSpeed: WalkingSpeedAssessment
    let activityLevel: ActivityLevelAssessment
    let overallRisk: RiskLevel
    let recommendations: [String]

    static func assess(
        averageWalkingSpeed: Double,
        dailySteps: Int,
        age: Int = 65
    ) -> HealthAssessment {
        let walkingSpeedAssessment = WalkingSpeedAssessment.assess(speed: averageWalkingSpeed, age: age)
        let activityAssessment = ActivityLevelAssessment.assess(dailySteps: dailySteps)

        // 総合リスク評価
        let overallRisk = calculateOverallRisk(
            walkingSpeedRisk: walkingSpeedAssessment.riskLevel,
            activityRisk: activityAssessment.riskLevel
        )

        // 推奨事項の生成
        var recommendations: [String] = []

        if walkingSpeedAssessment.riskLevel == .high {
            recommendations.append("歩行速度が低下しています。医師に相談することをお勧めします。")
            recommendations.append("バランス運動や筋力トレーニングを検討してください。")
        } else if walkingSpeedAssessment.riskLevel == .medium {
            recommendations.append("歩行速度の維持・改善のため、定期的な運動を心がけましょう。")
        }

        if activityAssessment.riskLevel == .high {
            recommendations.append("活動量が不足しています。1日8000歩以上を目標にしましょう。")
        }

        if overallRisk == .low && recommendations.isEmpty {
            recommendations.append("良好な健康状態を維持しています。この調子で継続しましょう。")
        }

        return HealthAssessment(
            walkingSpeed: walkingSpeedAssessment,
            activityLevel: activityAssessment,
            overallRisk: overallRisk,
            recommendations: recommendations
        )
    }

    private static func calculateOverallRisk(
        walkingSpeedRisk: RiskLevel,
        activityRisk: RiskLevel
    ) -> RiskLevel {
        let riskScore = walkingSpeedRisk.score + activityRisk.score

        if riskScore >= 5 {
            return .high
        } else if riskScore >= 3 {
            return .medium
        } else {
            return .low
        }
    }
}

// MARK: - 歩行速度評価

struct WalkingSpeedAssessment {
    let speed: Double
    let speedInKmPerHour: Double
    let riskLevel: RiskLevel
    let message: String

    static func assess(speed: Double, age: Int) -> WalkingSpeedAssessment {
        let kmPerHour = speed * 3.6

        // 歩行速度の基準値（研究に基づく）
        // 高齢者の場合、1.0 m/s (3.6 km/h) 以下は要注意
        // 0.8 m/s (2.88 km/h) 以下は高リスク
        let riskLevel: RiskLevel
        let message: String

        if speed >= 1.0 {
            riskLevel = .low
            message = "歩行速度は良好です"
        } else if speed >= 0.8 {
            riskLevel = .medium
            message = "歩行速度がやや低下しています"
        } else if speed > 0 {
            riskLevel = .high
            message = "歩行速度の著しい低下が見られます"
        } else {
            riskLevel = .unknown
            message = "データが不足しています"
        }

        return WalkingSpeedAssessment(
            speed: speed,
            speedInKmPerHour: kmPerHour,
            riskLevel: riskLevel,
            message: message
        )
    }
}

// MARK: - 活動レベル評価

struct ActivityLevelAssessment {
    let dailySteps: Int
    let riskLevel: RiskLevel
    let message: String

    static func assess(dailySteps: Int) -> ActivityLevelAssessment {
        let riskLevel: RiskLevel
        let message: String

        if dailySteps >= 8000 {
            riskLevel = .low
            message = "活動量は十分です"
        } else if dailySteps >= 5000 {
            riskLevel = .medium
            message = "活動量がやや不足しています"
        } else if dailySteps > 0 {
            riskLevel = .high
            message = "活動量が不足しています"
        } else {
            riskLevel = .unknown
            message = "データが不足しています"
        }

        return ActivityLevelAssessment(
            dailySteps: dailySteps,
            riskLevel: riskLevel,
            message: message
        )
    }
}

// MARK: - リスクレベル

enum RiskLevel: String, Codable {
    case low = "低リスク"
    case medium = "中リスク"
    case high = "高リスク"
    case unknown = "不明"

    var score: Int {
        switch self {
        case .low: return 1
        case .medium: return 2
        case .high: return 3
        case .unknown: return 0
        }
    }

    var color: String {
        switch self {
        case .low: return "green"
        case .medium: return "yellow"
        case .high: return "red"
        case .unknown: return "gray"
        }
    }

    var icon: String {
        switch self {
        case .low: return "checkmark.circle.fill"
        case .medium: return "exclamationmark.triangle.fill"
        case .high: return "exclamationmark.octagon.fill"
        case .unknown: return "questionmark.circle.fill"
        }
    }
}

// MARK: - トレンド分析

struct WalkingSpeedTrend {
    let currentSpeed: Double
    let previousSpeed: Double
    let changePercentage: Double
    let trend: TrendDirection

    static func analyze(currentData: [DailyWalkingSpeedData]) -> WalkingSpeedTrend? {
        guard currentData.count >= 14 else { return nil }

        let sortedData = currentData.sorted { $0.date < $1.date }
        let recentData = Array(sortedData.suffix(7))
        let previousData = Array(sortedData.dropLast(7).suffix(7))

        guard !recentData.isEmpty && !previousData.isEmpty else { return nil }

        let currentAvg = recentData.reduce(0.0) { $0 + $1.speed } / Double(recentData.count)
        let previousAvg = previousData.reduce(0.0) { $0 + $1.speed } / Double(previousData.count)

        let changePercentage = ((currentAvg - previousAvg) / previousAvg) * 100

        let trend: TrendDirection
        if changePercentage >= 5 {
            trend = .improving
        } else if changePercentage <= -5 {
            trend = .declining
        } else {
            trend = .stable
        }

        return WalkingSpeedTrend(
            currentSpeed: currentAvg,
            previousSpeed: previousAvg,
            changePercentage: changePercentage,
            trend: trend
        )
    }
}

enum TrendDirection: String {
    case improving = "改善傾向"
    case stable = "安定"
    case declining = "低下傾向"

    var icon: String {
        switch self {
        case .improving: return "arrow.up.circle.fill"
        case .stable: return "minus.circle.fill"
        case .declining: return "arrow.down.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .improving: return "green"
        case .stable: return "blue"
        case .declining: return "orange"
        }
    }
}

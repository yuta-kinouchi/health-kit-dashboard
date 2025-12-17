import Foundation

struct ActivityData: Identifiable {
    let id: UUID
    let type: ActivityType
    let value: Double
    let goal: Double
    let unit: String

    init(
        id: UUID = UUID(),
        type: ActivityType,
        value: Double,
        goal: Double,
        unit: String
    ) {
        self.id = id
        self.type = type
        self.value = value
        self.goal = goal
        self.unit = unit
    }

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(value / goal, 1.0)
    }

    var progressPercentage: Int {
        return Int(progress * 100)
    }

    var isGoalAchieved: Bool {
        return value >= goal
    }

    var formattedValue: String {
        return String(format: "%.0f", value)
    }

    var formattedGoal: String {
        return String(format: "%.0f", goal)
    }
}

enum ActivityType: String, Codable {
    case steps = "歩数"
    case distance = "距離"
    case activeEnergy = "消費カロリー"
    case exerciseTime = "運動時間"
    case standHours = "スタンド時間"

    var iconName: String {
        switch self {
        case .steps:
            return "figure.walk"
        case .distance:
            return "location.fill"
        case .activeEnergy:
            return "flame.fill"
        case .exerciseTime:
            return "timer"
        case .standHours:
            return "figure.stand"
        }
    }

    var color: String {
        switch self {
        case .steps:
            return "blue"
        case .distance:
            return "green"
        case .activeEnergy:
            return "red"
        case .exerciseTime:
            return "yellow"
        case .standHours:
            return "cyan"
        }
    }
}

extension ActivityData {
    static var samples: [ActivityData] {
        [
            ActivityData(
                type: .steps,
                value: 8543,
                goal: 10000,
                unit: "歩"
            ),
            ActivityData(
                type: .distance,
                value: 6.2,
                goal: 8.0,
                unit: "km"
            ),
            ActivityData(
                type: .activeEnergy,
                value: 423,
                goal: 500,
                unit: "kcal"
            ),
            ActivityData(
                type: .exerciseTime,
                value: 35,
                goal: 30,
                unit: "分"
            )
        ]
    }
}

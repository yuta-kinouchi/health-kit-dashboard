import Foundation

struct HealthData: Identifiable, Codable {
    let id: UUID
    let date: Date
    let steps: Int
    let distance: Double
    let activeEnergy: Double
    let flightsClimbed: Int

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        steps: Int = 0,
        distance: Double = 0.0,
        activeEnergy: Double = 0.0,
        flightsClimbed: Int = 0
    ) {
        self.id = id
        self.date = date
        self.steps = steps
        self.distance = distance
        self.activeEnergy = activeEnergy
        self.flightsClimbed = flightsClimbed
    }

    var distanceInKilometers: Double {
        return distance / 1000.0
    }

    var formattedDistance: String {
        return String(format: "%.2f km", distanceInKilometers)
    }

    var formattedActiveEnergy: String {
        return String(format: "%.0f kcal", activeEnergy)
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

extension HealthData {
    static var sample: HealthData {
        HealthData(
            steps: 8543,
            distance: 6234.5,
            activeEnergy: 423.7,
            flightsClimbed: 12
        )
    }

    static var samples: [HealthData] {
        let calendar = Calendar.current
        let today = Date()

        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return HealthData(
                date: date,
                steps: Int.random(in: 3000...12000),
                distance: Double.random(in: 2000...9000),
                activeEnergy: Double.random(in: 200...600),
                flightsClimbed: Int.random(in: 5...20)
            )
        }
    }
}

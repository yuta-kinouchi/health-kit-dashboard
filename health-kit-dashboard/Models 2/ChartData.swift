import Foundation

struct ChartData: Identifiable {
    let id: UUID
    let date: Date
    let value: Double
    let label: String

    init(
        id: UUID = UUID(),
        date: Date,
        value: Double,
        label: String = ""
    ) {
        self.id = id
        self.date = date
        self.value = value
        self.label = label
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var weekdayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    var formattedValue: String {
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        } else {
            return String(format: "%.0f", value)
        }
    }
}

struct WeeklyChartData {
    let title: String
    let data: [ChartData]
    let unit: String
    let averageValue: Double

    var formattedAverage: String {
        return String(format: "%.0f", averageValue)
    }

    var maxValue: Double {
        return data.map { $0.value }.max() ?? 0
    }

    var minValue: Double {
        return data.map { $0.value }.min() ?? 0
    }

    var totalValue: Double {
        return data.reduce(0) { $0 + $1.value }
    }
}

extension WeeklyChartData {
    static func createWeeklyStepsData(from dailyData: [DailyStepData]) -> WeeklyChartData {
        let chartData = dailyData.map { data in
            ChartData(
                date: data.date,
                value: data.value,
                label: data.formattedDate
            )
        }

        let average = chartData.isEmpty ? 0 : chartData.reduce(0) { $0 + $1.value } / Double(chartData.count)

        return WeeklyChartData(
            title: "週間歩数",
            data: chartData,
            unit: "歩",
            averageValue: average
        )
    }

    static var sample: WeeklyChartData {
        let calendar = Calendar.current
        let today = Date()

        let data = (0..<7).reversed().map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            return ChartData(
                date: date,
                value: Double.random(in: 3000...12000)
            )
        }

        let average = data.reduce(0) { $0 + $1.value } / Double(data.count)

        return WeeklyChartData(
            title: "週間歩数",
            data: data,
            unit: "歩",
            averageValue: average
        )
    }
}

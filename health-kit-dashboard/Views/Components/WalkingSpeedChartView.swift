import SwiftUI
import Charts

struct WalkingSpeedChartView: View {
    let data: [DailyWalkingSpeedData]
    let trend: WalkingSpeedTrend?

    private var chartData: [ChartDataPoint] {
        data.map { ChartDataPoint(date: $0.date, value: $0.speedInKmPerHour) }
    }

    private var averageSpeed: Double {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0.0) { $0 + $1.speedInKmPerHour } / Double(data.count)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("歩行速度の推移（30日間）")
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text("平均: \(String(format: "%.2f", averageSpeed)) km/h")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    if let trend = trend {
                        HStack(spacing: 4) {
                            Image(systemName: trend.trend.icon)
                                .foregroundColor(trendColor(trend.trend))
                            Text(trend.trend.rawValue)
                                .font(.caption)
                                .foregroundColor(trendColor(trend.trend))
                        }
                    }
                }
            }

            if !chartData.isEmpty {
                Chart {
                    ForEach(chartData) { item in
                        LineMark(
                            x: .value("日付", item.date),
                            y: .value("速度", item.value)
                        )
                        .foregroundStyle(Color.healthBlue.gradient)
                        .interpolationMethod(.catmullRom)

                        AreaMark(
                            x: .value("日付", item.date),
                            y: .value("速度", item.value)
                        )
                        .foregroundStyle(Color.healthBlue.opacity(0.1).gradient)
                        .interpolationMethod(.catmullRom)
                    }

                    // 基準線（1.0 m/s = 3.6 km/h）
                    RuleMark(y: .value("基準", 3.6))
                        .foregroundStyle(Color.healthGreen.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("基準値")
                                .font(.caption2)
                                .foregroundColor(.healthGreen)
                        }

                    // 注意線（0.8 m/s = 2.88 km/h）
                    RuleMark(y: .value("注意", 2.88))
                        .foregroundStyle(Color.healthYellow.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                        .annotation(position: .bottom, alignment: .trailing) {
                            Text("注意")
                                .font(.caption2)
                                .foregroundColor(.healthYellow)
                        }
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let speed = value.as(Double.self) {
                                Text(String(format: "%.1f", speed))
                                    .font(.caption2)
                            }
                        }
                    }
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .day, count: 7)) { value in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month().day(), centered: true)
                            .font(.caption2)
                    }
                }
            } else {
                Text("データが不足しています")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(height: 200)
                    .frame(maxWidth: .infinity)
            }

            if let trend = trend {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("前週比")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        HStack(alignment: .lastTextBaseline, spacing: 4) {
                            Image(systemName: trend.changePercentage >= 0 ? "arrow.up" : "arrow.down")
                                .font(.caption)
                                .foregroundColor(trend.changePercentage >= 0 ? .healthGreen : .healthRed)

                            Text(String(format: "%.1f%%", abs(trend.changePercentage)))
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("今週平均")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.2f km/h", trend.currentSpeed * 3.6))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }

                    Divider()
                        .frame(height: 30)

                    VStack(alignment: .leading, spacing: 4) {
                        Text("前週平均")
                            .font(.caption2)
                            .foregroundColor(.secondary)

                        Text(String(format: "%.2f km/h", trend.previousSpeed * 3.6))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .cardStyle()
    }

    private func trendColor(_ trend: TrendDirection) -> Color {
        switch trend {
        case .improving:
            return .healthGreen
        case .stable:
            return .healthBlue
        case .declining:
            return .healthYellow
        }
    }

    struct ChartDataPoint: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
    }
}

#Preview {
    let sampleData = (0..<30).map { day in
        let date = Calendar.current.date(byAdding: .day, value: -30 + day, to: Date())!
        let baseSpeed = 1.0
        let variation = Double.random(in: -0.2...0.2)
        return DailyWalkingSpeedData(date: date, speed: baseSpeed + variation)
    }

    let trend = WalkingSpeedTrend.analyze(currentData: sampleData)

    return ScrollView {
        WalkingSpeedChartView(data: sampleData, trend: trend)
            .padding()
    }
}

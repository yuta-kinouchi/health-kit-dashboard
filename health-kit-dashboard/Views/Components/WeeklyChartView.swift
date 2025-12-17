import SwiftUI
import Charts

struct WeeklyChartView: View {
    let chartData: WeeklyChartData

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(chartData.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                HStack {
                    Text("平均: \(chartData.formattedAverage) \(chartData.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("合計: \(String(format: "%.0f", chartData.totalValue)) \(chartData.unit)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Chart(chartData.data) { item in
                BarMark(
                    x: .value("日付", item.weekdayName),
                    y: .value("値", item.value)
                )
                .foregroundStyle(Color.healthBlue.gradient)
                .cornerRadius(4)
            }
            .frame(height: 180)
            .chartYAxis {
                AxisMarks(position: .leading)
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    WeeklyChartView(chartData: .sample)
        .padding()
}

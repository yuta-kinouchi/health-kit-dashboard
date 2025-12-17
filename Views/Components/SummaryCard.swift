import SwiftUI

struct SummaryCard: View {
    let icon: String
    let title: String
    let value: String
    let unit: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.1))
                .cornerRadius(8)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    VStack(spacing: 12) {
        SummaryCard(
            icon: "figure.walk",
            title: "歩数",
            value: "8,543",
            unit: "歩",
            color: .healthBlue
        )

        SummaryCard(
            icon: "location.fill",
            title: "距離",
            value: "6.2",
            unit: "km",
            color: .healthGreen
        )

        SummaryCard(
            icon: "flame.fill",
            title: "消費カロリー",
            value: "423",
            unit: "kcal",
            color: .healthRed
        )
    }
    .padding()
}

import SwiftUI

struct ActivityCard: View {
    let activity: ActivityData

    var color: Color {
        switch activity.type {
        case .steps:
            return .healthBlue
        case .distance:
            return .healthGreen
        case .activeEnergy:
            return .healthRed
        case .exerciseTime:
            return .healthYellow
        case .standHours:
            return .healthCyan
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: activity.type.iconName)
                    .font(.title3)
                    .foregroundColor(color)

                Spacer()

                Text("\(activity.progressPercentage)%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }

            Text(activity.type.rawValue)
                .font(.caption)
                .foregroundColor(.secondary)

            HStack(alignment: .lastTextBaseline, spacing: 4) {
                Text(activity.formattedValue)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text(activity.unit)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: activity.progress)
                .tint(color)
                .scaleEffect(x: 1, y: 1.5, anchor: .center)

            Text("目標: \(activity.formattedGoal) \(activity.unit)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .cardStyle()
    }
}

#Preview {
    HStack(spacing: 12) {
        ActivityCard(activity: ActivityData(
            type: .steps,
            value: 8543,
            goal: 10000,
            unit: "歩"
        ))

        ActivityCard(activity: ActivityData(
            type: .activeEnergy,
            value: 423,
            goal: 500,
            unit: "kcal"
        ))
    }
    .padding()
}

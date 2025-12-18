import SwiftUI

struct WalkingSpeedCard: View {
    let speed: Double
    let assessment: WalkingSpeedAssessment

    var speedInKmPerHour: Double {
        speed * 3.6
    }

    var riskColor: Color {
        switch assessment.riskLevel {
        case .low:
            return .healthGreen
        case .medium:
            return .healthYellow
        case .high:
            return .healthRed
        case .unknown:
            return .gray
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.walk.motion")
                    .font(.title2)
                    .foregroundColor(riskColor)

                Spacer()

                Image(systemName: assessment.riskLevel.icon)
                    .font(.title3)
                    .foregroundColor(riskColor)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("平均歩行速度")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(String(format: "%.2f", speedInKmPerHour))
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)

                    Text("km/h")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }

                Text(String(format: "%.2f m/s", speed))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                Image(systemName: "info.circle.fill")
                    .foregroundColor(riskColor)

                Text(assessment.message)
                    .font(.subheadline)
                    .foregroundColor(.primary)

                Spacer()
            }
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    VStack(spacing: 16) {
        WalkingSpeedCard(
            speed: 1.2,
            assessment: WalkingSpeedAssessment.assess(speed: 1.2, age: 65)
        )

        WalkingSpeedCard(
            speed: 0.9,
            assessment: WalkingSpeedAssessment.assess(speed: 0.9, age: 65)
        )

        WalkingSpeedCard(
            speed: 0.7,
            assessment: WalkingSpeedAssessment.assess(speed: 0.7, age: 65)
        )
    }
    .padding()
}

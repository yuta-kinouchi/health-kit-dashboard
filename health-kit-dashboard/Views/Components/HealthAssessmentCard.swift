import SwiftUI

struct HealthAssessmentCard: View {
    let assessment: HealthAssessment

    var overallRiskColor: Color {
        switch assessment.overallRisk {
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
            // ヘッダー
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.title2)
                    .foregroundColor(overallRiskColor)

                Text("健康状態評価")
                    .font(.headline)
                    .foregroundColor(.primary)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: assessment.overallRisk.icon)
                        .foregroundColor(overallRiskColor)

                    Text(assessment.overallRisk.rawValue)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(overallRiskColor)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(overallRiskColor.opacity(0.1))
                .cornerRadius(8)
            }

            Divider()

            // 詳細評価
            VStack(spacing: 12) {
                AssessmentRow(
                    title: "歩行速度",
                    riskLevel: assessment.walkingSpeed.riskLevel,
                    message: assessment.walkingSpeed.message,
                    value: String(format: "%.2f km/h", assessment.walkingSpeed.speedInKmPerHour)
                )

                AssessmentRow(
                    title: "活動レベル",
                    riskLevel: assessment.activityLevel.riskLevel,
                    message: assessment.activityLevel.message,
                    value: "\(assessment.activityLevel.dailySteps) 歩"
                )
            }

            if !assessment.recommendations.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.healthYellow)
                        Text("推奨事項")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }

                    ForEach(Array(assessment.recommendations.enumerated()), id: \.offset) { index, recommendation in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .font(.caption)
                                .foregroundColor(.secondary)

                            Text(recommendation)
                                .font(.caption)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding()
        .cardStyle()
    }
}

struct AssessmentRow: View {
    let title: String
    let riskLevel: RiskLevel
    let message: String
    let value: String

    var riskColor: Color {
        switch riskLevel {
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
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(value)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            HStack(spacing: 6) {
                Image(systemName: riskLevel.icon)
                    .font(.caption)
                    .foregroundColor(riskColor)

                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .background(riskColor.opacity(0.05))
        .cornerRadius(8)
    }
}

#Preview {
    VStack(spacing: 16) {
        HealthAssessmentCard(
            assessment: HealthAssessment.assess(
                averageWalkingSpeed: 1.2,
                dailySteps: 9500,
                age: 65
            )
        )

        HealthAssessmentCard(
            assessment: HealthAssessment.assess(
                averageWalkingSpeed: 0.9,
                dailySteps: 6000,
                age: 70
            )
        )

        HealthAssessmentCard(
            assessment: HealthAssessment.assess(
                averageWalkingSpeed: 0.7,
                dailySteps: 3000,
                age: 75
            )
        )
    }
    .padding()
}

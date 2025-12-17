import SwiftUI

struct StepCountCard: View {
    let steps: Int
    let goal: Int

    var progress: Double {
        guard goal > 0 else { return 0 }
        return min(Double(steps) / Double(goal), 1.0)
    }

    var progressPercentage: Int {
        return Int(progress * 100)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "figure.walk")
                    .font(.title2)
                    .foregroundColor(.healthBlue)

                Spacer()

                Text("\(progressPercentage)%")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("歩数")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text("\(steps)")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)

                Text("目標: \(goal)歩")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            ProgressView(value: progress)
                .tint(.healthBlue)
                .scaleEffect(x: 1, y: 2, anchor: .center)
        }
        .padding()
        .cardStyle()
    }
}

#Preview {
    StepCountCard(steps: 8543, goal: 10000)
        .padding()
}

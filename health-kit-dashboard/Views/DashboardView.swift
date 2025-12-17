import SwiftUI

struct DashboardView: View {
    @StateObject private var healthManager = HealthKitManager.shared
    @State private var showingAuthAlert = false
    @State private var weeklyStepsData: [DailyStepData] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if healthManager.isAuthorized {
                        todaySummarySection

                        activityCardsSection

                        weeklyChartSection
                    } else {
                        unauthorizedView
                    }
                }
                .padding()
            }
            .navigationTitle("ヘルスダッシュボード")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await loadData()
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                    }
                }
            }
            .task {
                await checkAuthorization()
            }
            .alert("HealthKitへのアクセス", isPresented: $showingAuthAlert) {
                Button("許可する") {
                    Task {
                        await requestAuthorization()
                    }
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("健康データを読み取るためには、HealthKitへのアクセス許可が必要です。")
            }
        }
    }

    private var todaySummarySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("今日の概要")
                .font(.title2)
                .fontWeight(.bold)

            StepCountCard(steps: healthManager.todaySteps, goal: 10000)

            HStack(spacing: 12) {
                SummaryCard(
                    icon: "location.fill",
                    title: "距離",
                    value: String(format: "%.1f", healthManager.todayDistance / 1000),
                    unit: "km",
                    color: .healthGreen
                )

                SummaryCard(
                    icon: "flame.fill",
                    title: "カロリー",
                    value: String(format: "%.0f", healthManager.todayActiveEnergy),
                    unit: "kcal",
                    color: .healthRed
                )
            }

            SummaryCard(
                icon: "figure.stairs",
                title: "上った階数",
                value: "\(healthManager.todayFlightsClimbed)",
                unit: "階",
                color: .healthPurple
            )
        }
    }

    private var activityCardsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("アクティビティ")
                .font(.title2)
                .fontWeight(.bold)

            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ActivityCard(activity: ActivityData(
                    type: .steps,
                    value: Double(healthManager.todaySteps),
                    goal: 10000,
                    unit: "歩"
                ))

                ActivityCard(activity: ActivityData(
                    type: .distance,
                    value: healthManager.todayDistance / 1000,
                    goal: 8.0,
                    unit: "km"
                ))

                ActivityCard(activity: ActivityData(
                    type: .activeEnergy,
                    value: healthManager.todayActiveEnergy,
                    goal: 500,
                    unit: "kcal"
                ))

                ActivityCard(activity: ActivityData(
                    type: .exerciseTime,
                    value: 0,
                    goal: 30,
                    unit: "分"
                ))
            }
        }
    }

    private var weeklyChartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間統計")
                .font(.title2)
                .fontWeight(.bold)

            if !weeklyStepsData.isEmpty {
                WeeklyChartView(chartData: WeeklyChartData.createWeeklyStepsData(from: weeklyStepsData))
            } else {
                WeeklyChartView(chartData: .sample)
            }
        }
    }

    private var unauthorizedView: some View {
        VStack(spacing: 20) {
            Image(systemName: "heart.text.square.fill")
                .font(.system(size: 80))
                .foregroundColor(.healthRed)

            Text("HealthKitへのアクセスが必要です")
                .font(.title2)
                .fontWeight(.bold)

            Text("健康データを表示するには、HealthKitへのアクセス許可が必要です。")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button(action: {
                showingAuthAlert = true
            }) {
                Text("アクセスを許可")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.healthBlue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
        }
        .padding()
    }

    private func checkAuthorization() async {
        if !healthManager.isAuthorized && healthManager.isHealthKitAvailable() {
            showingAuthAlert = true
        } else if healthManager.isAuthorized {
            await loadData()
        }
    }

    private func requestAuthorization() async {
        do {
            try await healthManager.requestAuthorization()
            await loadData()
        } catch {
            print("Authorization failed: \(error)")
        }
    }

    private func loadData() async {
        do {
            try await healthManager.fetchAllTodayData()
            weeklyStepsData = try await healthManager.fetchWeeklySteps()
        } catch {
            print("Failed to fetch data: \(error)")
        }
    }
}

#Preview {
    DashboardView()
}

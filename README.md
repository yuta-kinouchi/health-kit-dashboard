# Health Kit Dashboard

HealthKitと連携し、歩数などの健康データを表示するiOSダッシュボードアプリ。

## セットアップ手順

### 1. プロジェクトにファイルを追加

Xcodeでプロジェクトを開き、以下のディレクトリとファイルをプロジェクトに追加してください：

1. Xcodeで `health-kit-dashboard.xcodeproj` を開く
2. 左側のプロジェクトナビゲーターで `health-kit-dashboard` グループを選択
3. **File > Add Files to "health-kit-dashboard"** を選択
4. 以下のディレクトリを選択して追加（"Create groups" を選択）：
   - `Managers/`
   - `Models/`
   - `Views/`
   - `Styles/`

### 2. HealthKit Capabilityの有効化

1. プロジェクトナビゲーターでプロジェクトファイルを選択
2. Targetsから `health-kit-dashboard` を選択
3. **Signing & Capabilities** タブを開く
4. **+ Capability** ボタンをクリック
5. **HealthKit** を検索して追加

### 3. Info.plistの設定確認

`Info.plist` に以下のキーが含まれていることを確認：
- `NSHealthShareUsageDescription`: "歩数や健康データを読み取り、ダッシュボードに表示するために使用します。"
- `NSHealthUpdateUsageDescription`: "健康データを記録するために使用します。"

### 4. ビルドと実行

1. シミュレーターまたは実機を選択
2. **Product > Run** (⌘R) でアプリを実行
3. 初回起動時にHealthKitへのアクセス許可を求められるので、許可してください

## プロジェクト構造

```
health-kit-dashboard/
├── Managers/
│   └── HealthKitManager.swift       # HealthKitとの連携を管理
├── Models/
│   ├── HealthData.swift             # 健康データモデル
│   ├── ActivityData.swift           # アクティビティデータモデル
│   └── ChartData.swift              # グラフ表示用データモデル
├── Views/
│   ├── DashboardView.swift          # メインダッシュボード画面
│   └── Components/
│       ├── StepCountCard.swift      # 歩数カード
│       ├── ActivityCard.swift       # アクティビティカード
│       ├── SummaryCard.swift        # サマリーカード
│       └── WeeklyChartView.swift    # 週間グラフ
├── Styles/
│   ├── Colors.swift                 # カラーパレット
│   └── CardStyle.swift              # カードスタイル
├── ContentView.swift                # ルートビュー
└── health_kit_dashboardApp.swift    # アプリエントリーポイント
```

## 機能

### 実装済み
- HealthKitからのデータ取得（歩数、距離、消費カロリー、階段）
- 今日のデータ概要表示
- 週間データのグラフ表示
- アクティビティカード表示
- 目標達成率の可視化

### 今後の実装予定（DEVELOPMENT_PLAN.mdを参照）
- サーバー連携機能
- データキャッシング
- 通知機能
- ウィジェット対応
- Apple Watch対応

## 必要要件

- Xcode 15.0+
- iOS 17.5+
- Swift 5.9+
- 実機またはシミュレーター（HealthKitデータの取得には実機推奨）

## 注意事項

- シミュレーターではHealthKitのデータが限定的です。完全なテストには実機が必要です。
- HealthKitへのアクセス許可は、アプリの初回起動時にユーザーに求められます。
- プライバシーに配慮し、収集したデータは端末内でのみ処理されます（サーバー連携機能実装後は暗号化して送信）。

## トラブルシューティング

### ビルドエラーが発生する場合
1. すべてのSwiftファイルがプロジェクトに追加されているか確認
2. HealthKit Capabilityが有効になっているか確認
3. Clean Build Folder（⇧⌘K）を実行してから再ビルド

### データが表示されない場合
1. HealthKitへのアクセス許可が正しく設定されているか確認
2. 実機を使用している場合、ヘルスケアアプリにデータが存在するか確認
3. シミュレーターを使用している場合、サンプルデータが表示されているか確認

## ライセンス

このプロジェクトは開発中です。

## 詳細な開発計画

詳細な開発計画については [DEVELOPMENT_PLAN.md](DEVELOPMENT_PLAN.md) を参照してください。

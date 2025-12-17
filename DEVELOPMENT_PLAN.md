# ヘルスキットダッシュボードアプリ 開発計画

## プロジェクト概要
iOSのHealthKitと連携し、歩数やその他の健康データを可視化するダッシュボードアプリ。将来的にサーバー連携も視野に入れた拡張可能な設計。

## 開発フェーズ

### Phase 1: HealthKit基盤の構築

#### 1.1 プロジェクト設定
- [x] Xcodeプロジェクトの作成（完了済み）
- [ ] HealthKit Capabilityの有効化
  - Xcode > Target > Signing & Capabilities > "+ Capability" > HealthKit
- [ ] Info.plistへの権限設定追加
  - `NSHealthShareUsageDescription`: ヘルスデータ読み取りの理由を記載
  - `NSHealthUpdateUsageDescription`: ヘルスデータ書き込みの理由を記載（必要な場合）

#### 1.2 HealthKitマネージャーの実装
```
health-kit-dashboard/
├── Managers/
│   └── HealthKitManager.swift
```

実装内容:
- HealthKitの利用可能性チェック
- 権限リクエスト処理
- データ取得機能（歩数、距離、消費カロリー、心拍数など）
- ObservableObjectとして実装し、SwiftUIとの連携を容易に

#### 1.3 データモデルの作成
```
health-kit-dashboard/
├── Models/
│   ├── HealthData.swift
│   ├── StepData.swift
│   ├── ActivityData.swift
│   └── ChartData.swift
```

実装内容:
- 各種健康データを表現する構造体
- 日次、週次、月次の集計データ構造
- グラフ表示用のデータ変換ロジック

### Phase 2: UI/UXの実装

#### 2.1 画面構成
```
health-kit-dashboard/
├── Views/
│   ├── DashboardView.swift       # メインダッシュボード
│   ├── StepCountCard.swift       # 歩数カード
│   ├── ActivityRingsView.swift   # アクティビティリング
│   ├── ChartView.swift           # グラフ表示
│   ├── DetailView.swift          # 詳細画面
│   └── SettingsView.swift        # 設定画面
```

#### 2.2 各コンポーネントの実装
- **DashboardView**: 各種健康データの概要を表示
- **StepCountCard**: 今日の歩数、目標達成率
- **ActivityRingsView**: Apple Watch風のアクティビティリング
- **ChartView**: 週次・月次の推移グラフ（Swift Chartsを使用）
- **DetailView**: 各データの詳細表示
- **SettingsView**: 目標設定、表示項目のカスタマイズ

#### 2.3 デザインシステム
```
health-kit-dashboard/
├── Styles/
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── CardStyle.swift
```

### Phase 3: データ表示機能の実装

#### 3.1 表示する健康データ
- 歩数（Steps）
- 移動距離（Distance）
- 上った階数（Flights Climbed）
- アクティブエネルギー（Active Energy）
- 心拍数（Heart Rate）
- 睡眠データ（Sleep Analysis）
- 運動時間（Exercise Time）

#### 3.2 時系列データの処理
- 今日のデータ
- 週次集計（過去7日間）
- 月次集計（過去30日間）
- カスタム期間の集計

#### 3.3 データキャッシング
```
health-kit-dashboard/
├── Services/
│   └── CacheManager.swift
```

UserDefaultsまたはCoreDataでデータをキャッシュし、アプリ起動時の読み込み速度を改善

### Phase 4: サーバー連携の準備

#### 4.1 ネットワーク層の設計
```
health-kit-dashboard/
├── Network/
│   ├── APIClient.swift
│   ├── APIEndpoint.swift
│   ├── NetworkError.swift
│   └── RequestBuilder.swift
```

#### 4.2 実装内容
- RESTful APIクライアントの実装
- 認証機能（JWT/OAuth2.0）
- データ同期ロジック
- オフライン時の処理
- バックグラウンド同期

#### 4.3 データ同期設計
```
health-kit-dashboard/
├── Services/
│   ├── SyncManager.swift
│   └── SyncScheduler.swift
```

- 定期的なデータアップロード
- 変更差分の検出
- コンフリクト解決ロジック
- 同期状態の管理

#### 4.4 サーバー側API設計（参考）
```
POST   /api/v1/health-data        # データアップロード
GET    /api/v1/health-data        # データ取得
GET    /api/v1/health-data/stats  # 統計情報取得
POST   /api/v1/auth/login         # ログイン
POST   /api/v1/auth/refresh       # トークンリフレッシュ
```

### Phase 5: 追加機能

#### 5.1 通知機能
- 目標達成通知
- リマインダー（「今日はまだ歩いていません」など）
- 週次レポート

#### 5.2 目標設定機能
- カスタマイズ可能な歩数目標
- 目標達成履歴
- バッジ/実績システム

#### 5.3 ウィジェット対応
```
health-kit-dashboard/
├── Widget/
│   ├── HealthWidget.swift
│   └── HealthWidgetProvider.swift
```

ホーム画面に今日の歩数などを表示

#### 5.4 Apple Watch対応
- Watch Connectivity Frameworkの実装
- Watch用ダッシュボード
- コンプリケーション対応

## 技術スタック

### フロントエンド（iOS）
- **言語**: Swift 5.9+
- **フレームワーク**: SwiftUI
- **データ可視化**: Swift Charts
- **HealthKit**: Apple HealthKit Framework
- **ストレージ**: UserDefaults / CoreData
- **ネットワーク**: URLSession / Async/Await

### バックエンド（将来的に）
- **選択肢1**: Node.js + Express + PostgreSQL
- **選択肢2**: Python + FastAPI + PostgreSQL
- **選択肢3**: Go + Gin + PostgreSQL
- **認証**: JWT
- **デプロイ**: AWS / GCP / Azure

## 開発スケジュール例

1. **Week 1-2**: Phase 1（HealthKit基盤）
2. **Week 3-4**: Phase 2（UI/UX実装）
3. **Week 5**: Phase 3（データ表示機能）
4. **Week 6**: テスト・調整
5. **Week 7-8**: Phase 4（サーバー連携準備）
6. **Week 9+**: Phase 5（追加機能）

## ディレクトリ構成（最終形）

```
health-kit-dashboard/
├── App/
│   ├── health_kit_dashboardApp.swift
│   └── AppDelegate.swift
├── Views/
│   ├── Dashboard/
│   ├── Detail/
│   ├── Settings/
│   └── Components/
├── ViewModels/
│   ├── DashboardViewModel.swift
│   └── HealthDataViewModel.swift
├── Models/
│   ├── HealthData.swift
│   └── User.swift
├── Managers/
│   ├── HealthKitManager.swift
│   └── NotificationManager.swift
├── Services/
│   ├── CacheManager.swift
│   ├── SyncManager.swift
│   └── SyncScheduler.swift
├── Network/
│   ├── APIClient.swift
│   ├── APIEndpoint.swift
│   └── NetworkError.swift
├── Styles/
│   ├── Colors.swift
│   ├── Fonts.swift
│   └── CardStyle.swift
├── Extensions/
│   ├── Date+Extensions.swift
│   └── Double+Extensions.swift
└── Resources/
    └── Assets.xcassets
```

## セキュリティ考慮事項

1. **データプライバシー**
   - HealthKitデータは端末内で処理
   - サーバー送信時は暗号化必須
   - ユーザー同意の明確化

2. **通信セキュリティ**
   - HTTPS通信必須
   - Certificate Pinning検討
   - APIトークンの安全な保管（Keychain使用）

3. **データ保持ポリシー**
   - ローカルデータの自動削除オプション
   - サーバー側のデータ保持期間設定

## テスト戦略

1. **Unit Tests**: ビジネスロジック、データ変換
2. **UI Tests**: 主要な画面遷移
3. **Integration Tests**: HealthKitとの連携
4. **Manual Tests**: 実機でのデータ取得確認

## 次のステップ

Phase 1から開始することをお勧めします。具体的には：

1. HealthKit Capabilityの有効化
2. HealthKitManager.swiftの実装
3. 基本的な歩数取得機能の実装
4. シンプルなUIでの表示確認

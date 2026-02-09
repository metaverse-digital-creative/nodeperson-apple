# 🏃 Sprint Roadmap — Data-Driven Development

> **原則：軟體不跟日曆走——跟數據走。**
> 每個功能在真實數據或回饋達到觸發條件時才啟動開發。

---

## 🟢 已完成 (Shipped)

- [x] KarmaScore model (4 dimensions)
- [x] KarmaRingView (shared ring chart)
- [x] KarmaDetailView (iOS — 「我的貢獻紀錄」)
- [x] WatchKarmaView (watchOS — compact view)
- [x] APIConfig port fix (3000→5001)
- [x] Offline fallback (preview data)
- [x] Package.swift macOS v14 (@Observable)
- [x] Xcode `.xcodeproj` (WellnessApple — 3 targets: iOS, watchOS, visionOS)

---

## 📊 下一步：由數據觸發

### Trigger 1: 後端 GKS API 有真實數據
> 📍 觸發條件：`/api/community/karma/:id` 返回**非 seed** 的真實用戶分數

開發項目：
- [ ] 移除 "demo" 預設，連接真實 user session
- [ ] Karma 即時更新（pull-to-refresh + 背景刷新）
- [ ] 貢獻紀錄 timeline 與真實 contributions API 對接

### Trigger 2: 使用者回饋 Watch 畫面
> 📍 觸發條件：收到**第一筆真實用戶回饋**（Karma 顯示太擠/看不懂/想看更多）

開發項目：
- [ ] Watch Complication (錶面小工具)
- [ ] 手腕震動提醒「今天回收了嗎?」
- [ ] Watch 數字尺寸/佈局調整

### Trigger 3: 首筆成交出現
> 📍 觸發條件：recycling-leads-platform 出現第一筆 `completed` match

開發項目：
- [ ] 媒合結果通知 UI
- [ ] 交易→Karma 自動加分動畫
- [ ] 感謝訊息推播 UI

### Trigger 4: 活躍 NodePerson ≥ 10
> 📍 觸發條件：有 ≥ 10 個不同的 nodePersonId 呼叫過 karma API

開發項目：
- [ ] 社區貢獻統計頁面
- [ ] 茶會 UI（創建 / 報名 / QR 簽到）
- [ ] 轉介任務 UI

### Trigger 5: 企業客戶詢問
> 📍 觸發條件：收到第一個企業方的 demo request

開發項目：
- [ ] visionOS 3D 信任熱力圖
- [ ] ESG 報告 UI
- [ ] 企業 Dashboard 模式

---

## 🔄 持續性工作（不需觸發）

- [x] Xcode `.xcodeproj` 設定（真機測試用）— WellnessApple.xcodeproj shipped
- [ ] 單元測試
- [ ] Accessibility (VoiceOver, Dynamic Type)

---

*Updated: 2026-02-09 14:46 | Philosophy: Ship when data says so, not when calendar says so.*

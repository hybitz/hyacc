# Hyacc

## What This Is

日本の中小企業向けの複式簿記会計システム(Rails 8.1 / Ruby 3.4)。会計帳簿・決算・給与・社会保険・源泉徴収などを一体管理する多テナント型Webアプリケーション。本プロジェクトでは、給与・賞与に関する社会保険料計算の精度を高め、法定ルールに準拠させることを目指す。

## Core Value

法定ルールに正しく準拠した社会保険料計算 — 給与・賞与の保険料額が行政の算定方法と一致すること。

## Requirements

### Validated

<!-- 既存コードベースから推定された、既に動作している能力 -->

- ✓ 複式簿記の仕訳管理・自動仕訳生成 — existing
- ✓ 給与・賞与の計算と仕訳連動(`app/models/payroll.rb`, `auto/journal/payroll_factory.rb`)— existing
- ✓ 社会保険料(健康保険・厚生年金・介護保険)の標準報酬月額ベース算定 — existing
- ✓ 源泉所得税(月額表・賞与表)の計算 — existing
- ✓ 従業員・会社・年度・勘定科目のマルチテナント管理 — existing

### Active

<!-- 本マイルストーンのスコープ(仮説)。出荷して検証するまでは確定しない -->

- [ ] 賞与に係る厚生年金保険料計算で「1回あたり標準賞与額 150万円」の上限を適用する
- [ ] 上限値 1,500,000 を `app/utils/hyacc_const.rb` に定数として追加する
- [ ] 上限超過時、厚生年金保険料は 150万円 を基準に自動計算し、画面・帳票に淡々と反映する
- [ ] 機能導入後に新規登録される賞与から適用(過去データの再計算は行わない)

### Out of Scope

- 健康保険・介護保険の年度累計 573万円 上限対応 — 今回は厚生年金のみに絞って影響範囲を限定するため(将来マイルストーンで検討)
- 過去賞与データへの遡及再計算 — 既存帳簿との整合性リスクを避けるため
- 上限超過時の明示的な警告ダイアログ/確認UI — 法定に従った自動計算のみで十分という判断
- 上限額のマスタ/テーブル化・履歴管理 — 法改正頻度が低く、定数管理で十分という判断

## Context

**ドメイン背景:**
- 標準賞与額の上限は日本年金機構の規定(https://www.nenkin.go.jp/shinsei/kounen/tekiyo/shoyo/20120314-01.html)。
- 厚生年金保険:1回の支払につき 150万円 が上限(2016年4月以降)。
- 健康保険:4月〜翌3月の年度累計で 573万円 が上限(2016年4月以降)。
- 現行Hyaccはこの上限を考慮せず、支給額そのものを標準賞与額として保険料を算出している。

**技術環境:**
- Rails 8.1.3 / Ruby 3.4.8 / 標準MVC + ドメイン定数群(`app/utils/hyacc_const.rb`)。
- 社会保険料算出の主な実装: `app/models/social_insurance_finder.rb`, `app/models/payroll.rb`, `app/models/payroll_info/payroll_logic.rb`, `app/models/auto/journal/payroll_factory.rb`。
- 税制・保険料率は gem `tax_jp` で管理(最近バージョンアップ済: commit 6bc237cf)。

## Constraints

- **Tech stack**: Rails 8.1 / Ruby 3.4 に準拠し、既存のモデル構造・定数管理パターンを踏襲する。
- **Compatibility**: 既存の賞与データ・仕訳との整合を壊さない。過去データは現状のまま保持する。
- **Domain accuracy**: 日本年金機構の算定ルールに厳密に一致させる(端数処理・適用タイミング含む)。
- **Maintainability**: 上限額は将来の法改正に備え、`hyacc_const.rb` の定数として一元管理する。

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| 今回のスコープは厚生年金(1回150万円)上限のみ | 影響範囲を絞り、確実にリリースするため。健保の年度累計は別対応 | — Pending |
| 上限額は `hyacc_const.rb` の定数として保持 | 法改正頻度が低く、マスタ化コストに見合わないため | — Pending |
| 過去賞与には遡及適用しない | 既存帳簿・決算との整合リスクを避けるため | — Pending |
| 上限超過の警告UIは設けず自動計算のみ | 法定どおりの粛々とした処理が望ましいため | — Pending |

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-04-12 after initialization*

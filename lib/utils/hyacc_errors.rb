# -*- encoding : utf-8 -*-
#
# $Id: hyacc_errors.rb 2764 2011-12-29 06:06:33Z ichy $
# Product: hyacc
# Copyright 2009-2011 by Hybitz.co.ltd
# ALL Rights Reserved.
#
module HyaccErrors

  ERR_ACCOUNT_ALREADY_USED = "既に伝票の存在する勘定科目のため削除できません。"
  ERR_AMOUNT_UNBALANCED_BY_BRANCH = "部門別で貸借の金額が一致しません。"
  ERR_CANNOT_CHANGE_ASSET_NOT_STATUS_CREATED = "償却対象の資産が存在するため変更できません。"
  ERR_CANNOT_CHANGE_SUB_ACCOUNT_TYPE = "既に伝票の存在する勘定科目のため補助科目区分を変更できません。"
  ERR_CLOSING_STATUS_CLOSING = "仮締状態のため処理を実行できません。"
  ERR_CLOSING_STATUS_CLOSED = "本締状態のため処理を実行できません。"  
  ERR_DB = "DB処理でエラーが発生しました。"
  ERR_DC_AMOUNT_NOT_THE_SAME = "貸借の金額が一致していません。"
  ERR_DEFAULT_BRANCH_NOT_FOUND = "デフォルトの所属部署が存在しません。"
  ERR_DUPLICATED_ASSET_CODE = "資産コードが重複しています。"
  ERR_DUPLICATEE_CARRY_FORWARD_JOURNAL = "繰越仕訳が重複して登録されています。"
  ERR_EMPTY_SUB_ACCOUNT = "補助科目の指定がありません。"
  ERR_FILE_ALREADY_EXISTS = "既に存在するファイル名です。ファイル名を変更して下さい。"
  ERR_FISCAL_YEAR_NOT_EXISTS = "会計年度が定義されていません。"
  ERR_INVALID_ACCOUNT_TYPE = "不正な勘定科目区分です。"
  ERR_INVALID_ACTION = "不正なアクションの呼び出しです。"
  ERR_INVALID_AUTO_JOURNAL_TYPE = "不正な自動仕訳区分です。"
  ERR_INVALID_DC_TYPE = "不正な貸借区分です。"
  ERR_INVALID_SLIP = "不正な伝票です。"
  ERR_INVALID_SLIP_TYPE = "不正な伝票区分です。"
  ERR_INVALID_SOCIAL_EXPENSE_NUMBER_OF_PEOPLE = "接待交際の参加人数が不明です。"
  ERR_INVALID_SOMETHING = "が不正です。"
  ERR_INVALID_SUB_ACCOUNT_TYPE = "補助科目タイプが不正です。"
  ERR_INVALID_TAX_TYPE = "不正な消費税区分です。"
  ERR_ILLEGAL_STATE = "予期せぬ状態です。"
  ERR_ILLEGAL_TAX_DETAIL = "消費税は税抜経理方式の場合のみ指定可能です。"
  ERR_NOT_JOURNALIZABLE_ACCOUNT = "仕訳が登録できない勘定科目が指定されています。"
  ERR_OVERRIDE_NEEDED = "サブクラスでの実装が必要です。"
  ERR_RECORD_NOT_FOUND = "該当するデータが見つかりません。"
  ERR_REQUIRED_SETTLEMENT_TYPE = "決済区分は必須です。"
  ERR_STALE_OBJECT = "古いデータを更新しようとしました。"
  ERR_SUB_ACCOUNT_ALREADY_USED = "は既に使用されているため削除できません。"
  ERR_SUB_ACCOUNT_DUPLICATE_UNIQUE_CODE = "補助科目コードが重複しています。"
  ERR_SUB_ACCOUNT_TYPE_NOT_EDITABLE = "補助科目区分の変更ができない勘定科目です。"
  ERR_SYSTEM_REQUIRED_ACCOUNT = "システムで必須の勘定科目です。"

end

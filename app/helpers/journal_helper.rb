module JournalHelper
  include HyaccConstants

  # 編集可能か
  def can_edit( jh )
    # 自動振替伝票は編集不可
    ! jh.auto?
  end

  # 削除可能か
  def can_delete( jh )
    # 台帳登録は削除不可
    if jh.slip_type == SLIP_TYPE_AUTO_TRANSFER_LEDGER_REGISTRATION
      return false
    end

    return can_edit( jh )
  end

  def style_for_detail(jd)
    return 'display: none;' if jd.deleted?
    return 'display: none;' unless current_user.show_details
    nil
  end

  def message_for_details
    show = current_user.show_details if show.nil?

    if show
      '詳細を隠す'
    else
      '詳細を表示'
    end
  end
end

module JournalHelper
  include HyaccConst

  def can_edit(jh)
    # 台帳登録は編集不可
    if jh.slip_type == SLIP_TYPE_AUTO_TRANSFER_PAYROLL
      return false
    end

    # 有価証券画面から登録した伝票は編集不可
    if jh.slip_type == SLIP_TYPE_INVESTMENT
      return false
    end

    # 自動振替伝票は編集不可
    ! jh.auto?
  end

  def can_delete(jh)
    can_edit(jh)
  end
  
  def can_copy(jh)
    can_edit(jh)
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

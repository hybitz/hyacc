class Slips::SlipUtils
  include HyaccConst

  # 簡易入力機能で編集可能かどうか
  def self.editable_as_simple_slip(jh, target_account_id)
    # 伝票区分は「簡易入力伝票」か「振替伝票」であること
    unless [ SLIP_TYPE_SIMPLIFIED, SLIP_TYPE_TRANSFER ].include? jh.slip_type
      return false
    end

    # 通常の明細数が２つであること
    if jh.get_normal_detail_count != 2
      return false
    end

    # 計上部門が同じであること
    unless is_all_same_branch( jh )
      return false
    end

    # 明細１つが対象としている科目であること
    # ２つとも対象の場合は、振替伝票でのみ編集可
    detail_count = 0
    jh.journal_details.each do |jd|
      detail_count += 1 if jd.account_id == target_account_id
    end
    if detail_count != 1
      return false
    end

    # 明細メモが存在する場合は振替伝票でのみ編集可
    if jh.journal_details.any?{|jd| jd.note.to_s.length > 0 }
      return false
    end

    # 配賦仕訳が存在する場合は振替伝票でのみ編集可
    if jh.journal_details.any?{|jd| jd.allocation_type.present? }
      return false
    end

    true
  end

  # すべて同一計上部門かどうか
  def self.is_all_same_branch( jh )
    branch_id = nil
    jh.journal_details.each do |jd|
      if branch_id.nil?
        branch_id = jd.branch_id
      else
        if branch_id != jd.branch_id
          return false
        end
      end
    end

    true
  end

end
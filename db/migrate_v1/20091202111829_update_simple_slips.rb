# 自動振替伝票と元伝票との紐付けルールが変わったのでデータ移行
class UpdateSimpleSlips < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    # slip_typeがnullの伝票が存在する場合は、汎用的な振替伝票として扱う
    connection.execute("update journal_headers set slip_type=1 where slip_type is null")

    puts '未払金（従業員）を更新'
    a = Account.find_by_code(ACCOUNT_CODE_UNPAID_EMPLOYEE)
    rlike = JournalUtil.build_rlike_condition(a.code, 0, 0)
    JournalHeader.find(:all, :conditions=>['slip_type = ? and finder_key rlike ?', SLIP_TYPE_SIMPLIFIED, rlike]).each do|jh|
      update_auto_journal(a, jh)
    end
    
    puts '小口現金を更新'
    a = Account.find_by_code('1121')
    rlike = JournalUtil.build_rlike_condition(a.code, 0, 0)
    JournalHeader.find(:all, :conditions=>['slip_type = ? and finder_key rlike ?', SLIP_TYPE_SIMPLIFIED, rlike]).each do|jh|
      update_auto_journal(a, jh)
    end
    
    puts '普通預金を更新'
    a = Account.find_by_code('1311')
    rlike = JournalUtil.build_rlike_condition(a.code, 0, 0)
    JournalHeader.find(:all, :conditions=>['slip_type = ? and finder_key rlike ?', SLIP_TYPE_SIMPLIFIED, rlike]).each do|jh|
      update_auto_journal(a, jh)
    end
  end

  def self.down
  end

  def self.update_auto_journal(a, jh)
    journals = JournalUtil.get_all_related_journals(jh)

    auto = has_prepaid_expense_transfers(journals)
    auto = has_accrued_expense_transfers(journals) unless auto
    auto = has_date_input_expense_transfers(journals) unless auto
    return unless auto
    return if auto.transfer_from_detail_id.to_i > 0
    
    puts "#{jh.id}: #{jh.remarks}"
    src_dt = nil
    jh.normal_details.each do |dt|
      if dt.account_id != a.id
        src_dt = dt
        break
      end
    end
    
    # 前払振替
    if auto.slip_type == SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
      connection.execute("update journal_headers set transfer_from_id=null, transfer_from_detail_id=#{src_dt.id} where id=#{auto.id}")
    # 未払振替
    elsif auto.slip_type == SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
      connection.execute("update journal_headers set transfer_from_id=null, transfer_from_detail_id=#{src_dt.id} where id=#{auto.id}")
    # 計上日振替
    elsif auto.slip_type == SLIP_TYPE_AUTO_TRANSFER_EXPENSE
      # 過去に登録された日付指定の計上日振替伝票は、自動仕訳とその逆仕訳の生成順にくせがある
      # 画面入力した計上日を持つ伝票をautoとして登録する現仕様にあわせる
      auto = journals[1]
      reverse = journals[2]
      if journals[0].date == journals[1].date
        auto = journals[2]
        reverse = journals[1]
      end
      
      connection.execute("update journal_headers set transfer_from_id=null, transfer_from_detail_id=#{src_dt.id} where id=#{auto.id}")
      connection.execute("update journal_headers set transfer_from_id=#{auto.id}, transfer_from_detail_id=null where id=#{reverse.id}")
    end
  end

  def self.has_prepaid_expense_transfers(journals)
    return nil if journals.size != 3
    return nil if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
    return nil if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_PREPAID_EXPENSE
    
    return journals[1] unless journals[1].remarks.include?('【逆】')
    return journals[2] unless journals[2].remarks.include?('【逆】')
    return nil
  end

  def self.has_accrued_expense_transfers(journals)
    return nil if journals.size != 3
    return nil if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
    return nil if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE
    
    return journals[1] unless journals[1].remarks.include?('【逆】')
    return journals[2] unless journals[2].remarks.include?('【逆】')
    return nil
  end
  
  def self.has_date_input_expense_transfers(journals)
    return nil if journals.size != 3
    return nil if journals[1].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
    return nil if journals[2].slip_type != SLIP_TYPE_AUTO_TRANSFER_EXPENSE
    
    return journals[1] unless journals[1].remarks.include?('【逆】')
    return journals[2] unless journals[2].remarks.include?('【逆】')
    return nil
  end
end

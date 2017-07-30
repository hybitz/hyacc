class UpdateDayOnAccruedExpenseReverseJournals < ActiveRecord::Migration[5.0]
  include HyaccConstants

  def up
    JournalHeader.where(:slip_type => SLIP_TYPE_AUTO_TRANSFER_ACCRUED_EXPENSE).find_each do |jh|
      
      if jh.transfer_from_id.present?
        puts "id: #{jh.id} #{jh.remarks}"

        unless jh.remarks.include?('【自動】【逆】')
          raise '逆仕訳かどうか怪しい'
        end

        from = JournalHeader.find(jh.transfer_from_id)
        if from.remarks + '【逆】' != jh.remarks
          raise '自動仕訳かどうか怪しい'
        end
        
        original = JournalDetail.find(from.transfer_from_detail_id).journal_header
        if original.remarks + '【自動】' != from.remarks
          raise '元仕訳かどうか怪しい'
        end
        
        if original.ym != jh.ym
          raise '元仕訳と逆仕訳の年月が一致しない'
        end
        
        if jh.day == original.day
          puts "\tOK"
        elsif jh.day != 1
          raise '逆仕訳の日が 1 日ではない'
        end

        jh.update(:day => original.day)
      else
        if jh.remarks.include?('【自動】【逆】')
          raise '逆仕訳の自動仕訳が不明'
        end
      end
    end
  end
  
  def down
  end
end

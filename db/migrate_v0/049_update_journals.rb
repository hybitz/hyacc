# 部門間で貸借が合っていない振替伝票を支店間取引に対応させる
class UpdateJournals < ActiveRecord::Migration
  include HyaccConstants
  
  def self.up
    JournalHeader.find(:all, :conditions=>['slip_type=?', SLIP_TYPE_TRANSFER]).each do |jh|
      print("updating journal [" + jh.id.to_s + "]\n")
    
      param = Auto::AutoTransferParam.new( AUTO_TRANSFER_TYPE_INTERNAL_TRADE )
      factory = Auto::AutoTransferFactory.get_instance( param, jh )
      
      if factory.nil?
        # 自動振替ファクトリが取得できなければ自動振替仕訳は不要
        jh.transfer_journals.clear
      else
        # 自動振替仕訳を作成して保存する
        factory.make_auto_transfers()
      end
    end
  end

  def self.down
  end
end

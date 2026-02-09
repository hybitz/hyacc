module Reports
  class MiscellaneousLogic < BaseLogic

    def build_model
      ret = MiscellaneousModel.new

      profit = Account.find_by_code(ACCOUNT_CODE_MISCELLANEOUS_PROFIT)
      Journal.where('ym >= ? and ym <= ? and finder_key rlike ?', start_ym, end_ym, JournalUtil.finder_key_rlike(profit.code, 0, 0)).order('ym, day, id').each do |j|
        detail = build_detail_model(profit, j)
        ret.add_profit_detail(detail)
      end

      loss = Account.find_by_code(ACCOUNT_CODE_MISCELLANEOUS_LOSS)
      Journal.where('ym >= ? and ym <= ? and finder_key rlike ?', start_ym, end_ym, JournalUtil.finder_key_rlike(loss.code, 0, 0)).order('ym, day, id').each do |j|
        detail = build_detail_model(loss, j)
        ret.add_loss_detail(detail)
      end

      ret.fill_details(5)
      ret
    end

    private

    def build_detail_model(account, journal)
      ret = MiscellaneousDetailModel.new
      ret.account_name = account.name
      ret.remarks = journal.remarks
      ret.amount = journal.journal_details.where(account_id: account.id).inject(0) do |sum, detail|
        if detail.dc_type == account.dc_type
          sum += detail.amount
        else
          sum -= detail.amount
        end
      end
      ret
    end

  end

  class MiscellaneousModel
    attr_accessor :profit_details
    attr_accessor :loss_details

    def initialize
      self.profit_details = []
      self.loss_details = []
    end

    def add_profit_detail(detail)
      self.profit_details << detail
    end

    def add_loss_detail(detail)
      self.loss_details << detail
    end

    def fill_details(min_count)
      (profit_details.size ... min_count).each do
        add_profit_detail(MiscellaneousDetailModel.new)
      end
      (loss_details.size ... min_count).each do
        add_loss_detail(MiscellaneousDetailModel.new)
      end
    end

  end
  
  class MiscellaneousDetailModel
    attr_accessor :account_name
    attr_accessor :remarks
    attr_accessor :amount
  end

end

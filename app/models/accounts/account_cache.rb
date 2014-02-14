module Accounts
  module AccountCache
    module ClassMethods
      include HyaccConstants

      def get(id)
        return nil unless id
        with_latency("#{self.name}.get(#{id})") do
          ret = find_by_id(id)
          if ret
            ret.initialize_sub_accounts_support()
          end
          ret
        end
      end

      def get_by_code(code)
        return nil unless code
        with_latency("#{self.name}.get_by_code(#{code})") do
          ret = find_by_code(code)
          if ret
            ret.initialize_sub_accounts_support()
          end
          ret
        end
      end

      # 仕訳可能な勘定科目のみ取得する
      def get_journalizable_accounts(include_deleted = false)
        with_latency("#{self.name}.get_journalizable_accounts(#{include_deleted})") do
          accounts = where(:journalizable => true)
          unless include_deleted
            accounts = accounts.where(:deleted => false)
          end
          accounts = accounts.where('code <> ?', ACCOUNT_CODE_VARIOUS).order(:code)

          # 補助科目が未整備の勘定科目を除外
          ret = []
          accounts.each do |a|
            next if a.sub_account_type != SUB_ACCOUNT_TYPE_NORMAL && a.sub_accounts.empty?
            ret << a
          end
          ret
        end
      end
      
      def expire_caches_by_sub_account_type(sat)
        Account.scoped_by_sub_account_type(sat).each do |a|
          a.expire_caches
        end
      end

    end
    
    module InstanceMethods
      def expire_caches
        super
        Rails.cache.delete("#{self.class.name}.get_journalizable_accounts(true)")
        Rails.cache.delete("#{self.class.name}.get_journalizable_accounts(false)")
      end
    end
  end
end
module Accounts
  class SubAccountsRequestCache < ActiveSupport::CurrentAttributes
    attribute :store

    class << self
      def cache
        self.store ||= {}
      end

      def reset
        self.store = {}
      end    
    end
  end
end

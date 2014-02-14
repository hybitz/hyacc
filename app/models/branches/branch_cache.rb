module Branches
  module BranchCache
    module ClassMethods
    end
    
    module InstanceMethods
      include HyaccConstants

      def expire_caches
        super
        Account.expire_caches_by_sub_account_type(SUB_ACCOUNT_TYPE_BRANCH)
      end
    end
  end
end
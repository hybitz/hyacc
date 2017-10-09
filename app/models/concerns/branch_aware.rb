module BranchAware
  extend ActiveSupport::Concern

  included do
    attr_accessor :branch_id
  end

  def branch
    @branch ||= company.branches.find(branch_id)
  end

  def branches
    @branches ||= company.branches
  end

end
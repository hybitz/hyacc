class SimpleSlipTemplateFinder
  include ActiveModel::Model
  include Pagination
  include CompanyAware
  include AccountAware
  include BranchAware

  attr_accessor :remarks
  
  def list
    ret = SimpleSlipTemplate.where(conditions).includes([:account, :branch]).order('remarks')
    ret = ret.paginate(page: page, per_page: per_page)
  end

  private

  def conditions
    sql = SqlBuilder.new
    sql.append('simple_slip_templates.deleted = ?', false)
    sql.append('and account_id = ?', account_id) if account_id.present?
    sql.append('and remarks like ?', "%#{remarks}%") if remarks.present?
    sql.to_a
  end
end

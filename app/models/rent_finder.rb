class RentFinder
  include ActiveModel::Model
  include HyaccConst
  include Pagination
  
  attr_accessor :status
  
  def list
    Rent.where(conditions).includes(:customer).order('status, end_to desc').paginate(page: page, per_page: per_page)
  end

  private

  def conditions
    ret = []
    if status.present?
      ret << 'status = ?'
      ret << status
    end
    ret
  end
end

class RentFinder < Daddy::Model
  include HyaccConstants
  
  def list
    Rent.where(conditions).order('status, ymd_end desc').paginate(:page => page, :per_page => per_page)
  end

  def deleted?
    deleted == 'true' if deleted.present?
  end

  private

  def conditions
    ret = []
    if deleted.present?
      ret << 'status = ?'
      if deleted?
        ret << RENT_STATUS_TYPE_STOP
      else
        ret << RENT_STATUS_TYPE_USE
      end
    end
    ret
  end
end

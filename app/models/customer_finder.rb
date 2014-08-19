class CustomerFinder < Base::Finder
  
  def initialize( user )
    super(user)
    @deleted = false
  end

  def list
    Customer.where(conditions).order('code').paginate(:page => @page > 0 ? @page : 1, :per_page => @slips_per_page)
  end

  private

  def conditions
    ret = []
    unless @deleted.nil?
      ret << 'deleted=?'
      ret << @deleted
    end
    ret
  end
end

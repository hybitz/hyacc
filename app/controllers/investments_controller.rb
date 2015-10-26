class InvestmentsController < Base::HyaccController
  view_attribute :title => '有価証券'
  view_attribute :customers, :only => :new, :conditions => {:is_investment => true, :deleted => false}

  def index
  end

  def new
    @investment = Investment.new
  end
  
  def create
    @investment = Investment.new(investment_params)
  end

  private
  
  def investment_params
    params.require(:investment).permit(:name)
  end
end

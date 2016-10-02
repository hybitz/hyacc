class Mm::CustomersController < Base::HyaccController
  view_attribute :title => '取引先'

  helper_method :finder
  
  def index
    @customers = finder.list
  end

  def show
    @customer = Customer.find(params[:id])
  end

  def new
    @customer = Customer.new
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def create
    begin
      @customer = Customer.new(customer_params)

      @customer.transaction do
        @customer.save!
      end

      flash[:notice] = '取引先を登録しました。'
      render 'common/reload'

    rescue => e
      handle(e)
      render 'new'
    end
  end

  def update
    begin
      @customer = Customer.find(params[:id])

      @customer.transaction do
        @customer.attributes = customer_params
        @customer.save!
        flash[:notice] = '取引先を更新しました。'
        render 'common/reload'
      end
    rescue => e
      handle(e)
      render :edit
    end
  end

  def destroy
    @customer = Customer.find(params[:id])

    @customer.transaction do
      @customer.destroy_logically!
    end

    flash[:notice] = '取引先を削除しました。'
    redirect_to :action => :index
  end

  private

  def finder
    unless @finder
      @finder = CustomerFinder.new(params[:finder])
      @finder.disabled ||= 'false'
      @finder.page = params[:page] || 1
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def customer_params
    permitted = [
      :name, :name_effective_at, :formal_name, :formal_name_effective_at,
      :is_order_entry, :is_order_placement, :is_investment, :address, :disabled,
      :names_attributes => [:id, :_destroy],
      :formal_names_attributes => [:id, :_destroy]
    ]

    ret = params.require(:customer)

    case action_name
    when 'create'
      ret = ret.permit(permitted, :code)
    when 'update'
      ret = ret.permit(permitted)
    end

    ret
  end

end

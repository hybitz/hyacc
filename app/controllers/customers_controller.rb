class CustomersController < Base::HyaccController
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
    @customer.customer_names << CustomerName.new
  end

  def add_customer_name
    cn = CustomerName.new
    render :partial => 'customer_name_fields', :locals => {:cn => cn, :index => params[:index]}
  end

  def edit
    @customer = Customer.find(params[:id])
  end

  def create
    begin
      @customer = Customer.new(customer_params)
      @customer.customer_names.first.start_date = current_user.company.founded_date

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
      @finder.page = params[:page] || 1
      @finder.per_page = current_user.slips_per_page
    end
    
    @finder
  end

  def customer_params
    customer_names_attributes = [:id, :_destroy, :name, :formal_name, :start_date]

    if action_name == 'create'
      params.require(:customer)
          .permit(:code, :is_order_entry, :is_order_placement, :address, :disabled,
              :customer_names_attributes => customer_names_attributes)
    else
      params.require(:customer)
          .permit(:is_order_entry, :is_order_placement, :address, :disabled,
              :customer_names_attributes => customer_names_attributes)
    end
  end

end

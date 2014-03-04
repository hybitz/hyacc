# coding: UTF-8

class CustomersController < Base::HyaccController
  view_attribute :title => '取引先'
  view_attribute :finder, :class => CustomerFinder, :only => :index
  view_attribute :deleted_types
  
  def add_customer_name
    cn = CustomerName.new
    render :partial => 'customer_name_fields', :locals => {:cn => cn, :index => params[:index]}
  end

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

  def edit
    @customer = Customer.find(params[:id])
  end

  def create
    begin
      @customer = Customer.new(params[:customer])
      @customer.customer_names[0].start_date = current_user.company.founded_date

      @customer.transaction do
        @customer.save!
      end

      flash[:notice] = '取引先を登録しました。'
      render 'common/reload'

    rescue Exception=>e
      handle(e)
      render 'new'
    end
  end

  def update
    begin
      # 取引先コードの更新は不可
      params[:customer].delete( :code ) if params[:customer]
  
      @customer = Customer.find(params[:id])
      
      @customer.transaction do
        @customer.attributes = params[:customer]
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

    begin
      @customer.transaction do
        @customer.destroy_logically!
      end

      flash[:notice] = '取引先を削除しました。'

    rescue => e
      handle(e)
    end

    redirect_to(:action=>:index)
  end
end

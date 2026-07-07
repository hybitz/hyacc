class Mm::RentsController < Base::HyaccController
  before_action :check_customer_exists

  helper_method :finder

  def index
    @rents = finder.list
  end

  def show
    @rent = Rent.find(params[:id])
  end

  def new
    @rent = Rent.new
    @customers = Customer.not_deleted
  end

  def edit
    @rent = Rent.find(params[:id])
    @customers = Customer.not_deleted
  end

  def create
    @rent = Rent.new(rent_params)

    begin
      Rent.transaction do
        @rent.save!
      end

      flash[:notice] = "#{ERB::Util.html_escape(@rent.name)} を登録しました。"
      render 'common/reload'

    rescue => e
      handle(e)
      @customers = Customer.not_deleted
      render action: "new"
    end
  end

  def update
    @rent = Rent.find(params[:id])

    begin
      Rent.transaction do
        @rent.update!(rent_params)
      end

      flash[:notice] = "#{ERB::Util.html_escape(@rent.name)} を更新しました。"
      render 'common/reload'

    rescue => e
      handle(e)
      @customers = Customer.not_deleted
      render :edit
    end
  end

  def destroy
    @rent = Rent.find(params[:id])
    @rent.destroy

    flash[:notice] = "#{ERB::Util.html_escape(@rent.name)} を削除しました。"
    redirect_to action: 'index'
  end
  
  private

  def check_customer_exists
    if Customer.count == 0
      render :check_customer_exists and return
    end
  end

  def rent_params
    params.require(:rent).permit(:name, :status, :customer_id, :rent_type, :usage_type, :address, :start_from, :end_to, :zip_code)
  end

  def finder
    @finder ||= RentFinder.new(finder_params)
    @finder.page = params[:page] || 1
    @finder.per_page = current_user.slips_per_page
    @finder
  end
  
  def finder_params
    if params[:finder]
      params.require(:finder).permit(:status)
    end
  end

end

class CareersController < Base::HyaccController
  view_attribute :title => '業務経歴'
  view_attribute :finder, :class => CareerFinder, :only => :index
  view_attribute :employees
  view_attribute :customers, :conditions => ['is_order_entry=?', true]
  
  def index
    if @customers.size > 0
      @careers = finder.list
    end
  end
  
  def new
    @c = Career.new
  end
  
  def create
    @c = Career.new(params[:career])
    begin
      @c.transaction do
        @c.save!
      end
  
      flash[:notice] = '業務経歴を追加しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'new'
    end
  end

  def edit
    @c = Career.find(params[:id])
  end
  
  def update
    @c = Career.find(params[:id])

    begin
      @c.transaction do
        @c.update_attributes!(params[:career])
      end

      flash[:notice] = '業務経歴を更新しました。'
      render 'common/reload'
    rescue => e
      handle(e)
      render 'edit'
    end
  end
  
  def destroy
    c = Career.find(params[:id])
    c.destroy
    flash[:notice] = '業務経歴を削除しました。'
    redirect_to :action => 'index'
  end
end

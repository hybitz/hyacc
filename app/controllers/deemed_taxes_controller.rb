class DeemedTaxesController < Base::HyaccController
  before_action :check_business_type
  
  def index
    fy = current_company.current_fiscal_year
    logic = DeemedTax::DeemedTaxLogic.new(fy)
    @dtm = logic.get_deemed_tax_model
  end
  
  def create
    begin
      fy = current_company.current_fiscal_year
      fy.transaction do
        # 既存の仕訳を破棄
        fy.get_deemed_tax_journals.each do |jh|
          raise HyaccException.new(ERR_DB) unless jh.destroy
        end
        
        # 新たに作成
        param = Auto::Journal::DeemedTaxParam.new(fy, current_user)
        factory = Auto::AutoJournalFactory.get_instance(param)
        factory.make_journals.each do |jh|
          JournalUtil.validate_journal(jh)
          jh.save!
        end
      end
      
      flash[:notice] = '消費税仕訳を作成しました。'
    rescue => e
      handle(e)
    end
    
    redirect_to :action => :index
  end

  private

  def check_business_type
    unless current_company.business_type.present?
      render :action => :business_type_required
    end
  end
end
